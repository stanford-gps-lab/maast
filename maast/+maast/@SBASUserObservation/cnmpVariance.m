function [] = cnmpVariance(obj)
% This function finds the variance along the line of sight due to the
% troposphere. This variance is calculated using the function written in
% the MOPS.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Handle empty input
if (isempty(obj.UserLL))
    return;
end

% Grab WAASMOPSConstants
waasMOPSConstants = maast.constants.WAASMOPSConstants;

% Get elevation angles
el = NaN(length(obj.SatellitePRN), 1);
el(obj.SatellitesInViewMask) = obj.ElevationAngles(obj.SatellitesInViewMask);

obj.Sig2CNMP =(waasMOPSConstants.CNMPA0 + waasMOPSConstants.CNMPA1*exp(-el/waasMOPSConstants.CNMPTheta0)).^2 +...
    (waasMOPSConstants.CNMPB0 - waasMOPSConstants.CNMPB1*(el - waasMOPSConstants.CNMPPhi0)/waasMOPSConstants.CNMPPhi1).^2;
end