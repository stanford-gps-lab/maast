function svdata = L5_decodeMT35(time, msg, svdata)
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
% Decodes Message Type 35 
%   per ED-259A
%
% SEE ALSO: L5_decode_messages

%created 28 December, 2020 by Todd Walter

%read in DFREIs
idx = 11;
for jdx = 1:53
    svdata.mt35_dfrei(jdx) = bin2dec(msg(idx:(idx+3))) + 1; %convert from MOPS 0-15 to matlab 1-16
    idx = idx + 4;
end

% skip two reserve bits
idx = idx + 2;

%read in IODM
svdata.mt35_iodm = bin2dec(msg(idx:(idx+3)));

svdata.mt35_time = time;