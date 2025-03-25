function svdata = L1_decodeMT20(time, msg, svdata)
%*************************************************************************
%*     Copyright c 2025 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% Decodes Message Type 20 
%
% SEE ALSO: L1_decode_messages

%created 18 March, 2025 by Todd Walter


% copy older messages over
svdata.mt20(2:end) = svdata.mt20(1:(end-1));

svdata.mt20(1).key_num = floor((time - 2.0)/6.0);
xs_time = rem((time - 2.0),6.0);
if xs_time > 4.0
    warning('Misplaced authentication message: %i seconds late', xs_time);
end

svdata.mt20(1).time = time;

svdata.mt20(1).msg_idx = mod(round(time), 700) + 1;
mac_msg_ids = svdata.mt20(1).msg_idx - (5:-1:1);
if mac_msg_ids(1) < 1
    mac_msg_ids = mod(mac_msg_ids + 699, 700) + 1;
end
svdata.mt20(1).mac_msg_ids = mac_msg_ids;

% compute svdata indexes of incoming messages to authenticate
mt20_time = uint32(time);
mt20_idx = time_to_msg_idx(mt20_time);

mt_times = mt20_time - uint32(6) - uint32(5:-1:1);
mt_idx = time_to_msg_idx(mt_times);

global mt20Receiver;
svdata.auth_pass(mt20_idx) = mt20Receiver.check_if_message_verified(mt20_time);

for i = 1:5
    t = mt_times(i);
    idx = mt_idx(i);
    svdata.auth_pass(idx) = mt20Receiver.check_if_message_verified(t);
end

function idx = time_to_msg_idx(time)
    idx = mod(round(time), 700) + 1;
end

end

