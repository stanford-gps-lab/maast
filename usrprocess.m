function [vhpl, usr2satdata] = usrprocess(satdata, usrdata, igpdata, ...
                            inv_igp_mask, usr2satdata, usrtrpfun, ...
                            usrcnmpfun, time, pa_mode, dual_freq, ...
                            rss_udre, rss_iono)
%*************************************************************************
%*     Copyright c 2020 The board of trustees of the Leland Stanford     *
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
%Modified by Todd Walter Sept. 4, 2013 to include MT27 & other constellations
%Modified by Todd Walter Mar. 26, 2020 to change MT27 format and outputs now included in usr2satdata
%Modified by Todd Walter Apr. 10, 2020 to include MOPS degradation terms

global MOPS_SIN_USRMASK MT27 
global COL_SAT_XYZ COL_USR_XYZ COL_USR_LL COL_SAT_UDREI COL_SAT_DEGRAD ...
        COL_USR_EHAT COL_USR_NHAT COL_USR_UHAT  ...
        COL_U2S_PRN COL_U2S_GXYZB COL_U2S_SIGFLT COL_U2S_SIG2UIRE ...
        COL_U2S_OB2PP COL_U2S_SIG2TRP COL_U2S_SIG2L1MP  ...
        COL_U2S_LOSENU COL_U2S_GENUB COL_U2S_EL COL_U2S_AZ ...
        COL_U2S_IPPLL COL_U2S_TTRACK0 COL_U2S_INITNAN ...
        COL_SAT_COV COL_SAT_SCALEF COL_IGP_LL COL_IGP_GIVEI COL_IGP_DEGRAD
global MOPS_SIG_UDRE MOPS_MT27_DUDRE MOPS_UDREI_NM MOPS_UDREI_DNU 
global MOPS_MIN_GEOPRN MOPS_MAX_GEOPRN
global MOPS_UIRE_NUM MOPS_UIRE_DEN MOPS_UIRE_CONST
global CONST_F1 CONST_F5

nsat = size(satdata,1);
nusr = size(usrdata,1);
nlos = nsat*nusr;

% set the RSS bits if they are unspecified
if isempty(rss_udre)  || isnan(rss_udre)
    rss_udre = true;
end
if isempty(rss_iono)  || isnan(rss_iono)
    rss_iono = true;
end

% initialize some values to NaN
usr2satdata(:,COL_U2S_INITNAN) = NaN;

% form los data from usr to satellites
usr2satdata(:,COL_U2S_GXYZB) = find_los_xyzb(usrdata(:,COL_USR_XYZ), ...
                                            satdata(:,COL_SAT_XYZ));
usr2satdata(:,COL_U2S_GENUB) = find_los_enub(usr2satdata(:,COL_U2S_GXYZB),...
   usrdata(:,COL_USR_EHAT),usrdata(:,COL_USR_NHAT),usrdata(:,COL_USR_UHAT));
abv_mask = find(-usr2satdata(:,COL_U2S_GENUB(3)) >= MOPS_SIN_USRMASK);

if(~isempty(abv_mask))
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
usr2satdata(:, COL_U2S_SIG2TRP) = sig2_trop;

% cnmp
if ~isempty(usrcnmpfun)
    sig2_cnmp = feval(usrcnmpfun,time-usr2satdata(:,COL_U2S_TTRACK0),...
                                usr2satdata(:,COL_U2S_EL));
    usr2satdata(:, COL_U2S_SIG2L1MP) = sig2_cnmp;                            
end

% initialize outputs
sig_flt = NaN(nlos,1);
sig2_uire = NaN(nlos,1);
obl2 = NaN(nlos,1);
vhpl = NaN(nusr,2);

