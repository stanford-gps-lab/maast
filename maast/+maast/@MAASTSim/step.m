function step(obj)
% step  execute the next time step of the simulation.


% TODO: handle desired outputs for these steps

%
% process the WAAS Master Station data
%
obj.wmsProcess();


%
% process the user data
%
obj.usrProcess();


% TODO: some of the raw process outputs may need to be
% combined/post-processed to get the desired data and may want to log the
% intermediate data


% increase to the next time index
obj.Index = obj.Index + 1;