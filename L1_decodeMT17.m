function svdata = L1_decodeMT17(time, msg, svdata)
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
% Decodes Message Type 17 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter



t0 = bin2dec(msg(216:226))*64 + floor(time/86400)*86400; %t0
if t0 - time < -43200 %adjust for day rollover
    t0 = t0 + 86400;
elseif t0 - time > 43200
    t0 = t0 - 86400;
end        

idx = 15;
for jdx = 1:3
    id = bin2dec(msg(idx:idx+1)); % Data ID
    idx = idx+2;
    prn = bin2dec(msg(idx:idx+7)); % PRN
    idx = idx+8;
    if prn
        gdx = prn - 119; %GEO PRNS run from 120 to 159
        
        % copy older messages over
        svdata.mt17(gdx,2:end) = svdata.mt17(gdx,1:(end-1));

        svdata.mt17(gdx,1).prn = prn; % PRN
        svdata.mt17(gdx,1).health = bin2dec(msg(idx:idx+7)); % Health & Status
        idx = idx+8;   
        svdata.mt17(gdx,1).xyz(1) = twos2dec(msg(idx:idx+14))*2600; %X_G
        idx = idx+15;   
        svdata.mt17(gdx,1).xyz(2) = twos2dec(msg(idx:idx+14))*2600; %Y_G
        idx = idx+15;   
        svdata.mt17(gdx,1).xyz(3) = twos2dec(msg(idx:idx+8))*26000; %Z_G
        idx = idx+9;   
        svdata.mt17(gdx,1).xyz_dot(1) = twos2dec(msg(idx:idx+2))*10; %X_dot_G
        idx = idx+3;     
        svdata.mt17(gdx,1).xyz_dot(2) = twos2dec(msg(idx:idx+2))*10; %X_dot_G
        idx = idx+3;       
        svdata.mt17(gdx,1).xyz_dot(3) = twos2dec(msg(idx:idx+3))*60; %Z_dot_G
        idx = idx+4;   
        svdata.mt17(gdx,1).t0 = t0;
        svdata.mt17(gdx,1).time = time;
        svdata.mt17(gdx,1).msg_idx = mod(round(time), 700) + 1;
    else
        idx = idx+56;
    end
end