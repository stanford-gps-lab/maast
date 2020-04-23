function mt10 = L1_decodeMT10(time, msg)
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
% Decodes Message Type 10 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

mt10.brrc = bin2dec(msg(15:24))*0.002;
mt10.cltc_lsb = bin2dec(msg(25:34))*0.002;
mt10.cltc_v1 = bin2dec(msg(35:44))*0.00005;
mt10.iltc_v1 = bin2dec(msg(45:53));
mt10.cltc_v0 = bin2dec(msg(54:63))*0.002;
mt10.iltc_v0 = bin2dec(msg(64:72));
mt10.cgeo_lsb = bin2dec(msg(73:82))*0.0005;
mt10.cgeo_v = bin2dec(msg(83:92))*0.00005;
mt10.igeo = bin2dec(msg(93:101));
mt10.cer = bin2dec(msg(102:107))*0.5;
mt10.ciono_step = bin2dec(msg(108:117))*0.001;
mt10.iiono = bin2dec(msg(118:126));
mt10.ciono_ramp = bin2dec(msg(127:136))*0.000005;
mt10.rss_udre = bin2dec(msg(137));
mt10.rss_iono = bin2dec(msg(138));
mt10.ccovariance = bin2dec(msg(139:145))*0.1;
mt10.time = time;
