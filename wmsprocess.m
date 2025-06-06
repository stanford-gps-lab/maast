function [satdata,igpdata,wrs2satdata] = wmsprocess(alm_param, satdata,...
                            wrsdata, igpdata, wrs2satdata, gpsudrefun,...
                            geoudrefun, givefun, wrstrpfun, wrsgpscnmpfun,...
                            wrsgeocnmpfun, outputs, time, tstart, tstep,...
                            trise, inv_igp_mask, truth_data, dual_freq, ...
                            active_satdata)
                            
%*************************************************************************
%*     Copyright c 2021 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%function [satdata,igpdata,wrs2satdata] = wmsprocess(alm_param, satdata,...
%                            wrsdata, igpdata, wrs2satdata, gpsudrefun,...
%                            geoudrefun, givefun, wrstrpfun, wrsgpscnmpfun,...
%                            wrsgeocnmpfun, outputs, time, tstart, tstep,...
%                            trise, inv_igp_mask, truth_data, dual_freq)
% WMS Processing

global MOPS_SIN_WRSMASK CONST_H_IONO
global COL_SAT_PRN COL_SAT_XYZ COL_USR_XYZ COL_USR_LL ...
        COL_USR_EHAT COL_USR_NHAT COL_USR_UHAT  COL_IGP_LL ...
        COL_IGP_GIVEI COL_IGP_UPMGIVEI COL_U2S_PRN COL_U2S_GXYZB ...
        COL_U2S_LOSENU COL_U2S_GENUB COL_U2S_EL COL_U2S_AZ COL_U2S_SIG2TRP ...
        COL_U2S_SIG2L1MP COL_U2S_SIG2L2MP COL_U2S_IPPLL COL_U2S_IPPXYZ ...
        COL_U2S_TTRACK0 COL_U2S_IVPP COL_U2S_INITNAN 
global CNMP_TL3
global MOPS_MIN_GPSPRN MOPS_MAX_GPSPRN MOPS_MIN_GLOPRN MOPS_MAX_GLOPRN 
global MOPS_MIN_GALPRN MOPS_MAX_GALPRN MOPS_MIN_GEOPRN MOPS_MAX_GEOPRN
global MOPS_MIN_BDUPRN MOPS_MAX_BDUPRN
global TRUTH_FLAG CONST_R_E CONST_R_IONO;

nsat = size(satdata,1);
nwrs = size(wrsdata,1);
sgps=find(satdata(:,COL_SAT_PRN) >= MOPS_MIN_GPSPRN & ...
          satdata(:,COL_SAT_PRN) <= MOPS_MAX_GPSPRN);
sglo=find(satdata(:,COL_SAT_PRN) >= MOPS_MIN_GLOPRN & ...
          satdata(:,COL_SAT_PRN) <= MOPS_MAX_GLOPRN);
sgal=find(satdata(:,COL_SAT_PRN) >= MOPS_MIN_GALPRN & ...
          satdata(:,COL_SAT_PRN) <= MOPS_MAX_GALPRN);
sbdu=find(satdata(:,COL_SAT_PRN) >= MOPS_MIN_BDUPRN & ...
          satdata(:,COL_SAT_PRN) <= MOPS_MAX_BDUPRN);
sgnss =[sgps; sglo; sgal; sbdu];

sgeo=find(satdata(:,COL_SAT_PRN) >= MOPS_MIN_GEOPRN & ...
          satdata(:,COL_SAT_PRN) <= MOPS_MAX_GEOPRN);

% initialize some values to NaN
wrs2satdata(:,COL_U2S_INITNAN) = NaN;


