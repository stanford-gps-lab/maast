function obj = fromsgtUserObservation(sgtUserObservation)
% fromsgtUserObservation creates a maast.SBASUserObservation from an
% sgt.UserObservation

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Preallocate
obj(length(sgtUserObservation)) = maast.SBASUserObservation;

% Allocate Properties
[obj.UserID] = deal(sgtUserObservation.UserID);
[obj.SatellitePRN] = deal(sgtUserObservation.SatellitePRN);
[obj.t] = deal(sgtUserObservation.t);
[obj.LOSecef] = deal(sgtUserObservation.LOSecef);
[obj.LOSenu] = deal(sgtUserObservation.LOSenu);
[obj.SatellitesInViewMask] = deal(sgtUserObservation.SatellitesInViewMask);
[obj.ElevationAngles] = deal(sgtUserObservation.ElevationAngles);
[obj.AzimuthAngles] = deal(sgtUserObservation.AzimuthAngles);
[obj.NumSatellitesInView] = deal(sgtUserObservation.NumSatellitesInView);
[obj.Range] = deal(sgtUserObservation.Range);
end