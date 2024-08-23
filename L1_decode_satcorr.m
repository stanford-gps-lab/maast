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

%Must have valid MT 1, 7, & 10 messages in order to have valid corrections
if (svdata.mt1(1).time >= (time - MOPS_MT1_PATIMEOUT)) && ...
        (svdata.mt7(1).time >= (time - MOPS_MT7_PATIMEOUT)) && ...
        (svdata.mt1(1).iodp == svdata.mt7(1).iodp) && ...
        (mt10.time >= (time - MOPS_MT10_PATIMEOUT))

    eps_rrc_deg  = 0.0;
    eps_ltc_deg  = 0.0;

    for sdx = 1:max_sats
        %find the most recent UDREI
        tudrei = time - svdata.mt2345(sdx,1).time; 
        svdata.udrei(sdx) = svdata.mt2345(sdx,1).udrei;
    
        if svdata.mt6(1).time - svdata.mt2345(sdx,1).time > 0
            tudrei = time - svdata.mt6_time; 
            svdata.udrei(sdx) = svdata.mt6_udrei(sdx);
        end
    
        %find the time since the most recent fast correction (fc)
        dtfc = time - svdata.mt2345(sdx,1).time;
    
        %find the range rate correction (rrc)
        dtrrc = svdata.mt2345(sdx,1).time - svdata.mt2345(sdx,2).time; %TODO optimize to find best choice
        dtrrc(isinf(dtrrc)) = NaN;
        rrc = (svdata.mt2345(sdx,1).fc - svdata.mt2345(sdx,2).fc)./dtrrc;
    
        %find the fast correction degradation
        eps_fc_deg = MOPS_MT7_AI(svdata.mt7(1).ai(sdx)+1).*((dtfc + svdata.mt7(1).t_lat).^2)/2;
        fc_timeout = MOPS_MT7_FCTIMEOUT(svdata.mt7(1).ai(sdx)+1);
        
        %find the rrc degradation 
        %look for non sequential IODFs
        if mod(svdata.mt2345(sdx,1).iodf - svdata.mt2345(sdx,2).iodf,3) ~= 1 && ...
               ~isnan(dtrrc)
            eps_rrc_deg = (MOPS_MT7_AI(svdata.mt7(1).ai(sdx)+1).*fc_timeout(sdx)/4 + ...
                           mt10.brrc/dtrrc).*dtfc;
        end
    
        %look for IODFs equal to 3 and not at the expected interval
        if (svdata.mt2345(sdx,1).iodf == 3 || svdata.mt2345(sdx,2).iodf == 3) && ...
               dtrrc ~= fc_timeout/2 && ~isnan(dtrrc)
            eps_rrc_deg = (MOPS_MT7_AI(svdata.mt7_ai(sdx)+1).*abs(dtrrc(sdx) - fc_timeout(sdx)/2)/2 + ...
                           (e(sdx)*mt10.brrc)./dtrrc(sdx)).*dtfc(sdx);
        end
    
        %if ai from MT 7 is 0, the the rrc is 0
        if svdata.mt7(1).ai(sdx) == 0
            rrc(sdx) = 0;
            dtrrc(sdx) = 0;
        end
    
        %find the time since the most recent long-term correction
        dt25 = time - svdata.mt25(sdx,1).time;
    
        %find the long-term corrections
        tmt0 = time - svdata.mt25(sdx,1).t0;
        tmt0(isnan(tmt0)) = 0; %fix the velocity code 0 cases
        svdata.dxyzb(sdx,:) = svdata.mt25(sdx,1).dxyzb + svdata.mt25(sdx,1).dxyzb_dot.*tmt0;
    
        %add in the fast correction
        svdata.dxyzb(sdx,4) = svdata.dxyzb(sdx,4) + svdata.mt2345(sdx,1).fc + rrc.*dtfc;
    
        %find the long-term correction degradation factor for velocity code = 1
        if (svdata.mt25(sdx,1).t0 <= time || svdata.mt25(sdx,1).t0 >= time + mt10.iltc_v1) && ...
                ~isnan(svdata.mt25(sdx,1).t0)
            eps_ltc_deg = mt10.cltc_lsb + mt10.cltc_v1*max([0 ...
                            (svdata.mt25(sdx,1).t0 - time) ...
                            (time - svdata.mt25(sdx,1).t0 - mt10.iltc_v1)]);
        %find the long-term correction degradation factor for velocity code = 0
        elseif isnan(svdata.mt25(sdx,1).t0)
            eps_ltc_deg = mt10.cltc_v0*floor(dt25/mt10.iltc_v0);
        end
        gdx  = 1;
        % put in the ltc degradations for the GEOs
        if svdata.prns(sdx) >= MOPS_MIN_GEOPRN && ...
                svdata.prns(sdx) <= MOPS_MAX_GEOPRN && ...
                svdata.mt1(1).ngeo > 1 && svdata.geo_prn ~= svdata.prns(sdx) && ...
                svdata.mt1(1).mask(svdata.prns(sdx))
            gdx = sum(svdata.mt1(1).mask(MOPS_MIN_GEOPRN:svdata.prns(sdx)));
            if ~isnan(svdata.geo_deg(gdx))
                eps_ltc_deg = svdata.geo_deg(gdx);
            end
        end    
    
        %only require MT 28 if there is an active one on any satellite
        if time - svdata.mt28_time <= MOPS_MT28_PATIMEOUT
            mt28_iodp = svdata.mt28(sdx,1).iodp;
            dt28 = time - svdata.mt28(sdx,1).time;
            svdata.mt28_dCov(sdx,:) = svdata.mt28(sdx,1).dCov;
            svdata.mt28_sc_exp(sdx) = svdata.mt28(sdx,1).sc_exp;            
        else
            dt28 = 0.0;
            mt28_iodp = svdata.mt1(1).iodp;
            svdata.mt28_dCov(sdx,:) = [1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0];
            svdata.mt28_sc_exp(sdx) = 5;
        end
    
        %find the degradation term
        if mt10.rss_udre
            svdata.degradation(sdx) = eps_fc_deg.^2 + eps_rrc_deg.^2 + eps_ltc_deg.^2;
        else
            svdata.degradation(sdx) = eps_fc_deg + eps_rrc_deg + eps_ltc_deg;
        end
        %set the UDREs to NM for any SV with a timed out correction component
        % or whose iodps do not match and are not GEOs
        if (dtfc > fc_timeout  || tudrei > MOPS_UDRE_PATIMEOUT  || ...
              dtrrc > fc_timeout  || dt25 > MOPS_MT25_PATIMEOUT || ...
              dt28 > MOPS_MT28_PATIMEOUT || ...
              svdata.mt2345(sdx,1).iodp ~= svdata.mt1(1).iodp || ...
              svdata.mt25(sdx,1).iodp ~= svdata.mt1(1).iodp || ...
              mt28_iodp ~= svdata.mt1(1).iodp) && ...
              (svdata.prns(sdx) < MOPS_MIN_GEOPRN || svdata.prns(sdx) > MOPS_MAX_GEOPRN)

            svdata.udrei(sdx) = MOPS_UDREI_NM;
            svdata.degradation(sdx) = NaN;
            svdata.dxyzb(sdx,:) = NaN;
        end
        %set the UDREs to NM for any SV with a timed out correction component
        % or whose iodps do not match and are GEOs
        if (dtfc > fc_timeout || tudrei > MOPS_UDRE_PATIMEOUT  || ...
             dtrrc > fc_timeout  || dt28 > MOPS_MT28_PATIMEOUT || ...
             svdata.mt2345(sdx,1).iodp ~= svdata.mt1(1).iodp || ...
             mt28_iodp ~= svdata.mt1(1).iodp || isnan(svdata.degradation(sdx))) && ...
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
%remove MT 27 messages that have timed out
if isnan(svdata.mt27(1).polytime) || ...
          time - svdata.mt27(1).polytime > MOPS_MT27_PATIMEOUT
    svdata.mt27(1).polygon = [];
end    