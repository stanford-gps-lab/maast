function svdata = L1_decode_satcorr(time, svdata, mt10)
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
%          L1_DECODEMT0 L1_DECODEMT1 L1_DECODEMT2345 L1_DECODEMT6 
%          L1_DECODEMT7 L1_DECODEMT9  L1_DECODEMT10 L1_DECODEMT17 
%          L1_DECODEMT24 L1_DECODEMT25 L1_DECODEMT28
%
% !!NOTE THAT MT 6 IS ONLY ENCODED AS AN ALERT MESSAGE AND THIS FUNCTION
%     CANNOT HANDLE INTERLEAVED MT 6 AND FC MESSAGES

%Created March 29, 2020 by Todd Walter

global MOPS_UDREI_NM
global MOPS_MIN_GEOPRN MOPS_MAX_GEOPRN
global MOPS_MT1_PATIMEOUT MOPS_MT2_PATIMEOUT MOPS_MT7_PATIMEOUT 
global MOPS_MT10_PATIMEOUT MOPS_MT25_PATIMEOUT MOPS_MT27_PATIMEOUT 
global MOPS_MT28_PATIMEOUT
global MOPS_MT7_AI

max_sats = size(svdata.mt2_udrei,1);

%Initialize satellite correction data
svdata.dxyzb  = NaN(max_sats, 4); 
svdata.udrei  = repmat(MOPS_UDREI_NM, max_sats, 1);
svdata.degradation  = NaN(max_sats, 1);

