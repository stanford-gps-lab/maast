function svdata = L5_decode_satcorr(time, svdata)
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
%
% L5_DECODE_SATCORR assembles decoded 250 bit SBAS L5 satellite correction 
%  data into ready to use corrections and confidence bounds
%
% svdata = L5_decode_satcorr(time, svdata)
%
% Inputs:
%   time    -   time when corrections should be applied
%   svdata  -   structure with satellite correction data decoded from the messages
%
%Outputs:
%   svdata  - structure with interpreted satellite correction data and all
%                   appropriate timeouts checked
%    .dxyzb - delta XYZ and clock corrections including fast and long-term
%    .dfrei - most recent DZFREI
%    .sig2deg - sum of the dual frequency correction degradation variances
%
%  Follows ED-259A
%
%See also: INIT_L5SVDATA INIT_L5SVDATA L5_DECODE_GEOCORR L5_DECODE_MESSAGES 
%          L5_DECODEMT0 L5_DECODEMT31 L5_DECODEMT32 L5_DECODEMT35 
%          L5_DECODEMT37 L5_DECODEMT39  L5_DECODEMT40 L5_DECODEMT47 
%

%Created December 29, 2020 by Todd Walter

global L5MOPS_DFREI_DNUSBAS
global L5MOPS_MIN_GPSPRN L5MOPS_MAX_GPSPRN L5MOPS_MIN_GLOPRN L5MOPS_MAX_GLOPRN 
global L5MOPS_MIN_GALPRN L5MOPS_MAX_GALPRN L5MOPS_MIN_GEOPRN L5MOPS_MAX_GEOPRN
global L5MOPS_MIN_BDSPRN L5MOPS_MAX_BDSPRN
global L5MOPS_MT31_PATIMEOUT L5MOPS_DFRE_PATIMEOUT L5MOPS_MT37_PATIMEOUT 

max_sats = size(svdata.mt35_dfrei,1);

% find which satellite belong to which constellations
gps_i = svdata.prns >= L5MOPS_MIN_GPSPRN & svdata.prns <= L5MOPS_MAX_GPSPRN;
glo_i = svdata.prns >= L5MOPS_MIN_GLOPRN & svdata.prns <= L5MOPS_MAX_GLOPRN;
gal_i = svdata.prns >= L5MOPS_MIN_GALPRN & svdata.prns <= L5MOPS_MAX_GALPRN;
geo_idx = find(svdata.prns >= L5MOPS_MIN_GEOPRN & svdata.prns <= L5MOPS_MAX_GEOPRN);
bds_i = svdata.prns >= L5MOPS_MIN_BDSPRN & svdata.prns <= L5MOPS_MAX_BDSPRN;

%Initialize satellite correction data
svdata.dxyzb   = zeros(max_sats, 4);
svdata.dCov    = NaN(max_sats, 16);
svdata.dCov_sf = NaN(max_sats, 1);
svdata.dfrei   = repmat(L5MOPS_DFREI_DNUSBAS, max_sats, 1);
svdata.degradation  = NaN(max_sats, 1);

