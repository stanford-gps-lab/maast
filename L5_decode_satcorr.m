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

max_prns = L5MOPS_MAX_BDSPRN;

% identify which satellite belong to which constellations
gps_i = L5MOPS_MIN_GPSPRN:L5MOPS_MAX_GPSPRN;
glo_i = L5MOPS_MIN_GLOPRN:L5MOPS_MAX_GLOPRN;
gal_i = L5MOPS_MIN_GALPRN:L5MOPS_MAX_GALPRN;
geo_i = L5MOPS_MIN_GEOPRN:L5MOPS_MAX_GEOPRN;
bds_i = L5MOPS_MIN_BDSPRN:L5MOPS_MAX_BDSPRN;

%Initialize satellite correction data
svdata.dxyzb   = zeros(max_prns, 4);
svdata.dCov    = NaN(max_prns, 16);
svdata.dCov_sf = NaN(max_prns, 1);
svdata.dfrei   = repmat(L5MOPS_DFREI_DNUSBAS, max_prns, 1);
svdata.degradation  = NaN(max_prns, 1);
      
%Must have valid MT 37 message in order to have valid position
mdx37 = find(([svdata.mt37.time] >= (time - L5MOPS_MT37_PATIMEOUT)) & ...
          svdata.auth_pass([svdata.mt37.msg_idx])');
if ~isempty(mdx37)
    mdx37 = mdx37(1); %use the most recent one

    eps_corr  = zeros(max_prns, 1);
    dRcorr  = ones(max_prns, 1);
    dtdfrei = NaN(max_prns, 1);
    dtcorr = NaN(max_prns, 1);
    
    % find the most recent authenticated MT 32 for each satellite
    mdx32 = (reshape([svdata.mt32.time], size(svdata.mt32)) ...
                             >= (time - svdata.mt37(mdx37).Ivalid32)) & ...
              svdata.auth_pass(reshape([svdata.mt32.msg_idx], size(svdata.mt32)));
    if any(mdx32(:))
        % use only the most recent and ignore duplicate older versions 
        mdx32(mdx32(:,1),2:3) = false;
        mdx32(mdx32(:,2),3) = false;
        idx32 = find(any(mdx32,2));
        [a, b] = ind2sub(size(mdx32'), find(mdx32')); %convert to indices
        mdx32 = sub2ind(size(mdx32),b,a);
        
        svdata.dfrei(idx32) = [svdata.mt32(mdx32).dfrei]';
        dtcorr(idx32) = time - [svdata.mt32(mdx32).time]';
        dtdfrei(idx32) = dtcorr(idx32);
        
        %remove the SBAS satellite values as they will be filled in  later
        svdata.dfrei(geo_i) = L5MOPS_DFREI_DNUSBAS;
        dtcorr(geo_i) = NaN;
        dtdfrei(geo_i) = NaN;
        
        %find the corrections
        tmt0 = time - [svdata.mt32(mdx32).t0]';
        mt32_dxyzb = reshape([svdata.mt32(mdx32).dxyzb], 4, length(idx32))';
        mt32_dxyzb_dot = reshape([svdata.mt32(mdx32).dxyzb_dot], 4, length(idx32))';
        svdata.dxyzb(idx32,:) = mt32_dxyzb + mt32_dxyzb_dot.*tmt0;
        dRcorr(idx32) = [svdata.mt32(mdx32).dRcorr]';
        mt32_iodn = [svdata.mt32(mdx32).iodn]';

        %find the MT28 parameters
        svdata.dCov(idx32,:) = reshape([svdata.mt32(mdx32).dCov], 16, length(idx32))';
        svdata.dCov_sf(idx32,:) = 2.^([svdata.mt32(mdx32).sc_exp]' - 5);      
        
        %find the degradation term
        dRcorr(gps_i(dtcorr(gps_i) > svdata.mt37(mdx37).Icorr(1))) = 1;
        eps_corr(gps_i) = floor(dtcorr(gps_i)/svdata.mt37(mdx37).Icorr(1))*svdata.mt37(mdx37).Ccorr(1) + ...
                                dtcorr(gps_i)*svdata.mt37(mdx37).Rcorr(1).*dRcorr(gps_i);
        dRcorr(glo_i(dtcorr(glo_i) > svdata.mt37(mdx37).Icorr(2))) = 1;
        eps_corr(glo_i) = floor(dtcorr(glo_i)/svdata.mt37(mdx37).Icorr(2))*svdata.mt37(mdx37).Ccorr(2) + ...
                                dtcorr(glo_i)*svdata.mt37(mdx37).Rcorr(2).*dRcorr(glo_i);
        dRcorr(gal_i(dtcorr(gal_i) > svdata.mt37(mdx37).Icorr(3))) = 1;
        eps_corr(gal_i) = floor(dtcorr(gal_i)/svdata.mt37(mdx37).Icorr(3))*svdata.mt37(mdx37).Ccorr(3) + ...
                                dtcorr(gal_i)*svdata.mt37(mdx37).Rcorr(3).*dRcorr(gal_i);
        dRcorr(bds_i(dtcorr(bds_i) > svdata.mt37(mdx37).Icorr(4))) = 1;
        eps_corr(bds_i) = floor(dtcorr(bds_i)/svdata.mt37(mdx37).Icorr(4))*svdata.mt37(mdx37).Ccorr(4) + ...
                                dtcorr(bds_i)*svdata.mt37(mdx37).Rcorr(4).*dRcorr(bds_i);         
    end
    
    % find the geo positions and corrections
    for gdx = 1:size(svdata.mt3940, 2)
        %is this the broadcasting geo? (if so, does not need a correction)
        if svdata.geo_channel == gdx
            % find most recent matching active MTs 39 & 40
            iodg = NaN;
            max_time = -Inf;
            for idx = 1:4
                if svdata.mt3940(idx, gdx).time > time - svdata.mt37(mdx37).Ivalid3940 
                    if svdata.mt3940(idx, gdx).time > max_time
                        max_time = svdata.mt3940(idx, gdx).time;
                        iodg = idx - 1;
                        dt_corr = time - svdata.mt3940(idx, gdx).time;
                        kdx40 = svdata.mt3940(idx, gdx).kdx40;
                        dt40 = time - svdata.mt40(kdx40, idx).time;
                    end
                end
            end
            if ~isnan(iodg)
                svdata.dxyzb(svdata.geo_prn,:) = [0 0 0 0];
                svdata.geo_xyzb(gdx,:) = svdata.mt3940(iodg+1, gdx).xyzb;
                svdata.dCov(svdata.geo_prn,:) = svdata.mt40(iodg+1, kdx40).dCov;
                svdata.dCov_sf(svdata.geo_prn) = 2^(svdata.mt40(iodg+1, kdx40).sc_exp - 5);
                dRcorr(svdata.geo_prn) = svdata.mt40(iodg+1, kdx40).dRcorr;
                if dt40 > svdata.mt37(mdx37).Icorr(5)
                    dRcorr(svdata.geo_prn) = 1;
                end
                dtcorr(svdata.geo_prn) = dt_corr;
                eps_corr(svdata.geo_prn) = floor(dt_corr/...
                        svdata.mt37(mdx37).Icorr(5))*svdata.mt37(mdx37).Ccorr(5) + ...
                        dt_corr*svdata.mt37(mdx37).Rcorr(5)*dRcorr(svdata.geo_prn);
                % if the MT 40 is more recent than other sources of DFREI, use it
                if dt40 < dtdfrei(svdata.geo_prn)|| isnan(dtdfrei(svdata.geo_prn))
                    svdata.dfrei(svdata.geo_prn) = svdata.mt40(iodg+1, kdx40).dfrei;
                    dtdfrei(svdata.geo_prn) = dt40;
                end
            end     
        %if not the broadacast satellite, it does need a correction            
        elseif any(~isnan([svdata.mt3940(:, gdx).prn]))
            % find most recent matching active MTs 39 & 40 and MT 32
            iodg = NaN;
            max_time = -Inf;
            for idx = 1:4
                if svdata.mt3940(idx, gdx).time > time - svdata.mt37(mdx37).Ivalid3940
                    geo_prn = svdata.mt3940(idx, gdx).prn;
                    % find the most recent authenticated MT 32 for this satellite that matches IODG
                    mdx32 = find(([svdata.mt32(geo_prn,:).time]' ...
                               >= (time - svdata.mt37(mdx37).Ivalid32)) & ...
                              svdata.auth_pass([svdata.mt32(geo_prn,:).msg_idx]) & ...
                              ([svdata.mt32(geo_prn,:).iodn]' == (idx - 1)));                
                    if ~isempty(mdx32)
                        mdx32 = mdx32(1);
                        corr_time = svdata.mt32(geo_prn,mdx32).time;
                        if corr_time > max_time
                            max_time = corr_time;
                            iodg = idx - 1;
                            dt_corr = time - corr_time;
                            kdx32 = mdx32;
                        end
                    end
                end
            end
            %if a set was found use the most recent one
            if ~isnan(iodg)
                svdata.geo_xyzb(gdx,:) = svdata.mt3940(iodg+1, gdx).xyzb;
                tmt0 = time - svdata.mt32(geo_prn, kdx32).t0;
                svdata.dxyzb(geo_prn,:) = svdata.mt32(geo_prn, kdx32).dxyzb + ...
                                svdata.mt32(geo_prn, kdx32).dxyzb_dot*tmt0;
                dRcorr(idx32) = [svdata.mt32(kdx32).dRcorr]';
                mt32_iodn(geo_prn) = svdata.mt32(geo_prn, kdx32).iodn;
                svdata.dxyzb(geo_prn,:) = [0 0 0 0];
                svdata.dCov(geo_prn,:) = svdata.mt40(iodg+1, kdx40).dCov;
                svdata.dCov_sf(geo_prn) = 2^(svdata.mt40(iodg+1, kdx40).sc_exp - 5);
                svdata.dfrei(geo_prn) = svdata.mt32(geo_prn, kdx32).dfrei;
                dtdfrei(geo_prn) = dt_corr;
                dRcorr(geo_prn) = svdata.mt40(iodg+1, kdx40).dRcorr;
                if dt_corr > svdata.mt37(mdx37).Icorr(5)
                    dRcorr(geo_prn) = 1;
                end    
                dtcorr(geo_prn) = dt_corr;
                eps_corr(geo_prn,:) = floor(dt_corr/...
                        svdata.mt37(mdx37).Icorr(5))*svdata.mt37(mdx37).Ccorr(5) + ...
                        dt_corr*svdata.mt37(mdx37).Rcorr(5)*dRcorr(geo_prn);
            end
        end
    end
        %find the most recent authenticated MT 35 with matching MT 31
    mdx35 = find(([svdata.mt35.time] >= (time - L5MOPS_DFRE_PATIMEOUT)) & ...
              svdata.auth_pass([svdata.mt35.msg_idx])');
    if ~isempty(mdx35)
        dt35 = NaN;
        idx = 1;
        while isnan(dt35) && idx <= length(mdx35)
            %Must have valid MT 31 message with matching IODM in order to use MT35
            mdx31 = find(([svdata.mt31.time] >= (time - L5MOPS_MT31_PATIMEOUT)) & ...
                      svdata.auth_pass([svdata.mt31.msg_idx])' &  ...
                      ([svdata.mt31.iodm] == svdata.mt35(mdx35(idx)).iodm));
            if ~isempty(mdx31)
                mdx31 = mdx31(1); %use the most recent one
   
                % find which DFREI need to be updated
                dt35 = time - svdata.mt35(mdx35(idx)).time;
%                 idxdfrei = find(dtdfrei > dt35);
                idxdfrei = dtdfrei > dt35;
                idxmt35 = svdata.mt31(mdx31).prn2slot(idxdfrei);
                svdata.dfrei(idxdfrei) = svdata.mt35(mdx35(idx)).dfrei(idxmt35);
                dtdfrei(idxdfrei) = dt35;
            end
            idx = idx + 1;
        end
    end
    
    %load in the degradation terms
    svdata.degradation = eps_corr;
    
    %set the DFREs to NM for any SV with a timed out DFREI
    svdata.dfrei(dtdfrei > L5MOPS_DFRE_PATIMEOUT) = L5MOPS_DFREI_DNUSBAS;
    
    corr_t_out = svdata.mt37(mdx37).Ivalid32*ones(size(dtcorr));
    corr_t_out(svdata.geo_prn) = svdata.mt37(mdx37).Ivalid3940;
    %set the DFREs to NM for any SV with a timed out correction
    svdata.dfrei(dtcorr > corr_t_out) = L5MOPS_DFREI_DNUSBAS;    
end