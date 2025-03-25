function igpdata = L1_decodeMT26(time, msg, igpdata)
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
% Decodes Message Type 26 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

global MOPS_GIVEI_NM

max_igps = 201;

bandid = bin2dec(msg(15:18)); 
kdx = bin2dec(msg(19:22))*15 + 1;  %convert from MOPS 0-13 to matlab 1-14
iodi = bin2dec(msg(218:219));

% copy older messages over
igpdata.mt26(bandid*max_igps + kdx + (0:14), 2:end) = ...
    igpdata.mt26(bandid*max_igps + kdx + (0:14), 1:(end-1));

idx = 23;
for sdx = 0:14
    if strcmp(msg(idx:(idx+8)), '111111111') % Special code indicates do not use
        igpdata.mt26(bandid*max_igps + kdx + sdx,1).Iv = NaN;
        igpdata.mt26(bandid*max_igps + kdx + sdx,1).givei = MOPS_GIVEI_NM;
        idx = idx + 13;
    else
        igpdata.mt26(bandid*max_igps + kdx + sdx,1).Iv = bin2dec(msg(idx:(idx+8)))*0.125;
        idx = idx + 9;
        igpdata.mt26(bandid*max_igps + kdx + sdx,1).givei = bin2dec(msg(idx:(idx+3))) + 1; %convert from MOPS 0-15 to matlab 1-16
        idx = idx + 4;
        igpdata.mt26(bandid*max_igps + kdx + sdx,1).iodi = iodi;
    end
    igpdata.mt26(bandid*max_igps + kdx + sdx,1).time = time;    
    igpdata.mt26(bandid*max_igps + kdx + sdx,1).msg_idx = mod(round(time), 700) + 1; 
end

