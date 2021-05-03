function svdata = L5_decodeMT50(time, msg, svdata)
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
% Decodes Message Type 51 
%   a dummy message
%
% SEE ALSO: L5_decode_messages

%created 06 January, 2021 by Todd Walter


% copy older messages over
svdata.mt50(2:end) = svdata.mt50(1:(end-1));

svdata.mt50(1).key_num = floor((time - 2.0)/6.0);
xs_time = rem((time - 2.0),6.0);
if xs_time > 4.0
    warning('Misplaced authentication message: %i seconds late', xs_time);
end

svdata.mt50(1).time = time;

svdata.mt50(1).msg_idx = mod(round(time), 700) + 1;
mac_msg_ids = svdata.mt50(1).msg_idx - (5:-1:1);
if mac_msg_ids(1) < 1
    mac_msg_ids = mod(mac_msg_ids + 699, 700) + 1;
end
svdata.mt50(1).mac_msg_ids = mac_msg_ids;

% compute svdata indexes of incoming messages to authenticate
mt50_time = uint32(time);
mt50_idx = time_to_msg_idx(mt50_time);

mt_times = mt50_time - uint32(6) - uint32(5:-1:1);
mt_idx = time_to_msg_idx(mt_times);

global mt50Receiver;
svdata.auth_pass(mt50_idx) = mt50Receiver.check_if_message_verified(mt50_time);

for i = 1:5
    t = mt_times(i);
    idx = mt_idx(i);
    svdata.auth_pass(idx) = mt50Receiver.check_if_message_verified(t);
end

function idx = time_to_msg_idx(time)
    idx = mod(round(time), 700) + 1;
end

end

