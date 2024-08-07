function svdata = L5_decodeMT36(time, msg, svdata)
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
svdata.mt36(2:end) = svdata.mt36(1:(end-1));

%read in DFREIs
idx = 11;
for jdx = 54:92
    svdata.mt36(1).dfrei(jdx-53) = bin2dec(msg(idx:(idx+3))) + 1; %convert from MOPS 0-15 to matlab 1-16
    idx = idx + 4;
end

% skip spare and reserve bits
idx = idx + 58;

%read in IODM
svdata.mt36(1).iodm = bin2dec(msg(idx:(idx+1)));

svdata.mt36(1).time = time;

svdata.mt36(1).msg_idx = mod(round(time), 700) + 1;