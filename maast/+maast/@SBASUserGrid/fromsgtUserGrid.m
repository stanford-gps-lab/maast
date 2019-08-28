function obj = fromsgtUserGrid(sgtUserGrid)
% This function creates a maast.SBASUserGrid object from an existing
% sgt.UserGrid object.
%
%   See Also: sgt.UserGrid, maast.SBASUserGrid

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Number of user objects
numUser = length(sgtUserGrid);

% Initialize User object
obj(numUser) = maast.SBASUserGrid();

for i = 1:numUser
    obj(i).GridName = sgtUserGrid(i).GridName;
    obj(i).GridPositionLLH = sgtUserGrid(i).GridPositionLLH;
    obj(i).GridPositionECEF = sgtUserGrid(i).GridPositionECEF;
    obj(i).Polygon = sgtUserGrid(i).Polygon;
    obj(i).Users = maast.SBASUser.fromsgtUser(sgtUserGrid(i).Users);
end
end