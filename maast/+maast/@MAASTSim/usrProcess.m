function usrProcess(obj)
% usrProcess    run the processing for the users for the current time.

i = obj.Index;
t = obj.Tvec(i);

% TODO: handle the desired processing for this time step


% NOTE: going to ignore all the inputs for now and list what I need here
%   - userObs - need obs for all users to all satellites at a give time
%   (Ux1) array


% NOTE: also want to remove all the globals
% TODO: need a set of MOPS related constants



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CODE BELOW IS A COPY FROM THE ORIGINAL MAAST CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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

% find the El/Az information for each of the user/satellite combinations
%   This is already calculated in each of the observations
% TODO: need to find the iono pierce points for all the satellites in view
% in latitude and longitude


%
% find IPP for all satellites in view to all users
%

% ipp = userObs.getIPP()

if(~isempty(abv_mask)),
  [usr2satdata(abv_mask,COL_U2S_EL),usr2satdata(abv_mask,COL_U2S_AZ)] = ...
        find_elaz(usr2satdata(abv_mask,COL_U2S_LOSENU));
  usr2satdata(abv_mask,COL_U2S_IPPLL) = find_ll_ipp(usrdata(:,COL_USR_LL),...
                                usr2satdata(:,COL_U2S_EL),...
                                usr2satdata(:,COL_U2S_AZ), abv_mask);
end

%
% account for lost LOS satellites and new LOS satellites
%

% TODO: need to account for the TTRACK0 column... this holds history
% information (I think)
% the real question though, is does it need to have history information...
% I guess we do care about history since the evaluation is done on the time
% that the satellite has been in view, which inherently has history

idxold = find(~isnan(usr2satdata(:,COL_U2S_TTRACK0)));  % find the satellites that were already in view (TTRACK0 was set)
idxnew = setdiff(abv_mask,idxold);  % find the satellites that are newly visible

% set start time of track for lost los's to NaN
usr2satdata(setdiff(idxold,abv_mask),COL_U2S_TTRACK0) = NaN; % lost los -> these are the satellites that were in view and no longer are in view
usr2satdata(idxnew,COL_U2S_TTRACK0) = time; % new los -> set their TTRACK0 to be the current time

%
% calculate TROPO (sigma2_tropo)
%   this is only based on elevation angles (of the satellites in view?)
%
%   NOTE: this does the math not just on the satellites in view but all the
%   satellites... with I think NaN for the those not in view
%

% tropo    
sig2_trop = feval(usrtrpfun,usr2satdata(:,COL_U2S_EL));

%
% calculate CNMP (sigma2_cnmp)
%   this depends on TTRACK0 and elevation angles to the satellites in view
%
%   NOTE: this calculates for all the LOSs from all the users to all the
%   satellites with NaN in the LOS that don't make sense
%

% cnmp
if ~isempty(usrcnmpfun)
    sig2_cnmp = feval(usrcnmpfun,time-usr2satdata(:,COL_U2S_TTRACK0),...
                                usr2satdata(:,COL_U2S_EL));
end

% initialize outputs
sig2_flt = NaN(nlos,1);
sig2_uive = NaN(nlos,1);
vhpl = NaN(nusr,2);


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

% check for valid UDRE
if (pa_mode)
    mops_sig2_udre = MOPS_SIG2_UDRE;
    mops_sig2_udre(13:end) = NaN;
    sig2_udre = mops_sig2_udre(satdata(:,COL_SAT_UDREI))';
else
    mops_sig2_udre = MOPS_SIG2_UDRE;
    mops_sig2_udre([MOPS_UDREI_NM MOPS_UDREI_DNU]) = NaN;
    sig2_udre = mops_sig2_udre(satdata(:,COL_SAT_UDREI))';
end
good_udre = find((sig2_udre(satidx(abv_mask)) > 0) | ...
     ((usr2satdata(satidx(abv_mask),COL_U2S_PRN) >= MOPS_MIN_GEOPRN) & ...
      (usr2satdata(satidx(abv_mask),COL_U2S_PRN) <= MOPS_MAX_GEOPRN)));


if(~isempty(good_udre))
    good_sat=abv_mask(good_udre);
    
    if MT27
        %european MT27 message
        sig2_flt(good_sat)=sig2_udre(satidx(good_sat));
        mt27_poly = [[20 -40]; [70 -40]; [70 40]; [20 40]; [20 -40];];
        inside = find(inpolygon(usrdata(usridx(good_sat),COL_USR_LL(1)),...
                          usrdata(usridx(good_sat),COL_USR_LL(2)), mt27_poly(:,1),...
                          mt27_poly(:,2)));     
        sig2_flt(good_sat(inside)) = sig2_flt(good_sat(inside))*3;              
        outside = find(~inpolygon(usrdata(usridx,COL_USR_LL(1)),...
                          usrdata(usridx,COL_USR_LL(2)), mt27_poly(:,1),...
                          mt27_poly(:,2)));
        sig2_flt(outside) = sig2_flt(outside)*10000;
    else
        sig2_flt(good_sat)=udre2flt(los_xyzb(good_sat,:), ....
                                    satidx(good_sat), ...
                                    sig2_udre, mt28_cov, mt28_sf);
    end

    if (dual_freq)
        %dual frequency user (iono-free combination)        
        good_los = good_sat;
        %residual iono error (higher order terms) really sig_uire 
        sig2_uive(good_sat) = (MOPS_UIRE_NUM*ones(size(good_sat))./...
                   (MOPS_UIRE_DEN + el(good_los).^2) + MOPS_UIRE_CONST).^2;
        sig2 = sig2_flt(good_los) + sig2_uive(good_sat) + sig2_cnmp(good_sat)*...
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
            sig2_uive(good_sat) = 20.25;
            %low-latitude klobuchar confidence
            idx = find(abs(mag_lat) < 20);
            if(~isempty(idx))
                sig2_uive(good_sat(idx)) = 81;
            end
            %high-latitude klobuchar confidence
            idx = find(abs(mag_lat) > 55);
            if(~isempty(idx))
                sig2_uive(good_sat(idx)) = 36;
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