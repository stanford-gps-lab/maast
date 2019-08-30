function [] = tropoVariance(obj)
% This function finds the variance along the line of sight due to the
% troposphere. This variance is calculated using the function written in
% the MOPS.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Preallocate
obj.Sig2Tropo = NaN(length(obj.ElevationAngles), 1);

elevationAngles = obj.ElevationAngles;
svInView = obj.SatellitesInViewMask;

obj.Sig2Tropo(svInView) = (0.12*1.001)^2 ./ (0.002001+sin(elevationAngles(svInView)).^2);
end