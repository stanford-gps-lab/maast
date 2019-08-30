function [] = cnmpVariance(obj)
% This function computes an aggressive from of the code noise and multipath
% variance. This is the default function used for SBASReferenceObservation.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Set Constants
maastConstants = maast.constants.MAASTConstants;
f1 = maastConstants.L1Frequency;
f2 = maastConstants.L2Frequency;

cnmpCoef = [-3.9586 11.5991 -10.5790 0.7142];    % aggressive cnmp

a1 = f1^2/(f1^2-f2^2);
a2 = f2^2/(f1^2-f2^2);

for i = 1:length(obj)
    
    elevationAngles = obj(i).ElevationAngles;
    svInView = obj(i).SatellitesInViewMask;
    
    % Preallocate
    obj(i).Sig2CNMP = NaN(length(elevationAngles), 1);
    
    % Calculate CNMP
    obj(i).Sig2CNMP(svInView) = (a1^2 + a2^2) * exp(polyval(cnmpCoef,elevationAngles(svInView))).^2;
end
end