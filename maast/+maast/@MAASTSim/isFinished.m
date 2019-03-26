function f = isFinished(obj)
% isFinished    true if the simulation is finished

% condition for being finished is the index being beyond the time vector
% length
f = (obj.Index > length(obj.Tvec));