[t1, t2]=meshgrid(1:nusr,1:nsat);
usridx=reshape(t1,nlos,1);
satidx=reshape(t2,nlos,1);
los_xyzb = usr2satdata(:,COL_U2S_GXYZB);
los_enub = usr2satdata(:,COL_U2S_GENUB);
mt28_cov = reshape(satdata(:,COL_SAT_COV)',4,4,nsat);
mt28_sf = satdata(:,COL_SAT_SCALEF);
ll_usr_ipp = usr2satdata(:,COL_U2S_IPPLL);
el = usr2satdata(:,COL_U2S_EL);

% check for valid UDRE
if (pa_mode)
    mops_sig_udre = MOPS_SIG_UDRE;
    mops_sig_udre(13:end) = NaN;
    sig_udre = mops_sig_udre(satdata(:,COL_SAT_UDREI))';
else
    mops_sig_udre = MOPS_SIG_UDRE;
    mops_sig_udre([MOPS_UDREI_NM MOPS_UDREI_DNU]) = NaN;
    sig_udre = mops_sig_udre(satdata(:,COL_SAT_UDREI))';
end

% look for above the elevation mask with a valid udre or if it is a GEO
good_udre = find((sig_udre(satidx(abv_mask)) > 0) | ...
     ((usr2satdata(satidx(abv_mask),COL_U2S_PRN) >= MOPS_MIN_GEOPRN) & ...
      (usr2satdata(satidx(abv_mask),COL_U2S_PRN) <= MOPS_MAX_GEOPRN)));
  
if(~isempty(good_udre))
    good_sat=abv_mask(good_udre);
    
    %Apply Message Type 27 dUDRE values if broadcast 
    if ~isempty(MT27)
        %MT27 message
        sig_flt(good_sat) = sig_udre(satidx(good_sat));
        mt27data = cell2mat(MT27(:,1));
        n_poly = size(mt27data,1);
        % all outside values are the same creat a matrix with a flag to
        % indicate inside/priority and resulting d_udre^2 value
        d_udre2 = repmat([-1 mt27data(1, 6)], length(good_sat), 1);
        
        for pdx = n_poly:-1:1
            region = cell2mat(MT27(pdx,2));
            idx = false(length(good_sat),1);
            inside = inpolygon(usrdata(usridx(good_sat),COL_USR_LL(1)),...
                              usrdata(usridx(good_sat),COL_USR_LL(2)), ...
                              region(:,1), region(:,2));     
            %check to see if it is not already inside a region, inside a 
            % region with lower priority or inside a region with the same 
            % priority but has a lower d_dure                          
            idx(inside) = d_udre2(inside, 1) < mt27data(pdx, 4) | ...
                   (d_udre2(inside, 1) == mt27data(pdx, 4) & ...
                    d_udre2(inside, 2) > mt27data(pdx, 5));
            d_udre2(idx,:) = repmat(mt27data(pdx, 4:5), sum(idx), 1);              
        end
        sig_flt(good_sat) = sig_flt(good_sat).*...
                                 (MOPS_MT27_DUDRE(d_udre2(:, 2) + 1)');
    else
        %Otherwise apply Message Type 28 dUDRE
        sig_flt(good_sat)=udre2flt(los_xyzb(good_sat,:), ....
                                    satidx(good_sat), ...
                                    sig_udre, mt28_cov, mt28_sf);
    end

    if (dual_freq)
        %dual frequency user (iono-free combination)        
        good_los = good_sat;
        %residual iono error (higher order terms) really sig_uire 
        sig2_uire(good_sat) = (MOPS_UIRE_NUM*ones(size(good_sat))./...
                   (MOPS_UIRE_DEN + el(good_los).^2) + MOPS_UIRE_CONST).^2;
        sig2 = sig_flt(good_los).^2 + sig2_uire(good_sat) + sig2_cnmp(good_sat)*...
               (CONST_F1^4 + CONST_F5^4)/((CONST_F1^2 - CONST_F5^2)^2)...
               + sig2_trop(good_los);              
    else
        good_los = [];
        obl2(good_sat) = obliquity2(el(good_sat));
        if (pa_mode)
            sig2_uire(good_sat) = grid2uive(usr2satdata(good_sat,COL_U2S_IPPLL), ...
                                            igpdata(:,COL_IGP_LL), inv_igp_mask, ...
                                            igpdata(:,COL_IGP_GIVEI), ...
                                            [], igpdata(:,COL_IGP_DEGRAD), ...
                                            rss_iono).*obl2(good_sat);
            good_uire=find(sig2_uire(good_sat) > 0);
            if(~isempty(good_uire))
                good_los=good_sat(good_uire);            
            end
        else
            mag_lat = usr2satdata(good_sat,COL_U2S_IPPLL(1)) + ...
                           0.064*180*cos((usr2satdata(good_sat, ...
                             COL_U2S_IPPLL(2))/180-1.617)*pi);
                         
            %mid-latitude klobuchar confidence
            sig2_uire(good_sat) = 20.25*obl2(good_sat);
            %low-latitude klobuchar confidence
            idx = find(abs(mag_lat) < 20);
            if(~isempty(idx))
                sig2_uire(good_sat(idx)) = 81*obl2(good_sat(idx));
            end
            %high-latitude klobuchar confidence
            idx = find(abs(mag_lat) > 55);
            if(~isempty(idx))
                sig2_uire(good_sat(idx)) = 36*obl2(good_sat(idx));
            end            
            good_los = good_sat;
        end
        if(~isempty(good_los))
            %add in degradation terms
            if rss_udre
                sig2_flt = sig_flt(good_los).^2 + ...
                               satdata(satidx(good_los), COL_SAT_DEGRAD);
            else
                sig2_flt = (sig_flt(good_los) + ...
                           satdata(satidx(good_los), COL_SAT_DEGRAD)).^2;
            end
            sig2 = sig2_flt  + sig2_uire(good_los) + ...
                   sig2_trop(good_los) + sig2_cnmp(good_los);        
        end
    end
    
    if(~isempty(good_los))
        usr2satdata(good_los, COL_U2S_SIGFLT) = sig_flt(good_los);
        usr2satdata(good_los, COL_U2S_SIG2UIRE) = sig2_uire(good_los);
        usr2satdata(good_los, COL_U2S_OB2PP) = obl2(good_los);

        % calculate VPL and HPL
        vhpl(1:max(usridx(good_los)),:) = usr_vhpl(los_enub(good_los,:), ...
                                                 usridx(good_los), sig2, ...
                                                 usr2satdata(good_los,COL_U2S_PRN),...
                                                 pa_mode);

        bad_usr=find(vhpl(:,1) <= 0 | vhpl(:,2) <= 0);
        if(~isempty(bad_usr))
          vhpl(bad_usr,:)=NaN;
        end
    end
end

    




