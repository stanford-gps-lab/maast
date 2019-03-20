function [] = calculateObservationData(obj)
% calculateObservationData  compute all of the properties that depend on
% the user and the satellite positions.  This includes the following:
%   - LOS in ECEF and ENU coordinates
%   - list of the satellites in view and number of satellites in view
%   - the elevation and azimuth angles of the satellites in view
%   - the range measurements to the satellites in view

%
% Setup
%

% get the number of satellites and their positions
[S, ~] = size(obj.SatellitePositions);
satPos = [obj.SatellitePositions.ECEF];

%
% calculate the ECEF LOS
%

% compute the range to the sallites
losecef = satPos - repmat(obj.User.Position, 1, S);

% normalize by magnitude
r = vecnorm(losecef);
losecef = losecef ./ repmat(r, 3, 1);
obj.LOSecef = losecef';

%
% calculate the ENU LOS
%
losenu = obj.User.ECEF2ENU * losecef;
obj.LOSenu = losenu';

%
% determine the satellites in view
%
u = losenu(3,:);
svInView = (u >= sin(obj.User.ElevationMask));
obj.SatellitesInViewMask  = svInView';
obj.NumSatellitesInView = sum(svInView);

%
% compute elevation angles to the satellites in view
%
obj.ElevationAngles = asin(losenu(3,svInView)');

%
% compute the azimuth angles to the satellites in view
%
obj.AzimuthAngles = atan2(losenu(1,svInView)', losenu(2,svInView)');

%
% compute the range measurement to the satellites in view
%
obj.RangeMeasurement = r';