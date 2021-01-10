function [smtidx, svdata, satdata] = ...
             read_in_sbas_L5messages(time, sbas_msgs, sbas_msg_time, ...
                  smtidx, gprime, svdata, satdata)
%*************************************************************************
%*     Copyright c 2021 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************

global COL_SAT_PRN COL_SAT_XYZB COL_SAT_DXYZB COL_SAT_UDREI COL_SAT_DEGRAD 
global COL_SAT_COV COL_SAT_SCALEF

global L5MOPS_MIN_GPSPRN L5MOPS_MAX_GPSPRN

ngps = sum(satdata(:, COL_SAT_PRN) >= L5MOPS_MIN_GPSPRN & satdata(:, COL_SAT_PRN) <= L5MOPS_MAX_GPSPRN);
nsat = sum(satdata(:, COL_SAT_PRN) > 0);
ngeo = nsat - ngps;
n_channels = size(svdata,2);
geoprns = satdata(ngps+(1:ngeo), COL_SAT_PRN);

% loop over the geo channels and read in the previously unread 
 %  messages up to the current time
for gdx = 1:n_channels
    while sbas_msg_time{gdx}(smtidx(gdx)) <= time
        msg = reshape(dec2bin(sbas_msgs{gdx}(smtidx(gdx),:),8)', 1,256);
        svdata(gdx) = L5_decode_messages(sbas_msg_time{gdx}(smtidx(gdx)), ...
                      msg, svdata(gdx));
        smtidx(gdx) = smtidx(gdx) + 1;
    end
end
%check the message data for timeouts and compute corrections and degradations
% check across all geos to obtain MT 39/40 positions
svdata = L5_decode_geocorr(time, svdata);
for gdx = 1:n_channels
    if svdata(gdx).geo_prn ~= geoprns(gdx)
        warning('Mismatched prns - looking for %d and found %d\n', ...
                geoprns(gdx), svdata(gdx).geo_prn); %TODO may want to prevent continues use of this GEO correction data!!!!!!!!!!
    end
end

% only check other data on the prime channel used for corrections
svdata(gprime)  = L5_decode_satcorr(time, svdata(gprime));

%transfer data to MAAST matrices
sdx = 1:nsat;
satdata(sdx, COL_SAT_DXYZB) = svdata(gprime).dxyzb(satdata(sdx, COL_SAT_PRN),:);
satdata(sdx, COL_SAT_UDREI) = svdata(gprime).dfrei(satdata(sdx, COL_SAT_PRN));
satdata(sdx, COL_SAT_DEGRAD) = svdata(gprime).degradation(satdata(sdx, COL_SAT_PRN));
satdata(sdx, COL_SAT_COV) = svdata(gprime).dCov(satdata(sdx, COL_SAT_PRN),:);
satdata(sdx, COL_SAT_SCALEF) = svdata(gprime).dCov_sf(satdata(sdx, COL_SAT_PRN),:);

idx = ~isnan(svdata(gprime).geo_xyzb(1:ngeo,1));
gdx = ngps + (1:ngeo);
satdata(gdx(idx), COL_SAT_XYZB) = svdata(gprime).geo_xyzb(idx,:);