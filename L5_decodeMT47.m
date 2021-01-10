function svdata = L5_decodeMT47(time, msg, svdata)
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
% Decodes Message Type 47 
%   per ED-259E
%
% SEE ALSO: L5_decode_messages

%created 31 December, 2020 by Todd Walter

idx = 11;
for jdx = 1:2
    gdx = bin2dec(msg(idx:idx+5)); % satellite slot delta
    idx = idx+6;
    if gdx
        svdata.mt47alm(gdx).prn = gdx + 119; % PRN (GEO PRNS run from 120 to 159)
        svdata.mt47alm(gdx).spid = bin2dec(msg(idx:idx+4)); % SBAS Provider ID
        idx = idx+5;   
        svdata.mt47alm(gdx).brid = bin2dec(msg(idx:idx)); % Broadcast indicator
        idx = idx+1;  
        svdata.mt47alm(gdx).a = bin2dec(msg(idx:idx+15))*650.0 + 6370000.0; % Semi-major axis
        idx = idx+16;   
        svdata.mt47alm(gdx).e = bin2dec(msg(idx:idx+7))*(2^-8); % Eccentricity
        idx = idx+8;  
        svdata.mt47alm(gdx).i = bin2dec(msg(idx:idx+12))*pi*(2^-13); % Inclination
        idx = idx+13;  
        svdata.mt47alm(gdx).omega = twos2dec(msg(idx:idx+13))*pi*(2^-13); % Argument of perigee
        idx = idx+14;   
        svdata.mt47alm(gdx).lan = twos2dec(msg(idx:idx+13))*pi*(2^-13); % Longitude of ascending node
        idx = idx+14;           
        svdata.mt47alm(gdx).lan_dot = twos2dec(msg(idx:idx+7))*(1e-9); % Rate of right ascension
        idx = idx+8;           
        svdata.mt47alm(gdx).M0 = twos2dec(msg(idx:idx+15))*pi*(2^-14); % Mean anomaly at ta
        idx = idx+15;           
        t0 = bin2dec(msg(idx:idx+5))*1800.0 + floor(time/86400.0)*86400.0; %ta
        idx = idx+6;           
        if t0 - time < -43200 %adjust for day rollover
            t0 = t0 + 86400;
        elseif t0 - time > 43200
            t0 = t0 - 86400;
        end        
        svdata.mt47alm(gdx).ta = t0;    
        svdata.mt47alm(gdx).time = time;
        svdata.mt47alm(gdx).msg_idx = mod(round(time), 700) + 1;
    else
        idx = idx+106;
    end
end
svdata.mt47_wnrocount = bin2dec(msg(223:226)); % Week number rollover count