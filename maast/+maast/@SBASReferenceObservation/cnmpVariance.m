function [] = cnmpVariance(obj)
% This function computes an aggressive from of the code noise and multipath
% variance. This is the default function used for SBASReferenceObservation.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Set Constants
f1 = maast.constants.MAASTConstants.L1Frequency;
f2 = maast.constants.MAASTConstants.L2Frequency;

cnmpCoef = [-3.9586 11.5991 -10.5790 0.7142];    % aggressive cnmp

a1 = f1^2/(f1^2-f2^2);
a2 = f2^2/(f1^2-f2^2);

[numRefStations, timeLength] = size(obj);

for j = 1:numRefStations
    for i = 1:timeLength
        
        elevationAngles = obj(j,i).ElevationAngles;
        svInView = obj(j,i).SatellitesInViewMask;
        
        % Preallocate
        obj(j,i).Sig2CNMP = NaN(length(elevationAngles), 1);
        
        % Calculate CNMP
        obj(j,i).Sig2CNMP(svInView) = (a1^2 + a2^2) * exp(polyval(cnmpCoef,elevationAngles(svInView))).^2;
    end
end
end