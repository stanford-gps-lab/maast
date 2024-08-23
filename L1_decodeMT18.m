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

% copy older messages over
igpdata.mt18(bandid,2:end) = igpdata.mt18(bandid,1:(end-1));

igpdata.mt18(bandid,1).num_bands = bin2dec(msg(15:18));
igpdata.mt18(bandid,1).iodi = bin2dec(msg(23:24));
igpdata.mt18(bandid,1).mask = cast(bin2dec(msg(25:225)'), 'uint8')';

igpdata.mt18(bandid,1).time = time;
igpdata.mt18(bandid,1).msg_idx = mod(round(time), 700) + 1;


% kdx = 1:201;
% igps = kdx(svdata.mt31(1).mask>0)';
% igpdata.igps(1:length(igps)) = igps;
% 
% slot = 1;
% igpdata.t18(bandid,1).igp2slot = NaN(size(igpdata.t18(bandid,1).igp2slot));
% igpdata.t18(bandid,1).slot2igp = NaN(size(igpdata.t18(bandid,1).slot2igp));
% for igp = 1:201
%     if igpdata.mt18(bandid,1).mask(igp)
%         igpdata.mt18(bandid,1).igp2slot(igp) = slot;
%         igpdata.mt18(bandid,1).slot2igp(slot) = igp;
%         slot = slot + 1;
%     end
% end
