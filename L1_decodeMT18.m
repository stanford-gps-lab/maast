function igpdata = L1_decodeMT18(time, msg, igpdata)
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
% Decodes Message Type 18 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

bandid = bin2dec(msg(19:22)) + 1;

igpdata.mt18_num_bands(bandid) = bin2dec(msg(15:18));
igpdata.mt18_iodi(bandid) = bin2dec(msg(23:24));
igpdata.mt18_mask(bandid,:) = cast(bin2dec(msg(25:225)'), 'uint8')';

igpdata.mt18_time(bandid) = time;