if TRUTH_FLAG
  abv_mask=sub2ind([nsat nwrs], truth_data(:,3), truth_data(:,2));
  wrs2satdata(abv_mask,COL_U2S_EL) = truth_data(:,7);
  wrs2satdata(abv_mask,COL_U2S_AZ) = truth_data(:,6);
  wrs2satdata(abv_mask,COL_U2S_GENUB) = ...
                   [-cos(wrs2satdata(abv_mask,COL_U2S_EL)).*...
                    sin(wrs2satdata(abv_mask,COL_U2S_AZ)) ...
                    -cos(wrs2satdata(abv_mask,COL_U2S_EL)).*...
                    cos(wrs2satdata(abv_mask,COL_U2S_AZ)) ...
                    -sin(wrs2satdata(abv_mask,COL_U2S_EL)) ones(size(abv_mask))];
  wrs2satdata(abv_mask,COL_U2S_GXYZB) = ...
      find_los_enub(wrs2satdata(:,COL_U2S_GENUB),...
                  [wrsdata(:,COL_USR_EHAT(1)) wrsdata(:,COL_USR_NHAT(1)) ...
                   wrsdata(:,COL_USR_UHAT(1))], ...
                  [wrsdata(:,COL_USR_EHAT(2)) wrsdata(:,COL_USR_NHAT(2)) ...
                   wrsdata(:,COL_USR_UHAT(2))], ...
                  [wrsdata(:,COL_USR_EHAT(3)) wrsdata(:,COL_USR_NHAT(3)) ...
                   wrsdata(:,COL_USR_UHAT(3))], abv_mask);
  wrs2satdata(abv_mask,COL_U2S_IPPLL) = find_ll_ipp(wrsdata(:,COL_USR_LL),...
                                  wrs2satdata(:,COL_U2S_EL),...
                                  wrs2satdata(:,COL_U2S_AZ), abv_mask);
  wrs2satdata(abv_mask,COL_U2S_IPPXYZ) = ...
          llh2xyz([wrs2satdata(abv_mask,COL_U2S_IPPLL),...
                  repmat(CONST_H_IONO,length(abv_mask),1)]);
  obliquity2 = 1./(sqrt(1-(CONST_R_E * cos( truth_data(:,7) ) / (CONST_R_IONO)).^2));
  wrs2satdata(abv_mask,COL_U2S_IVPP) = truth_data(:,8) ./ obliquity2;
else
  % form los data from wrs to satellites
  wrs2satdata(:,COL_U2S_GXYZB) = find_los_xyzb(wrsdata(:,COL_USR_XYZ), ...
                                              satdata(:,COL_SAT_XYZ));
  wrs2satdata(:,COL_U2S_GENUB) = find_los_enub(wrs2satdata(:,COL_U2S_GXYZB),...
     wrsdata(:,COL_USR_EHAT),wrsdata(:,COL_USR_NHAT),wrsdata(:,COL_USR_UHAT));
  abv_mask = find(-wrs2satdata(:,COL_U2S_GENUB(3)) >= MOPS_SIN_WRSMASK);

  if(~isempty(abv_mask))
    [wrs2satdata(abv_mask,COL_U2S_EL),wrs2satdata(abv_mask,COL_U2S_AZ)] = ...
          find_elaz(wrs2satdata(abv_mask,COL_U2S_LOSENU));
    wrs2satdata(abv_mask,COL_U2S_IPPLL) = find_ll_ipp(wrsdata(:,COL_USR_LL),...
                                  wrs2satdata(:,COL_U2S_EL),...
                                  wrs2satdata(:,COL_U2S_AZ), abv_mask);
    wrs2satdata(abv_mask,COL_U2S_IPPXYZ) = ...
          llh2xyz([wrs2satdata(abv_mask,COL_U2S_IPPLL),...
                  repmat(CONST_H_IONO,length(abv_mask),1)]);
  end
end
el = wrs2satdata(:,COL_U2S_EL);

% tropo
wrs2satdata(:,COL_U2S_SIG2TRP) = feval(wrstrpfun,el);

% Calculate cnmp, udre and give 
if isempty(CNMP_TL3)
    CNMP_TL3 = 12000;
end
for i=1:length(abv_mask)
    idx=find(trise(abv_mask(i),:)<=time);
    if ~isempty(idx)
        wrs2satdata(abv_mask(i),COL_U2S_TTRACK0)=max(trise(abv_mask(i),idx));
    else    % los is has been visible since tstart-CNMP_TL3
        wrs2satdata(abv_mask(i),COL_U2S_TTRACK0)=tstart-CNMP_TL3;
    end
end

