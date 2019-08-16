function obj = fromsgtUser(sgtUser)
% This function creates an rrt.RRUser object from an sgt.User object.

% Number of user objects
numUser = length(sgtUser);

for i = 1:numUser
    obj(i).ID = sgtUser(i).ID;
    obj(i).PositionLLH = sgtUser(i).PositionLLH;
    obj(i).PositionECEF = sgtUser(i).PositionECEF;
    obj(i).ECEF2ENU = sgtUser(i).ECEF2ENU;
    obj(i).ElevationMask = sgtUser(i).ElevationMask;
    obj(i).InBound = sgtUser(i).InBound;
end

end