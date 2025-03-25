function [svdata, igpdata, mt10, flag] = L1_decode_messages(time, msg, svdata, igpdata, mt10)
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

global MOPS_L1_PREAMBLE 

global mt20Receiver;
global keyStateMachine;
global AUTHENTICATION_ENABLED

flag  = 0;

%mark current and future messages as not received and not authenticated
idx = mod(round(time), 700) + 1;
if idx > 640
    svdata.received(idx:end) = false;
    svdata.auth_pass(idx:end) = false;
    svdata.received(1:(idx-640)) = false;
    svdata.auth_pass(1:(idx-640)) = false;   
else
    svdata.received(idx:(idx+60)) = false;
    svdata.auth_pass(idx:(idx+60)) = false;
end

mt = bin2dec(msg(9:14));
if crc24q(msg) 
    warning('CRC does not match')
    return
end
if ~strcmp(msg(1:8), MOPS_L1_PREAMBLE(mod(round(time), 3) + 1,:))
    warning('preamble does not match')
    return
end

%mark message as received
svdata.received(idx) = true;
% if authentication is not enabled, mark all messages as authenticated
if isempty(AUTHENTICATION_ENABLED) || ~AUTHENTICATION_ENABLED
    svdata.auth_pass = true(size(svdata.auth_pass));    
else
    % otherwise mark them as not authenticated
    svdata.auth_pass(idx) = false;
end

flag = 1;

if AUTHENTICATION_ENABLED
    if mt == 20
        shift_msg = msg;
        shift_msg(5:222) = shift_msg(9:226); % shift message back to match L5 formatting
        shift_msg(223:226) = '0000';
        shift_msg(5:10) = dec2bin(50,6);

        msg_logical = shift_msg == '1';   
    else
        msg_logical = msg == '1';
    end

    msg_logical = msg_logical(1:250)';
    
    key = keyStateMachine.get_current_key(3, time);
    
    if ~isempty(key) && keyStateMachine.full_stack_authenticated(time, key.key) 
        % pass to reciver if different
        if isempty(mt20Receiver.reciever_hash_path_end) || ~all(key.key == mt20Receiver.reciever_hash_path_end)
            mt20Receiver.set_hash_path_end(key.key);
        end
        
        % pass next key if it is received
        next_key = keyStateMachine.get_next_key(3);
        if ~isempty(next_key) && (isempty(mt20Receiver.next_hash_path_end) || ...
                ~all(next_key.key == mt20Receiver.next_hash_path_end))
            mt20Receiver.set_next_hash_path_end(next_key.key);
        end
    end
    
    message = sprintf('%i', msg_logical);
    mt20Receiver.add_message(message, uint32(time));
end

switch mt
    case 0
        [svdata, igpdata, mt10] = L1_decodeMT0(time, msg, svdata, igpdata, mt10, 1);
    case 1
        svdata = L1_decodeMT1(time, msg, svdata);
    case {2, 3, 4, 5}
        svdata = L1_decodeMT2345(time, msg, svdata);
    case 6
        svdata = L1_decodeMT6(time, msg, svdata);
    case 7
        svdata = L1_decodeMT7(time, msg, svdata);
    case 9
        svdata = L1_decodeMT9(time, msg, svdata);
    case 10
        mt10 = L1_decodeMT10(time, msg, mt10);
    case 17
        svdata = L1_decodeMT17(time, msg, svdata); 
    case 18
        igpdata = L1_decodeMT18(time, msg, igpdata); 
    case 20
        svdata = L1_decodeMT20(time, msg, svdata); 
    case 21
        L1_decodeMT21(time, msg); 
    case 24
        svdata = L1_decodeMT24(time, msg, svdata);
    case 25
        svdata = L1_decodeMT25(time, msg, svdata);
    case 26
        igpdata = L1_decodeMT26(time, msg, igpdata); 
    case 27
        svdata = L1_decodeMT27(time, msg, svdata);        
    case 28
        svdata = L1_decodeMT28(time, msg, svdata);  
end