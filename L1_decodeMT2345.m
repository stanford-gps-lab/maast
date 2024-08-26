function svdata = L1_decodeMT2345(time, msg, svdata)
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
% Decodes Message Types 2, 3, 4, & 5 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

mtype = bin2dec(msg(9:14));
jdx = (mtype - 2)*13 + 1;

if mtype == 5
    max_sdx = 11;
else
    max_sdx = 12;
end

% copy older messages over
svdata.mt2345(jdx:min([jdx+12 51]),2:end) = svdata.mt2345(jdx:min([jdx+12 51]),1:(end-1));

iodf = bin2dec(msg(15:16));
iodp = bin2dec(msg(17:18));
idx = 18;
for sdx = 0:max_sdx
    svdata.mt2345(jdx + sdx,1).time = time;
    svdata.mt2345(jdx + sdx,1).msg_idx = mod(round(time), 700) + 1;
    svdata.mt2345(jdx + sdx,1).iodf = iodf;
    svdata.mt2345(jdx + sdx,1).iodp = iodp;
    svdata.mt2345(jdx + sdx,1).fc = twos2dec(msg((idx + 1):(idx + 12)))*0.125;
    idx = idx + 12;
end
idx = 174;
for sdx = 0:max_sdx
    svdata.mt2345(jdx + sdx,1).udrei = bin2dec(msg((idx + 1):(idx + 4))) + 1; %convert from MOPS 0-15 to matlab 1-16
    idx = idx + 4;
end

