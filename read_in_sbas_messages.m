function [smtidx, svdata, ionodata, mt10, satdata, igpdata] = ...
             read_in_sbas_messages(time, sbas_msgs, sbas_msg_time, ...
                  smtidx, gprime, svdata, ionodata, mt10, satdata, ...
                  igpdata, mt26_to_igpdata)

global COL_SAT_PRN COL_SAT_XYZB COL_SAT_DXYZB COL_SAT_UDREI COL_SAT_DEGRAD 
global COL_SAT_COV COL_SAT_SCALEF
global COL_IGP_GIVEI COL_IGP_DEGRAD COL_IGP_DELAY

global MOPS_MIN_GPSPRN MOPS_MAX_GPSPRN

global MT27 

ngps = sum(satdata(:, COL_SAT_PRN) >= MOPS_MIN_GPSPRN & satdata(:, COL_SAT_PRN) <= MOPS_MAX_GPSPRN);
nsat = sum(satdata(:, COL_SAT_PRN) >0);
ngeo = nsat - ngps;
n_channels = size(svdata,2);
geoprns = satdata(ngps+(1:ngeo), COL_SAT_PRN);

% loop over the geo channels and read in the previously unread 
 %  messages up to the current time
for gdx = 1:n_channels
    while sbas_msg_time{gdx}(smtidx(gdx)) <= time
        msg = reshape(dec2bin(sbas_msgs{gdx}(smtidx(gdx),:),8)', 1,256);
        [svdata(gdx), ionodata(gdx), mt10(gdx), ~] = ...
            L1_decode_messages(sbas_msg_time{gdx}(smtidx(gdx)), ...
                      msg, svdata(gdx), ionodata(gdx), mt10(gdx));
        smtidx(gdx) = smtidx(gdx) + 1;
    end
end
%check the message data for timeouts and compute corrections and degradations
% check across all geos to obtain MT 9 positions
svdata = L1_decode_geocorr(time, svdata, mt10);
for gdx = 1:n_channels
    if svdata(gdx).geo_prn ~= geoprns(gdx) && isnan(svdata(gdx).geo_flags(4))
        warning('Mismatched prns - looking for %d and found %d\n', ...
                geoprns(gdx), svdata(gdx).geo_prn); %TODO may want to prevent continues use of this GEO correction data!!!!!!!!!!
        svdata(gdx).geo_flags(4) = false;
    elseif svdata(gdx).geo_prn == geoprns(gdx) && ~svdata(gdx).geo_flags(4)
        fprintf('GEO PRN %d confirmed on channel %d\n', geoprns(gdx), gdx);
        svdata(gdx).geo_flags(4) = true;
    end
end

% only check other data on the prime channel used for corrections
svdata(gprime)  = L1_decode_satcorr(time, svdata(gprime), mt10(gprime));
ionodata(gprime) = L1_decode_ionocorr(time, ionodata(gprime), mt10(gprime));

%transfer data to MAAST matrices
sdx = 1:nsat;
satdata(sdx, COL_SAT_DXYZB) = svdata(gprime).dxyzb(sdx,:);
satdata(sdx, COL_SAT_UDREI) = svdata(gprime).udrei(sdx);
satdata(sdx, COL_SAT_DEGRAD) = svdata(gprime).degradation(sdx);
if isempty(svdata(gprime).mt27_polygon)
    sdx = ~isnan(svdata(gprime).mt28_time);
    satdata(sdx, COL_SAT_COV) = svdata(gprime).mt28_dCov(sdx,:);
    satdata(sdx, COL_SAT_SCALEF) = 2.^(svdata(gprime).mt28_sc_exp(sdx) - 5);
else
    MT27 = svdata(gprime).mt27_polygon;
end
idx = ~isnan(svdata(gprime).geo_xyzb(1:ngeo,1));
gdx = ngps + (1:ngeo);
satdata(gdx(idx), COL_SAT_XYZB) = svdata(gprime).geo_xyzb(idx,:);

igpdata(:, COL_IGP_GIVEI) = ionodata(gprime).givei(mt26_to_igpdata);
igpdata(:, COL_IGP_DEGRAD) = ionodata(gprime).eps_iono(mt26_to_igpdata);
igpdata(:, COL_IGP_DELAY) = ionodata(gprime).mt26_Iv(mt26_to_igpdata);