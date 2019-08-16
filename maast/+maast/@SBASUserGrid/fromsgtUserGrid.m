function obj = fromsgtUserGrid(sgtUserGrid)
% This function creates a maast.SBASUserGrid object from an existing
% sgt.UserGrid object.
%
%   See Also: sgt.UserGrid, maast.SBASUserGrid

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