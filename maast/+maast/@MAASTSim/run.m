function run(obj)
% run   the main loop for processing the data


% run through all the time steps
while ~obj.isFinished()
    % NOTE: step function increases the index
    obj.step();
end