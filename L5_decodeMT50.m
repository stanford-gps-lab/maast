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

%Authenticate all of the messages associated with previously received MACs
for i = 2:length(svdata.mt50)
    % check that message was received and key number is earlier
    if ~isnan(svdata.mt50(i).msg_idx) && svdata.received(svdata.mt50(i).msg_idx) && ...
                     svdata.mt50(i).key_num < svdata.mt50(1).key_num
        % authenticate those that were received         
        svdata.auth_pass(svdata.mt50(i).mac_msg_ids) = ...
                  svdata.received(svdata.mt50(i).mac_msg_ids);
        %authenticate the MT 50 message
        svdata.auth_pass(svdata.mt50(i).msg_idx) = true;
    end
end