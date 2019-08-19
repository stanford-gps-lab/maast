function obj = fromsgtUserObservation(sgtUserObservation)
% fromsgtUserObservation creates a maast.SBASUserObservation from an
% sgt.UserObservation

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

for i = 1:length(sgtUserObservation)
    % Create maast.SBASUserObservation object
    obj(i) = maast.SBASUserObservation();
    obj(i).SatellitePosition = sgtUserObservation(i).SatellitePosition;
    obj(i).LOSecef = sgtUserObservation(i).LOSecef;
    obj(i).LOSenu = sgtUserObservation(i).LOSenu;
    obj(i).SatellitesInViewMask = sgtUserObservation(i).SatellitesInViewMask;
    obj(i).ElevationAngles = sgtUserObservation(i).ElevationAngles;
    obj(i).AzimuthAngles = sgtUserObservation(i).AzimuthAngles;
    obj(i).NumSatellitesInView = sgtUserObservation(i).NumSatellitesInView;
    obj(i).Range = sgtUserObservation(i).Range;
    
    % Change user type from sgt.User to maast.SBASUser
    obj(i).User = maast.SBASUser.fromsgtUser(sgtUserObservation(i).User);
end

end