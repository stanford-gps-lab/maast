function msg = L1_decodeMT21(time, msg)

msg(5:222) = msg(9:226); % shift message back to match L5 formatting
msg(223:226) = '0000';
msg(5:10) = dec2bin(51,6);


msg_logical = msg == '1';
msg_logical = msg_logical(1:250)';

global keyStateMachine

keyStateMachine.process_mt51(MT51.decode(msg_logical));
if keyStateMachine.full_stack_authenticated(time)
    fprintf('The Key State Machine has all keys and is authenticated\n');
else
    fprintf('The Key State Machine is not authenticated\n.');
end
