function msg = msg_auth_test(time, msg, svdata)
%This function introdcues message errors and evaluates whether the
%authenticaiton scheme properly handles them

%% corrupt the Hashpoint
if mod(time, 86400) == 18
    %confirm that it is a MT 50 message
    if bin2dec(msg(5:10)) ~= 50
        error('msg_auth_test:BadTest', ...
           'Timing of MT 50 is not as expected');
    end
    msg = msg_bit_flip(msg,230);
end
%look for the effect
if mod(time, 86400) == 19
    % should be a warning
    [~, warnId] = lastwarn;
    if ~strcmp(warnId,'ReceiverTESLA:InvalidHashPoint')
        error('msg_auth_test:InvalidHashPointFail', ...
           'Bad Hash Point should not Hash down to verified Hash Point');
    end
    %look for invalid authentication flags
    idx = mod(round(time - (8:12)), 700) + 1;
    if any(svdata.auth_pass(idx))
        error('msg_auth_test:InvalidHashPointAuthentication', ...
           'Bad Hash Point should not allow valid authentication'); 
    end
end

%% corrupt the AMAC
if mod(time, 86400) == 30
    msg = msg_bit_flip(msg,30);
end
%look for the effect
if mod(time, 86400) == 37
    % should be a warning
    [~, warnId] = lastwarn;
    if ~strcmp(warnId,'Receiver:invalidHmac')
        error('msg_auth_test:InvalidAMACFail', ...
           'Bad AMAC should not match messages');
    end
    %look for invalid authentication flags
    idx = mod(round(time - (8:12)), 700) + 1;
    if any(svdata.auth_pass(idx))
        error('msg_auth_test:InvalidAMACAuthentication', ...
           'Bad AMAC should not allow valid authentication'); 
    end
end

%% corrupt a Message
if mod(time, 86400) == 41
    msg = msg_bit_flip(msg,30);
end
%look for the effect
if mod(time, 86400) == 42
    % should be a warning
    [warn, ~] = lastwarn;
    if ~strcmp(warn,'CRC does not match')
        error('msg_auth_test:InvalidCRCFail', ...
           'Bad CRC should not pass');
    end
end
if mod(time, 86400) == 49
    %look for invalid authentication flags
    idx = mod(round(time - 8), 700) + 1;
    jdx = mod(round(time - (9:12)), 700) + 1;
    if svdata.auth_pass(idx) || ~all(svdata.auth_pass(jdx))
        error('msg_auth_test:InvalidMessageAuthentication', ...
           'Bad CRC should fail only one message authentication'); 
    end
end

%% corrupt two Messages
if mod(time, 86400) == 61 || mod(time, 86400) == 63
    msg = msg_bit_flip(msg,30);
end
%look for the effect
if mod(time, 86400) == 62 || mod(time, 86400) == 64
    % should be a warning
    [warn, ~] = lastwarn;
    if ~strcmp(warn,'CRC does not match')
        error('msg_auth_test:InvalidCRCFail', ...
           'Bad CRC should not pass');
    end
end
if mod(time, 86400) == 73
    %look for invalid authentication flags
    idx = mod(round(time - [10 12]), 700) + 1;
    jdx = mod(round(time - [8 9 11]), 700) + 1;
    if any(svdata.auth_pass(idx)) || ~all(svdata.auth_pass(jdx))
        error('msg_auth_test:Invalid2MessageAuthentication', ...
           'Bad CRCs should fail only two message authentications'); 
    end
end

%% corrupt three Messages
if mod(time, 86400) == 91 || mod(time, 86400) == 93|| mod(time, 86400) == 95
    msg = msg_bit_flip(msg,30);
end
%look for the effect
if mod(time, 86400) == 92 || mod(time, 86400) == 94|| mod(time, 86400) == 96
    % should be a warning
    [warn, ~] = lastwarn;
    if ~strcmp(warn,'CRC does not match')
        error('msg_auth_test:InvalidCRCFail', ...
           'Bad CRC should not pass');
    end
end
if mod(time, 86400) == 103
    %look for invalid authentication flags
    idx = mod(round(time - (8:12)), 700) + 1;
    if any(svdata.auth_pass(idx))
        error('msg_auth_test:Invalid3MessageAuthentication', ...
           'Bad CRCs should fail all five message authentications'); 
    end
end
end % end of msg_auth_test

%Function to flip the specified bit
function msg = msg_bit_flip(msg,bit_pos)
if msg(bit_pos) == '1'
    msg(bit_pos) = '0';
else
    msg(bit_pos) = '1';
end
end

