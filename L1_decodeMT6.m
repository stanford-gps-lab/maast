function svdata = L1_decodeMT6(time, msg, svdata)
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
% Decodes Message Type 6 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

svdata.mt6_iodf(1:13) = bin2dec(msg(15:16));  %IODF for MT2
svdata.mt6_iodf(14:26) = bin2dec(msg(17:18));  %IODF for MT3
svdata.mt6_iodf(27:39) = bin2dec(msg(19:20));  %IODF for MT4
svdata.mt6_iodf(40:51) = bin2dec(msg(21:22));  %IODF for MT5

idx = 23;
for jdx = 1:51
    svdata.mt6_udrei(jdx) = bin2dec(msg(idx:(idx+3))) + 1; %convert from MOPS 0-15 to matlab 1-16
    idx = idx + 4;
end

svdata.mt6_time = time;