%Must have valid MT 1, 7, & 10 messages in order to have valid corrections
if (svdata.mt1_time >= (time - MOPS_MT1_PATIMEOUT)) && ...
        (svdata.mt7_time >= (time - MOPS_MT7_PATIMEOUT)) && ...
        (svdata.mt1_iodp == svdata.mt7_iodp) && ...
        (mt10.time >= (time - MOPS_MT10_PATIMEOUT))

    eps_rrc_deg  = zeros(max_sats, 1);
    eps_ltc_deg  = zeros(max_sats, 1);
    
    %find the most recent UDREI
    tudrei = time - svdata.mt2_fc_time(:,1); 
    svdata.udrei = svdata.mt2_udrei;
    
    idx = svdata.mt6_time - svdata.mt2_fc_time(:,1) > 0;
    if any(idx)
        tudrei(idx) = time - svdata.mt6_time; 
        svdata.udrei(idx) = svdata.mt6_udrei(idx);
    end
        
    %find the time since the most recent fast correction (fc)
    dtfc = time - svdata.mt2_fc_time(:,1);
    
    %find the range rate correction (rrc)
    dtrrc = svdata.mt2_fc_time(:,1) - svdata.mt2_fc_time(:,2); %TODO optimize to find best choice
    rrc = (svdata.mt2_fc(:,1) - svdata.mt2_fc(:,2))./dtrrc;
    
    %find the fast correction degradation
    eps_fc_deg = MOPS_MT7_AI(svdata.mt7_ai+1).*((dtfc + svdata.mt7_t_lat).^2)/2;
    
    %find the rrc degradation 
    %look for non sequential IODFs
    e = ones(size(svdata.mt7_ai));
    idx = mod(svdata.mt2_fc_iodf(:,1) - svdata.mt2_fc_iodf(:,2),3) ~= 1 & ...
           ~isnan(dtrrc);
    if any(idx)
        eps_rrc_deg(idx) = (MOPS_MT7_AI(svdata.mt7_ai(idx)+1)*MOPS_MT2_PATIMEOUT/4 + ...
                       (e(idx)*mt10.brrc)./dtrrc(idx)).*dtfc(idx);
    end
    
    %look for IODFs equal to 3 and not at the expected interval
    idx = (svdata.mt2_fc_iodf(:,1) == 3 | svdata.mt2_fc_iodf(:,2) == 3 | ...
           dtrrc ~= MOPS_MT2_PATIMEOUT/2) & ~isnan(dtrrc);
    if any(idx)
        eps_rrc_deg(idx) = (MOPS_MT7_AI(svdata.mt7_ai(idx)+1).*abs(dtrrc(idx) - MOPS_MT2_PATIMEOUT/2)/2 + ...
                       (e(idx)*mt10.brrc)./dtrrc(idx)).*dtfc(idx);
    end
    
    %if ai from MT 7 is 0, the the rrc is 0
    idx = svdata.mt7_ai == 0;
    if any(idx)
        rrc(idx) = 0;
        dtrrc(idx) = 0;
    end
    
    %find the time since the most recent long-term correction
    dt25 = time - svdata.mt25_time;
    
    %find the long-term corrections
    tmt0 = time - svdata.mt25_t0;
    tmt0(isnan(tmt0)) = 0; %fix the velocity code 0 cases
    svdata.dxyzb = svdata.mt25_dxyzb + svdata.mt25_dxyzb_dot.*tmt0;
    
    %add in the fast correction
    svdata.dxyzb(:,4) = svdata.dxyzb(:,4) + svdata.mt2_fc(:,1) + rrc.*dtfc;
    
    %find the long-term correction degradation factor for velocity code = 1
    idx = (svdata.mt25_t0 <= time | svdata.mt25_t0 >= time + mt10.iltc_v1) & ...
            ~isnan(svdata.mt25_t0);
    if any(idx)
        eps_ltc_deg(idx) = mt10.cltc_lsb + mt10.cltc_v1*max([ ...
                         zeros(size(svdata.mt25_t0(idx))) ...
                        (svdata.mt25_t0(idx) - time) ...
                        (time - svdata.mt25_t0(idx) - mt10.iltc_v1)],[],2);
    end
    %find the long-term correction degradation factor for velocity code = 0
    idx = isnan(svdata.mt25_t0);
    if any(idx)
        eps_ltc_deg(idx) = mt10.cltc_v0*floor(dt25(idx)/mt10.iltc_v0);
    end
    % put in the ltc degradations for the GEOs
    idx = ~isnan(svdata.geo_deg);
    if any(idx) && svdata.mt1_ngeo
        k = svdata.mt1_ngps + svdata.mt1_nglo + (1:svdata.mt1_ngeo);
        idx = idx(1:svdata.mt1_ngeo);
        eps_ltc_deg(k(idx)) = svdata.geo_deg(idx);
    end    
    
    %find the time since the most recent MT 28 covariance matrix
    dt28 = time - svdata.mt28_time;
    
    %only require MT 28 if there is an active one on any satellite
    if any(dt28 <= MOPS_MT28_PATIMEOUT)
        mt28_iodp = svdata.mt28_iodp;
    else
        dt28 = dt28*0;
        mt28_iodp = ones(size(svdata.mt28_iodp))*svdata.mt1_iodp;
    end
    
    %find the degradation term
    if mt10.rss_udre
        svdata.degradation = eps_fc_deg.^2 + eps_rrc_deg.^2 + eps_ltc_deg.^2;
    else
        svdata.degradation = eps_fc_deg + eps_rrc_deg + eps_ltc_deg;
    end
    %set the UDREs to NM for any SV with a timed out correction component
    % or whose iodps do not match and are not GEOs
    idx = (tudrei > MOPS_MT2_PATIMEOUT  | dtfc > MOPS_MT2_PATIMEOUT  | ...
            dtrrc > MOPS_MT2_PATIMEOUT  | dt25 > MOPS_MT25_PATIMEOUT | ...
             dt28 > MOPS_MT28_PATIMEOUT | ...
             svdata.mt2_fc_iodp ~= svdata.mt1_iodp | ...
             svdata.mt25_iodp ~= svdata.mt1_iodp | ...
             mt28_iodp ~= svdata.mt1_iodp) & ...
             (svdata.prns < MOPS_MIN_GEOPRN | svdata.prns > MOPS_MAX_GEOPRN);
     if any(idx)
         svdata.udrei(idx)  = MOPS_UDREI_NM;
         svdata.degradation(idx)  = NaN;
     end
    %set the UDREs to NM for any SV with a timed out correction component
    % or whose iodps do not match and are GEOs
    idx = (tudrei > MOPS_MT2_PATIMEOUT  | dtfc > MOPS_MT2_PATIMEOUT  | ...
            dtrrc > MOPS_MT2_PATIMEOUT  | dt28 > MOPS_MT28_PATIMEOUT | ...
             svdata.mt2_fc_iodp ~= svdata.mt1_iodp | ...
             mt28_iodp ~= svdata.mt1_iodp | isnan(svdata.degradation)) & ...
             (svdata.prns >= MOPS_MIN_GEOPRN & svdata.prns <= MOPS_MAX_GEOPRN);
     if any(idx)
         svdata.udrei(idx)  = MOPS_UDREI_NM;
         svdata.degradation(idx)  = NaN;
     end     
end

%remove MT 27 messages that have timed out
if isnan(svdata.mt27_polytime) || ...
          time - svdata.mt27_polytime > MOPS_MT27_PATIMEOUT
    svdata.mt27_polygon = [];
end    