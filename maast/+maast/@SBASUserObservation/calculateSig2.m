function [] = calculateSig2(obj)
% This function calculates the line of sight variance to all satellites
% that are monitored according to the WAAS MOPS.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Preallocate
obj.Sig2 = NaN(length(obj.SatellitePRN),1);

% Calculate Sig2
obj.Sig2(obj.SatellitesMonitoredMask) = obj.Sig2FLT(obj.SatellitesMonitoredMask) + ...
    obj.Sig2UIVE(obj.SatellitesMonitoredMask).*maast.tools.obliquity2(obj.ElevationAngles(obj.SatellitesMonitoredMask)) + ...
    obj.Sig2Tropo(obj.SatellitesMonitoredMask) + obj.Sig2CNMP(obj.SatellitesMonitoredMask);
end