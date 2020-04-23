function svdata = L1_decodeMT7(time, msg, svdata)
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
% Decodes Message Type 7 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

svdata.mt7_t_lat = bin2dec(msg(15:18));
svdata.mt7_iodp = bin2dec(msg(19:20));
idx = 22;
for jdx = 1:51
    svdata.mt7_ai(jdx) = bin2dec(msg((idx + 1):(idx + 4)));
    idx = idx + 4;
end

svdata.mt7_time = time;