%Must have valid MT 31 & 37 messages in order to have valid corrections
if (svdata.mt31_time >= (time - L5MOPS_MT31_PATIMEOUT)) && ...
        (svdata.mt37_time >= (time - L5MOPS_MT37_PATIMEOUT))

    eps_corr  = zeros(max_sats, 1);

    %find the most recent DFREI from mt35
    dt35 = time - svdata.mt35_time(:,1); 
    svdata.dfrei = svdata.mt35_dfrei;
    dtdfrei = dt35*ones(size(svdata.dfrei));
    
    % see if any MT32s are more recent
    dt32 = time - svdata.mt32_time(:,1); 
    idx = dt32 < dtdfrei;
    svdata.dfrei(idx) = svdata.mt32_dfrei(idx);
    dtdfrei(idx) = dt32(idx);  

    %find the corrections
    tmt0 = time - svdata.mt32_t0;
    idx = ~isnan(svdata.mt32_dxyzb(:,1)) & (dt32 <= svdata.mt37_Ivalid32);
    svdata.dxyzb(idx,:) = svdata.mt32_dxyzb(idx,:) + svdata.mt32_dxyzb_dot(idx,:).*tmt0(idx);
    svdata.dCov(idx,:) = svdata.mt32_dCov(idx,:);
    svdata.dCov_sf(idx,:) = 2.^(svdata.mt32_sc_exp(idx,:) - 5);

    %find the degradation term
    eps_corr(gps_i) = floor(dt32(gps_i)/svdata.mt37_Icorr(1))*svdata.mt37_Ccorr(1) + ...
                            dt32(gps_i)*svdata.mt37_Rcorr(1);
    eps_corr(glo_i) = floor(dt32(glo_i)/svdata.mt37_Icorr(2))*svdata.mt37_Ccorr(2) + ...
                            dt32(glo_i)*svdata.mt37_Rcorr(2);
    eps_corr(gal_i) = floor(dt32(gal_i)/svdata.mt37_Icorr(3))*svdata.mt37_Ccorr(3) + ...
                            dt32(gal_i)*svdata.mt37_Rcorr(3);
    eps_corr(bds_i) = floor(dt32(bds_i)/svdata.mt37_Icorr(4))*svdata.mt37_Ccorr(4) + ...
                            dt32(bds_i)*svdata.mt37_Rcorr(4);          
    svdata.degradation = eps_corr;
    
    % find the geo positions and corrections
    for gdx = 1:length(geo_idx)
        %is this the broadcasting geo? (if so, does not need a correction)
        if svdata.prns(geo_idx(gdx)) == svdata.geo_prn
            % find most recent matching active MTs 39 & 40
            iodg = NaN;
            max_time = -Inf;
            for idx = 1:4
                if svdata.mt39(idx).time > time - svdata.mt37_Ivalid3940 && ...
                      svdata.mt40(idx).time > time - svdata.mt37_Ivalid3940
                    eph_time = max([svdata.mt39(idx).time svdata.mt40(idx).time]);
                    if eph_time > max_time
                        max_time = eph_time;
                        iodg = idx - 1;
                        dt_corr = time - eph_time;
                        dt40 = time - svdata.mt40(idx).time;
                    end
                end
            end
            if ~isnan(iodg)
                svdata.dxyzb(geo_idx(gdx),:) = [0 0 0 0];
                svdata.geo_xyzb(gdx,:) = svdata.mt3940(iodg+1).xyzb;
                svdata.dCov(geo_idx(gdx),:) = svdata.mt40(iodg+1).dCov;
                svdata.dCov_sf(geo_idx(gdx),:) = 2.^(svdata.mt40(iodg+1).sc_exp(iodg+1,:) - 5);
                svdata.degradation(geo_idx(gdx),:) = floor(dt_corr/...
                                            svdata.mt37_Icorr(5))...
                                            *svdata.mt37_Ccorr(5) + ...
                                            dt_corr*svdata.mt37_Rcorr(5);
                % if the MT 40 is more recent than other sources of DFREI, use it
                if dt40 < dtdfrei(geo_idx(gdx)) 
                    svdata.dfrei(geo_idx(gdx)) = svdata.mt40(iodg + 1).dfrei;
                    dtdfrei(geo_idx(gdx)) = dt40;
                end
            end     
        %if not, it does need a correction            
        else
            % find most recent matching active MTs 39 & 40 and MT 32
            iodg = NaN;
            max_time = -Inf;
            for idx = 1:4
                if svdata.mt39(idx).time > time - svdata.mt37_Ivalid3940 && ...
                      svdata.mt40(idx).time > time - svdata.mt37_Ivalid3940
                    jdx = 1;
                    while jdx <= size(svdata.mt32_time,2) 
                        if svdata.mt32_time(geo_idx(gdx),jdx) > ...
                                      time - svdata.mt37_Ivalid32 && ...
                                      svdata.mt32_iodn(geo_idx(gdx),jdx) == (idx -1)
                            corr_time = max([svdata.mt32_time(geo_idx(gdx)) ...
                                             svdata.mt39(idx).time ...
                                             svdata.mt40(idx).time]);
                            if corr_time > max_time
                                max_time = corr_time;
                                iodg = idx - 1;
                                dt_corr = time - corr_time;
                                dt40 = time - svdata.mt40(idx).time;
                                jdx = Inf;
                            end
                        end
                        jdx = jdx + 1;
                    end
                end
            end
            %if a set was found use the most recent one
            if ~isnan(iodg)
                svdata.dxyzb(geo_idx(gdx),:) = [0 0 0 0];
                svdata.geo_xyzb(gdx,:) = svdata.mt3940(iodg+1).xyzb;
                svdata.dCov(geo_idx(gdx),:) = svdata.mt40(iodg+1).dCov;
                svdata.dCov_sf(geo_idx(gdx),:) = 2.^(svdata.mt40(iodg+1).sc_exp(iodg+1,:) - 5);
                svdata.degradation(geo_idx(gdx),:) = floor(dt_corr/...
                                            svdata.mt37_Icorr(5))...
                                            *svdata.mt37_Ccorr(5) + ...
                                            dt_corr*svdata.mt37_Rcorr(5);
                % if the MT 40 is more recent than other sources of DFREI, use it
                if dt40 < dtdfrei(geo_idx(gdx)) 
                    svdata.dfrei(geo_idx(gdx)) = svdata.mt40(iodg + 1).dfrei;
                    dtdfrei(geo_idx(gdx)) = dt40;
                end
            end
        end
    end
    
    %set the DFREs to NM for any SV with a timed out correction component
    % and are not GEOs
    idx = (dtdfrei > L5MOPS_DFRE_PATIMEOUT  | dt32 > svdata.mt37_Ivalid32) & ...
             (svdata.prns < L5MOPS_MIN_GEOPRN | svdata.prns > L5MOPS_MAX_GEOPRN);
    if any(idx)
        svdata.dfrei(idx) = L5MOPS_DFREI_DNUSBAS;
        svdata.degradation(idx) = NaN;
        svdata.dxyzb(idx,:) = NaN;
    end
    %set the DFREs to NM for any SV with a timed out correction component
    % that are GEOs
    idx = (dtdfrei > L5MOPS_DFRE_PATIMEOUT  | dt32 > svdata.mt37_Ivalid32) & ...
             (svdata.prns >= L5MOPS_MIN_GEOPRN & svdata.prns <= L5MOPS_MAX_GEOPRN);
    if any(idx)
        svdata.dfrei(idx)  = L5MOPS_DFREI_DNUSBAS;
        svdata.degradation(idx)  = NaN;
        svdata.dxyzb(idx,:) = NaN;         
    end 
end