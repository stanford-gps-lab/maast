function svdata = L5_decodeMT34(time, msg, svdata)
%*************************************************************************
%*     Copyright c 2022 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% Decodes Message Type 36 
%   per ED-259A
%
% SEE ALSO: L5_decode_messages

%created 23 October, 2022 by Todd Walter

% copy older messages over
svdata.mt34(2:end) = svdata.mt34(1:(end-1));

%read in DFRECIs
idx = 11;
for jdx = 1:92
    svdata.mt34(1).dfreci(jdx-53) = bin2dec(msg(idx:(idx+1))) + 1; %convert from MOPS 0-15 to matlab 1-16
    idx = idx + 2;
end
for jdx = 1:7
    svdata.mt34(1).dfrei(jdx-53) = bin2dec(msg(idx:(idx+3))) + 1; %convert from MOPS 0-15 to matlab 1-16
    idx = idx + 4;
end
% skip reserve bits
idx = idx + 2;

%read in IODM
svdata.mt34(1).iodm = bin2dec(msg(idx:(idx+1)));

svdata.mt34(1).time = time;

svdata.mt34(1).msg_idx = mod(round(time), 700) + 1;