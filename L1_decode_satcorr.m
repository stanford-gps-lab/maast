function svdata = L1_decode_satcorr(time, svdata, mt10)
%*************************************************************************
%*     Copyright c 2024 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%
% L1_DECODE_SATCORR assembles decoded 250 bit SBAS satellite correction data
%  into ready to use corrections and confidence bounds
%
% svdata = L1_decode_satcorr(time, svdata, mt10)
%
% Inputs:
%   time    -   time when corrections should be applied
%   svdata  -   structure with satellite correction data decoded from the messages
%   mt10    -   structure with degradation parameters from MT10
%
%Outputs:
%   svdata  - structure with interpreted satellite correction data and all
%                   appropriate timeouts checked
%    .dxyzb - delta XYZ and clock corrections including fast and long-term
%    .udrei - most recent UDREI
%    .sig2deg - sum of the fast correction (fc), range rate correction (rrc), 
%                and long term correction (ltc) degradation variances
%
%See also: INIT_SVDATA INIT_MT10DATA L1_DECODE_GEOCORR L1_DECODE_MESSAGES 
%          L1_DECODEMT0 L1_DECODEMT1 L1_DECODEmt2345345 L1_DECODEMT6 
%          L1_DECODEMT7 L1_DECODEMT9  L1_DECODEMT10 L1_DECODEMT17 
%          L1_DECODEmt23454 L1_DECODEmt25 L1_DECODEmt28
%
% !!NOTE THAT MT 6 IS ONLY ENCODED AS AN ALERT MESSAGE AND THIS FUNCTION
%     CANNOT HANDLE INTERLEAVED MT 6 AND FC MESSAGES

%Created March 29, 2020 by Todd Walter
%Modified August 22, 2024 by Todd Walter

global MOPS_UDREI_NM %MOPS_UDREI_DNU
global MOPS_MIN_GEOPRN MOPS_MAX_GEOPRN
global MOPS_MT1_PATIMEOUT MOPS_UDRE_PATIMEOUT MOPS_MT7_PATIMEOUT 
global MOPS_MT10_PATIMEOUT MOPS_MT25_PATIMEOUT  
global MOPS_MT27_PATIMEOUT MOPS_MT28_PATIMEOUT
global MOPS_MT7_AI MOPS_MT7_FCTIMEOUT

max_sats = size(svdata.prns,1);

%Initialize satellite correction data
svdata.dxyzb  = zeros(max_sats, 4);
svdata.udrei  = repmat(MOPS_UDREI_NM, max_sats, 1);
svdata.degradation  = NaN(max_sats, 1);


