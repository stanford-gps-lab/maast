function [] = tropoVariance(obj)
% This function finds the variance along the line of sight due to the
% troposphere. This variance is calculated using the function written in
% the MOPS.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

[numRefStations, timeLength] = size(obj);

for j = 1:numRefStations
    for i = 1:timeLength
        
        % Preallocate
        obj(j,i).Sig2Tropo = NaN(length(obj(j,i).ElevationAngles), 1);
        
        elevationAngles = obj(j,i).ElevationAngles;
        svInView = obj(j,i).SatellitesInViewMask;
        
        obj(j,i).Sig2Tropo(svInView) = (0.12*1.001)^2 ./ (0.002001+sin(elevationAngles(svInView)).^2);
    end
end
end