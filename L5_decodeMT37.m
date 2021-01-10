function svdata = L5_decodeMT37(time, msg, svdata)
%*************************************************************************
%*     Copyright c 2021 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% Decodes Message Type 37 
%   per ED-259A
%
% SEE ALSO: L5_decode_messages

%created 28 December, 2020 by Todd Walter

% copy older messages over
svdata.mt37(2:end) = svdata.mt37(1:(end-1));

svdata.mt37(1).Ivalid32 = bin2dec(msg(11:16))*6.0 + 30.0;
svdata.mt37(1).Ivalid3940 = bin2dec(msg(17:22))*6.0 + 30.0;
svdata.mt37(1).Cer = bin2dec(msg(23:28))*0.5;
svdata.mt37(1).Ccovariance = bin2dec(msg(29:35))*0.1;

idx = 36;
for cdx = 1:6
    svdata.mt37(1).Icorr(cdx) = bin2dec(msg(idx:(idx+4)))*6.0 + 30.0;
    idx = idx + 5;
    svdata.mt37(1).Ccorr(cdx) = bin2dec(msg(idx:(idx+7)))*0.01;
    idx = idx + 8;
    svdata.mt37(1).Rcorr(cdx) = bin2dec(msg(idx:(idx+7)))*0.0002;
    idx = idx + 8;
end

% decode in the sigma DFRE table
svdata.mt37(1).sig_dfre(1)  = bin2dec(msg(162:165))*0.0625 + 0.125;
svdata.mt37(1).sig_dfre(2)  = bin2dec(msg(166:169))*0.125  + 0.25;
svdata.mt37(1).sig_dfre(3)  = bin2dec(msg(170:173))*0.125  + 0.375;
svdata.mt37(1).sig_dfre(4)  = bin2dec(msg(174:177))*0.125  + 0.5;
svdata.mt37(1).sig_dfre(5)  = bin2dec(msg(178:181))*0.125  + 0.625;
svdata.mt37(1).sig_dfre(6)  = bin2dec(msg(182:185))*0.25   + 0.75;
svdata.mt37(1).sig_dfre(7)  = bin2dec(msg(186:189))*0.25   + 1.0;
svdata.mt37(1).sig_dfre(8)  = bin2dec(msg(190:193))*0.25   + 1.25;
svdata.mt37(1).sig_dfre(9)  = bin2dec(msg(194:197))*0.25   + 1.5;
svdata.mt37(1).sig_dfre(10) = bin2dec(msg(198:201))*0.25   + 1.75;
svdata.mt37(1).sig_dfre(11) = bin2dec(msg(202:205))*0.5    + 2.0;
svdata.mt37(1).sig_dfre(12) = bin2dec(msg(206:209))*0.5    + 2.5;
svdata.mt37(1).sig_dfre(13) = bin2dec(msg(210:213))        + 3.0;
svdata.mt37(1).sig_dfre(14) = bin2dec(msg(214:217))*3.0    + 4.0;
svdata.mt37(1).sig_dfre(15) = bin2dec(msg(218:221))*6.0    + 10.0;

svdata.mt37(1).trefid = bin2dec(msg(222:224));
svdata.mt37(1).obadidx = bin2dec(msg(225));

svdata.mt37(1).time = time;

svdata.mt37(1).msg_idx = mod(round(time), 700) + 1;
