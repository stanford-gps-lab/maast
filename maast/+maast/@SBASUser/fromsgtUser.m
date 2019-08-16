function obj = fromsgtUser(sgtUser)
% This function creates an rrt.RRUser object from an sgt.User object.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Number of user objects
numUser = length(sgtUser);

% Initialize User object
obj(numUser) = maast.SBASUser();

for i = 1:numUser
    obj(i).ID = sgtUser(i).ID;
    obj(i).PositionLLH = sgtUser(i).PositionLLH;
    obj(i).PositionECEF = sgtUser(i).PositionECEF;
    obj(i).ECEF2ENU = sgtUser(i).ECEF2ENU;
    obj(i).ElevationMask = sgtUser(i).ElevationMask;
    obj(i).InBound = sgtUser(i).InBound;
end

end