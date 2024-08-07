function [svdata, flag] = L5_decode_messages(time, msg, svdata)
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

global L5MOPS_PREAMBLE AUTHENTICATION_ENABLED

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

if crc24q(msg)
    warning('CRC does not match')
    return
end
if ~strcmp(msg(1:4), L5MOPS_PREAMBLE(mod(round(time), 6) + 1,:))
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
mt = bin2dec(msg(5:10));

global mt50Receiver;
global keyStateMachine;
global AUTHENTICATION_ENABLED

if AUTHENTICATION_ENABLED
    msg_logical = msg == '1';
    msg_logical = msg_logical(1:250)';
    
    key = keyStateMachine.get_current_key(3, time);
    
    if ~isempty(key) && keyStateMachine.full_stack_authenticated(time, key.key) 
        % pass to reciver if different
        if isempty(mt50Receiver.reciever_hash_path_end) || ~all(key.key == mt50Receiver.reciever_hash_path_end)
            mt50Receiver.set_hash_path_end(key.key);
        end
        
        % pass next key if it is received
        next_key = keyStateMachine.get_next_key(3);
        if ~isempty(next_key) && (isempty(mt50Receiver.next_hash_path_end) || ...
                ~all(next_key.key == mt50Receiver.next_hash_path_end))
            mt50Receiver.set_next_hash_path_end(next_key.key);
        end
    end
    
    message = sprintf('%i', msg_logical);
    mt50Receiver.add_message(message, uint32(time));
end

switch mt
    case 0
        svdata = L5_decodeMT0(time, msg, svdata, 1);
    case 31
        svdata = L5_decodeMT31(time, msg, svdata);
    case 32
        svdata = L5_decodeMT32(time, msg, svdata);
    case 34
        svdata = L5_decodeMT34(time, msg, svdata);
    case 35
        svdata = L5_decodeMT35(time, msg, svdata);
    case 36
        svdata = L5_decodeMT36(time, msg, svdata);
    case 37
        svdata = L5_decodeMT37(time, msg, svdata);
    case 39
        svdata = L5_decodeMT39(time, msg, svdata);
    case 40
        svdata = L5_decodeMT40(time, msg, svdata);
    case 47
        svdata = L5_decodeMT47(time, msg, svdata); 
    case 50
        svdata = L5_decodeMT50(time, msg, svdata);   
    case 51
        L5_decodeMT51(time, msg);
end