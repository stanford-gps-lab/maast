function msg = L5_decodeMT51(time, msg)

msg_logical = msg == '1';
msg_logical = msg_logical(1:250)';

global keyStateMachine

keyStateMachine.process_mt51(MT51.decode(msg_logical));
if keyStateMachine.full_stack_authenticated(time)
    fprintf('The Key State Machine has all keys and is authenticated\n');
else
    fprintf('The Key State Machine is not authenticated\n.');
end