% find the active IODP
mdx2345 = find(~isnan([svdata.mt2345.iodp]) & ...
                 svdata.auth_pass([svdata.mt2345.msg_idx])');
if any(mdx2345)
    [~, i] = max([svdata.mt2345(mdx2345).time]);
    iodp = svdata.mt2345(mdx2345(i)).iodp;
else
    iodp = -1;
end

%Must have valid MT 1, 7, & 10 messages in order to have valid corrections
mdx1 = find(([svdata.mt1.time] >= (time - MOPS_MT1_PATIMEOUT)) & ...
          ([svdata.mt1.iodp] == iodp)  & ...
          svdata.auth_pass([svdata.mt1.msg_idx])');
mdx7 = find(([svdata.mt7.time] >= (time - MOPS_MT7_PATIMEOUT))  & ...
          ([svdata.mt7.iodp] == iodp)  & ...
          svdata.auth_pass([svdata.mt7.msg_idx])');
mdx10 = find(([mt10.msg.time] >= (time - MOPS_MT10_PATIMEOUT)) & ...
          svdata.auth_pass([mt10.msg.msg_idx])');
if ~isempty(mdx1)  && ~isempty(mdx7)  && ~isempty(mdx10)
    mdx1 = mdx1(1); %use the most recent one
    mdx7 = mdx7(1); %use the most recent one
    mdx10 = mdx10(1); %use the most recent one

    % See if MT 28 is required
    mdx28 = find(~isnan([svdata.mt28.time]) & ...
                     svdata.auth_pass([svdata.mt28.msg_idx])');
    if any(mdx28) && any([svdata.mt28(mdx28).time] >= (time - MOPS_MT28_PATIMEOUT))
        apply_mt28 = true;
    else
        apply_mt28 = false;
    end

    % find MT 6 IODFs
    mt6_iodf = [svdata.mt6.iodf];

    for sdx = 1:max_sats

        fc_timeout = MOPS_MT7_FCTIMEOUT(svdata.mt7(mdx7).ai(sdx)+1);

        %Must have valid Fast Correction messages
        mdx2345 = find(([svdata.mt2345(sdx,:).time] >= (time - 2*fc_timeout)) & ...
            ([svdata.mt2345(sdx,:).iodp] == iodp) & ...
            svdata.auth_pass([svdata.mt2345(sdx,:).msg_idx])');

        %Must have valid Long-Term Correction messages
        mdx25 = find(([svdata.mt25(sdx,:).time] >= (time - MOPS_MT25_PATIMEOUT)) & ...
            ([svdata.mt25(sdx,:).iodp] == iodp) & ...
            svdata.auth_pass([svdata.mt25(sdx,:).msg_idx])');
        
        %May need valid Clock/Ephemeris Covariance messages
        if apply_mt28
            mdx28 = find(([svdata.mt28(sdx,:).time] >= (time - MOPS_MT28_PATIMEOUT)) & ...
                ([svdata.mt28(sdx,:).iodp] == iodp) & ...
                svdata.auth_pass([svdata.mt28(sdx,:).msg_idx])');
        end

        %check that all required messages are present
        if length(mdx2345) > 1 && ...
              svdata.mt2345(sdx,mdx2345(1)).time >= (time - fc_timeout) && ...
              ~isempty(mdx25) && (~apply_mt28 || ~isempty(mdx28))

            eps_rrc_deg  = 0.0;
            eps_ltc_deg  = 0.0;

            %find the time since the most recent fast correction (fc)
            dtfc = time - svdata.mt2345(sdx,mdx2345(1)).time;

            %find the time for the fast correction degradation
            dtu = dtfc;

            %find the most recent UDREI
            tudrei = dtfc; 
            svdata.udrei(sdx) = svdata.mt2345(sdx,mdx2345(1)).udrei;

            %Look for valid MT 6 messages with matching iodf
            mdx6 = find(([svdata.mt6.time] >= (time - MOPS_UDRE_PATIMEOUT)) & ...
                (mt6_iodf(sdx,:) == svdata.mt2345(sdx,mdx2345(1)).iodf) & ...
                svdata.auth_pass([svdata.mt6.msg_idx])');            

            if ~isempty(mdx6) && svdata.mt6(mdx6(1)).time - svdata.mt2345(sdx,mdx2345(1)).time > 0
                tudrei = time - svdata.mt6(mdx6(1)).time; 
                svdata.udrei(sdx) = svdata.mt6(mdx6(1)).udrei(sdx);
                dtu = tudrei;
            end

            %Look for valid MT 6 messages with iodf = 3
            mdx6 = find(([svdata.mt6.time] >= (time - MOPS_UDRE_PATIMEOUT)) & ...
                (mt6_iodf(sdx,:) == 3) & svdata.auth_pass([svdata.mt6.msg_idx])');            

            if ~isempty(mdx6) && svdata.mt6(mdx6(1)).time - svdata.mt2345(sdx,mdx2345(1)).time > 0
                tudrei = time - svdata.mt6(mdx6(1)).time; 
                svdata.udrei(sdx) = svdata.mt6(mdx6(1)).udrei(sdx);
            end 

            %find the range rate correction (rrc)
            dtrrc = svdata.mt2345(sdx,mdx2345(1)).time - ...
                      svdata.mt2345(sdx,mdx2345(2)).time; %TODO optimize to find best choice
            dtrrc(isinf(dtrrc)) = NaN;
            rrc = (svdata.mt2345(sdx,mdx2345(1)).fc - svdata.mt2345(sdx,mdx2345(2)).fc)./dtrrc;
        
            %find the fast correction degradation
            eps_fc_deg = MOPS_MT7_AI(svdata.mt7(mdx7).ai(sdx)+1).*((dtfc + svdata.mt7(mdx7).t_lat).^2)/2;
            
            %find the rrc degradation 
            %look for non sequential IODFs
            if mod(svdata.mt2345(sdx,mdx2345(1)).iodf - svdata.mt2345(sdx,mdx2345(2)).iodf,3) ~= 1 && ...
                   ~isnan(dtrrc)
                eps_rrc_deg = (MOPS_MT7_AI(svdata.mt7(mdx7).ai(sdx)+1).*fc_timeout/4 + ...
                               mt10.msg(mdx10).brrc/dtrrc).*dtfc;
            end
        
            %look for IODFs equal to 3 and not at the expected interval
            if (svdata.mt2345(sdx,1).iodf == 3 || svdata.mt2345(sdx,2).iodf == 3) && ...
                   dtrrc ~= fc_timeout/2 && ~isnan(dtrrc)
                eps_rrc_deg = (MOPS_MT7_AI(svdata.mt7_ai(sdx)+1).*abs(dtrrc(sdx) - fc_timeout/2)/2 + ...
                               (e(sdx)*mt10.msg(mdx10).brrc)./dtrrc(sdx)).*dtfc(sdx);
            end
        
            %if ai from MT 7 is 0, the the rrc is 0
            if svdata.mt7(mdx7).ai(sdx) == 0
                rrc(sdx) = 0;
                dtrrc(sdx) = 0;
            end
        
            %find the time since the most recent long-term correction
            mdx25 = mdx25(1);
            dt25 = time - svdata.mt25(sdx,mdx25).time;
        
            %find the long-term corrections
            tmt0 = time - svdata.mt25(sdx,mdx25).t0;
            tmt0(isnan(tmt0)) = 0; %fix the velocity code 0 cases
            svdata.dxyzb(sdx,:) = svdata.mt25(sdx,mdx25).dxyzb + svdata.mt25(sdx,mdx25).dxyzb_dot.*tmt0;
        
            %add in the fast correction
            svdata.dxyzb(sdx,4) = svdata.dxyzb(sdx,4) + svdata.mt2345(sdx,mdx2345(1)).fc + rrc.*dtfc;
        
            %find the long-term correction degradation factor for velocity code = 1
            if (svdata.mt25(sdx,mdx25).t0 <= time || svdata.mt25(sdx,mdx25).t0 >= time + mt10.msg(mdx10).iltc_v1) && ...
                    ~isnan(svdata.mt25(sdx,mdx25).t0)
                eps_ltc_deg = mt10.msg(mdx10).cltc_lsb + mt10.msg(mdx10).cltc_v1*max([0 ...
                                (svdata.mt25(sdx,mdx25).t0 - time) ...
                                (time - svdata.mt25(sdx,mdx25).t0 - mt10.msg(mdx10).iltc_v1)]);
            %find the long-term correction degradation factor for velocity code = 0
            elseif isnan(svdata.mt25(sdx,mdx25).t0)
                eps_ltc_deg = mt10.msg(mdx10).cltc_v0*floor(dt25/mt10.msg(mdx10).iltc_v0);
            end
            % put in the ltc degradations for the GEOs
            if svdata.prns(sdx) >= MOPS_MIN_GEOPRN && ...
                    svdata.prns(sdx) <= MOPS_MAX_GEOPRN && ...
                    svdata.geo_prn == svdata.prns(sdx) && ...
                    svdata.mt1(mdx1).mask(svdata.prns(sdx))
                gdx = sum(svdata.mt1(mdx1).mask(MOPS_MIN_GEOPRN:svdata.prns(sdx)));
                if ~isnan(svdata.geo_deg(gdx))
                    eps_ltc_deg = svdata.geo_deg(gdx);
                end
            end    
        
            %only require MT 28 if there is an active one on any satellite
            if apply_mt28
                mdx28 = mdx28(1);
                mt28_iodp = svdata.mt28(sdx,mdx28).iodp;
                dt28 = time - svdata.mt28(sdx,mdx28).time;
                svdata.mt28_dCov(sdx,:) = svdata.mt28(sdx,mdx28).dCov;
                svdata.mt28_sc_exp(sdx) = svdata.mt28(sdx,mdx28).sc_exp;            
            else
                dt28 = 0.0;
                mt28_iodp = svdata.mt1(1).iodp;
                svdata.mt28_dCov(sdx,:) = [1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0];
                svdata.mt28_sc_exp(sdx) = 5;
            end
        
            %find the degradation term
            if mt10.msg(mdx10).rss_udre
                svdata.degradation(sdx) = eps_fc_deg.^2 + eps_rrc_deg.^2 + eps_ltc_deg.^2;
            else
                svdata.degradation(sdx) = eps_fc_deg + eps_rrc_deg + eps_ltc_deg;
            end
            %set the UDREs to NM for any SV with a timed out correction component
            % or whose iodps do not match and are not GEOs
            if (dtfc > fc_timeout  || tudrei > MOPS_UDRE_PATIMEOUT  || ...
                  dtrrc > fc_timeout  || dt25 > MOPS_MT25_PATIMEOUT || ...
                  dt28 > MOPS_MT28_PATIMEOUT || ...
                  svdata.mt2345(sdx,mdx2345(1)).iodp ~= svdata.mt1(mdx1).iodp || ...
                  svdata.mt25(sdx,mdx25).iodp ~= svdata.mt1(mdx1).iodp || ...
                  mt28_iodp ~= svdata.mt1(mdx1).iodp) && ...
                  (svdata.prns(sdx) < MOPS_MIN_GEOPRN || svdata.prns(sdx) > MOPS_MAX_GEOPRN)
    
                svdata.udrei(sdx) = MOPS_UDREI_NM;
                svdata.degradation(sdx) = NaN;
                svdata.dxyzb(sdx,:) = NaN;
            end
            %set the UDREs to NM for any SV with a timed out correction component
            % or whose iodps do not match and are GEOs
            if (dtfc > fc_timeout || tudrei > MOPS_UDRE_PATIMEOUT  || ...
                 dtrrc > fc_timeout  || dt28 > MOPS_MT28_PATIMEOUT || ...
                 svdata.mt2345(sdx,mdx2345(1)).iodp ~= svdata.mt1(mdx1).iodp || ...
                 mt28_iodp ~= svdata.mt1(mdx1).iodp || isnan(svdata.degradation(sdx))) && ...
                 (svdata.prns(sdx) >= MOPS_MIN_GEOPRN && svdata.prns(sdx) <= MOPS_MAX_GEOPRN)
                svdata.udrei(sdx)  = MOPS_UDREI_NM;
                svdata.degradation(sdx)  = NaN;
                svdata.dxyzb(sdx,:) = NaN;         
            end 
            % % if the active UDRE was DNU, then set the UDRE to DNU
            % if tudrei <= fc_timeout && (svdata.mt2345_udrei == MOPS_UDREI_DNU ...
            %                   || svdata.mt6_udrei == MOPS_UDREI_DNU)
            %    svdata.udrei(sdx)  = MOPS_UDREI_DNU;
            % end
        end
    end
end

%initialize final polygon data
svdata.mt27_polygon = [];

%Look for valid MT 27 messages
mdx27 = find(([svdata.mt27.time] >= (time - MOPS_MT27_PATIMEOUT)) & ...
          svdata.auth_pass([svdata.mt27.msg_idx])');
if ~isempty(mdx27)

%check for complete MT 27 set

    dt27 = time - [svdata.mt27(mdx27).time];
    % check for different IODSs, # of messages, and outside d_udre value
    mt27data = cell2mat({svdata.mt27(mdx27).msg_poly(1)});
    mt27sets = unique(mt27data(:,[1 2 6]),'rows');

    % loop over all sets and check if all polynomials are present
    for sdx = 1:size(mt27sets,1)
        idx = mt27data(:,1) == mt27sets(sdx,1) & ...
               mt27data(:,2) == mt27sets(sdx,2);
        eval_data = mt27data(idx,:);
        % have all messages been received
        if isequal(unique(eval_data(:,3)), 1:eval_data(1,2))
            %check for existing complete set
            if isempty(svdata.mt27_polygon)
                svdata.mt27_polygon = [svdata.mt27(mdx27(idx)).msg_poly];
                svdata.mt27_polytime = max([svdata.mt27(mdx27(idx)).time]);
                mean_age = mean(dt27(idx));
            elseif mean(dt27(idx)) < mean_age
                svdata.mt27_polygon = [svdata.mt27(mdx27(idx)).msg_poly];
                svdata.mt27_polytime = max([svdata.mt27(mdx27(idx)).time]);
                mean_age = mean(dt27(idx));
            end
        end
    end
end