ttrack = time-wrs2satdata(:,COL_U2S_TTRACK0) + 1;
wgps=find(wrs2satdata(:,COL_U2S_PRN) >= MOPS_MIN_GPSPRN & ...
          wrs2satdata(:,COL_U2S_PRN) <= MOPS_MAX_GPSPRN);
wglo=find(wrs2satdata(:,COL_U2S_PRN) >= MOPS_MIN_GLOPRN & ...
          wrs2satdata(:,COL_U2S_PRN) <= MOPS_MAX_GLOPRN);
wgal=find(wrs2satdata(:,COL_U2S_PRN) >= MOPS_MIN_GALPRN & ...
          wrs2satdata(:,COL_U2S_PRN) <= MOPS_MAX_GALPRN);
wbdu=find(wrs2satdata(:,COL_U2S_PRN) >= MOPS_MIN_BDUPRN & ...
          wrs2satdata(:,COL_U2S_PRN) <= MOPS_MAX_BDUPRN);
wgnss =sort([wgps; wglo; wgal; wbdu]);

wgeo=find(wrs2satdata(:,COL_U2S_PRN) >= MOPS_MIN_GEOPRN & ...
          wrs2satdata(:,COL_U2S_PRN) <= MOPS_MAX_GEOPRN);

% cnmp
if ~isempty(wrsgpscnmpfun)
%  wrs2satdata(gps,COL_U2S_SIG2L1MP) = feval('af_cnmpl1add',ttrack(gps),el(gps));
%  wrs2satdata(gps,COL_U2S_SIG2L2MP) = feval(wrsgpscnmpfun,ttrack(gps),el(gps));
  wrs2satdata(wgnss,COL_U2S_SIG2L1MP) = feval(wrsgpscnmpfun,ttrack(wgnss),el(wgnss));
  wrs2satdata(wgnss,COL_U2S_SIG2L2MP) = wrs2satdata(wgnss,COL_U2S_SIG2L1MP);  
end
if ~isempty(wrsgeocnmpfun)
  wrs2satdata(wgeo,COL_U2S_SIG2L1MP) = feval(wrsgeocnmpfun,ttrack(wgeo),el(wgeo));
  wrs2satdata(wgeo,COL_U2S_SIG2L2MP) = wrs2satdata(wgeo,COL_U2S_SIG2L1MP);
end

% udre
if strcmp(gpsudrefun,'af_udreadd_cov')
 satdata(sgnss,:) = feval(gpsudrefun, satdata(sgnss,:), wrsdata, ...
                        wrs2satdata(wgnss,:), 1, dual_freq, active_satdata);
else
 satdata(sgnss,:) = feval(gpsudrefun, satdata(sgnss,:), wrsdata, ...
                        wrs2satdata(wgnss,:), 1, dual_freq);                   
end 


% give
if(~dual_freq)
    igpdata = feval(givefun, time, igpdata, wrsdata, satdata(sgnss,:), ...
                    wrs2satdata(wgnss,:), truth_data);

    %interpolate the SP and UPM GIVEIs to the GEO LOSs
    wrs2satdata(wgeo,COL_U2S_IVPP)=grid2uive(wrs2satdata(wgeo,COL_U2S_IPPLL), ...
                                                igpdata(:,COL_IGP_LL), ...
                                                inv_igp_mask, ...
                                                igpdata(:,COL_IGP_GIVEI));        
    wrs2satdata(wgeo,COL_U2S_SIG2L2MP)=grid2uive(wrs2satdata(wgeo,COL_U2S_IPPLL), ...
                                                igpdata(:,COL_IGP_LL), ...
                                                inv_igp_mask, ...
                                                igpdata(:,COL_IGP_UPMGIVEI));
end

if strcmp(geoudrefun,'af_geoadd_cov')
   satdata(sgeo,:) = feval(geoudrefun, satdata(sgeo,:), wrsdata, ...
                        wrs2satdata(wgeo,:), 1, dual_freq, active_satdata);
else
   satdata(sgeo,:) = feval(geoudrefun, satdata(sgeo,:), wrsdata, ...
                        wrs2satdata(wgeo,:), 1, dual_freq);
end

