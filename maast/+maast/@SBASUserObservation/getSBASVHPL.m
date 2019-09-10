function [] = getSBASVHPL(obj)
% getSBASVPL calculates the VPL for a given SBASUserObservation using the
% methods outlined in Appendix J of the WAAS MOPS

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

if (sum(obj.SatellitesMonitoredMask) > 3) && (max(obj.SatellitePRN) >= maast.constants.WAASMOPSConstants.MinGEOPRN)
    % Calculate VPL
    % Get geometry matrix in the local enu frame
    G = [obj.LOSenu(obj.SatellitesMonitoredMask, :), ones(sum(obj.SatellitesMonitoredMask),1)];
    W = diag(ones(sum(obj.SatellitesMonitoredMask),1)./obj.Sig2(obj.SatellitesMonitoredMask));
    Cov = inv(G'*W*G);
    obj.VPL = maast.constants.WAASMOPSConstants.KVPA*sqrt(Cov(3,3));
    % Calculate HPL
    obj.HPL = maast.constants.WAASMOPSConstants.KHPA*...
        sqrt(0.5*(Cov(1,1) + Cov(2,2)) +...
        sqrt(0.25*(Cov(1,1) - Cov(2,2))^2 +...
        Cov(1,2)*Cov(2,1)));
else
    % V/HPL not available
    obj.VPL = NaN;
    obj.HPL = NaN;
end
end