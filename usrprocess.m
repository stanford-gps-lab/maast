function [vhpl,sig2_flt,sig2_uive,usr2satdata] = usrprocess(satdata,usrdata,...
                            igpdata,inv_igp_mask,usr2satdata,usrtrpfun,...
                            usrcnmpfun,alm_param,time,pa_mode,dual_freq)
%*************************************************************************
%*     Copyright c 2007 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% User Processing

%Modified Todd Walter June 28, 2007 to include PA vs. NPA mode

global MOPS_SIN_USRMASK 
global COL_SAT_XYZ COL_USR_XYZ COL_USR_LL COL_SAT_UDREI ...
        COL_USR_EHAT COL_USR_NHAT COL_USR_UHAT  ...
        COL_U2S_PRN COL_U2S_GXYZB ...
        COL_U2S_LOSENU COL_U2S_GENUB COL_U2S_EL COL_U2S_AZ ...
        COL_U2S_IPPLL COL_U2S_TTRACK0 COL_U2S_INITNAN...
        COL_SAT_COV COL_SAT_SCALEF COL_IGP_LL COL_IGP_GIVEI
global MOPS_SIG2_UDRE
global CONST_F1 CONST_F5

nsat = size(satdata,1);
nusr = size(usrdata,1);
nlos = nsat*nusr;

% initialize some values to NaN
usr2satdata(:,COL_U2S_INITNAN) = NaN;

% form los data from usr to satellites
usr2satdata(:,COL_U2S_GXYZB) = find_los_xyzb(usrdata(:,COL_USR_XYZ), ...
                                            satdata(:,COL_SAT_XYZ));
usr2satdata(:,COL_U2S_GENUB) = find_los_enub(usr2satdata(:,COL_U2S_GXYZB),...
   usrdata(:,COL_USR_EHAT),usrdata(:,COL_USR_NHAT),usrdata(:,COL_USR_UHAT));
abv_mask = find(-usr2satdata(:,COL_U2S_GENUB(3)) >= MOPS_SIN_USRMASK);

if(~isempty(abv_mask)),
  [usr2satdata(abv_mask,COL_U2S_EL),usr2satdata(abv_mask,COL_U2S_AZ)] = ...
        find_elaz(usr2satdata(abv_mask,COL_U2S_LOSENU));
  usr2satdata(abv_mask,COL_U2S_IPPLL) = find_ll_ipp(usrdata(:,COL_USR_LL),...
                                usr2satdata(:,COL_U2S_EL),...
                                usr2satdata(:,COL_U2S_AZ), abv_mask);
end

idxold = find(~isnan(usr2satdata(:,COL_U2S_TTRACK0)));
idxnew = setdiff(abv_mask,idxold);

% set start time of track for lost los's to NaN
usr2satdata(setdiff(idxold,abv_mask),COL_U2S_TTRACK0) = NaN; % lost los
usr2satdata(idxnew,COL_U2S_TTRACK0) = time; % new los

% tropo    
sig2_trop = feval(usrtrpfun,usr2satdata(:,COL_U2S_EL));
% cnmp
if ~isempty(usrcnmpfun)
    sig2_cnmp = feval(usrcnmpfun,time-usr2satdata(:,COL_U2S_TTRACK0),...
                                usr2satdata(:,COL_U2S_EL));
end

% initialize outputs
sig2_flt = repmat(NaN,nlos,1);
sig2_uive = repmat(NaN,nlos,1);
vhpl = repmat(NaN,nusr,2);

% check for valid UDRE
sig2_udre = MOPS_SIG2_UDRE(satdata(:,COL_SAT_UDREI))';

[t1 t2]=meshgrid(1:nusr,1:nsat);
usridx=reshape(t1,nlos,1);
satidx=reshape(t2,nlos,1);
los_xyzb = usr2satdata(:,COL_U2S_GXYZB);
los_enub = usr2satdata(:,COL_U2S_GENUB);
mt28_cov = reshape(satdata(:,COL_SAT_COV)',4,4,nsat);
mt28_sf = satdata(:,COL_SAT_SCALEF);
igp_mask = igpdata(:,COL_IGP_LL);
ll_usr_ipp = usr2satdata(:,COL_U2S_IPPLL);
el = usr2satdata(:,COL_U2S_EL);
givei = igpdata(:,COL_IGP_GIVEI);

good_udre = find(sig2_udre(satidx(abv_mask)) > 0);
if(~isempty(good_udre))
    good_sat=abv_mask(good_udre);
    sig2_flt(good_sat)=udre2flt(los_xyzb(good_sat,:), satidx(good_sat), ...
                                sig2_udre, mt28_cov, mt28_sf);

    if (dual_freq)
        %dual frequency user (iono-free combination)        
        good_los = good_sat;
        sig2 = sig2_flt(good_los) + sig2_cnmp(good_sat)*...
               (CONST_F1^4 + CONST_F5^4)/((CONST_F1^2 - CONST_F5^2)^2)...
               + sig2_trop(good_los);              
    else
        if (pa_mode)
            sig2_uive(good_sat)=grid2uive(ll_usr_ipp(good_sat,:), igp_mask, ...
                                  inv_igp_mask, givei);
            good_uive=find(sig2_uive(good_sat) > 0);
            if(~isempty(good_uive))
                good_los=good_sat(good_uive);            
            end
        else
            mag_lat = usr2satdata(good_sat,COL_U2S_IPPLL(1)) + ...
               0.064*180*cos((usr2satdata(good_sat,COL_U2S_IPPLL(2))/180-1.617)*pi);
           
            %mid-latitude klobuchar confidence
            sig2_uive(good_sat) = 20.25*obliquity2(el(good_sat));
            %low-latitude klobuchar confidence
            idx = find(abs(mag_lat) < 20);
            if(~isempty(idx))
                sig2_uive(good_sat(idx)) = 81*obliquity2(el(good_sat(idx)));
            end
            %high-latitude klobuchar confidence
            idx = find(abs(mag_lat) > 55);
            if(~isempty(idx))
                sig2_uive(good_sat(idx)) = 36*obliquity2(el(good_sat(idx)));
            end            
            good_los = good_sat;
        end
        if(~isempty(good_los))
            sig2 = sig2_flt(good_los) + ...
                   sig2_uive(good_los).*obliquity2(el(good_los)) + ...
                   sig2_trop(good_los) + sig2_cnmp(good_los);        
        end
    end

    % calculate VPL and HPL
    vhpl(1:max(usridx(good_los)),:)=usr_vhpl(los_enub(good_los,:), ...
                                             usridx(good_los), sig2, ...
                                             usr2satdata(good_los,COL_U2S_PRN),...
                                             pa_mode);
    bad_usr=find(vhpl(:,1) <= 0 | vhpl(:,2) <= 0);
    if(~isempty(bad_usr))
      vhpl(bad_usr,:)=NaN;
    end
end

    




