function [] = fltVariance(obj, mt28)
% This function calculates the fast/long-term variance for sbas user
% observations given udre and mt28 information.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Handle empty objects
if (isempty(obj.UserLL))
    return;
end

% Get WAAS MOPS Constants
waasMOPSConstants = maast.constants.WAASMOPSConstants;

% Number of satellites
numSats = length(obj.SatellitePRN);

% Preallocate
obj.Sig2FLT = NaN(numSats, 1);

% Loop through satellites and find sig2flt for satellites in view
for i = 1:numSats
    if (obj.SatellitesInViewMask(i))
        dUDRE = sqrt([obj.LOSecef(i,:), 1]*mt28{i}*[obj.LOSecef(i,:)'; 1])...
            + waasMOPSConstants.CCovariance;    %TODO: Add scale factor for GEOs
        
        obj.Sig2FLT(i) = obj.Sig2UDRE(i)*dUDRE^2;
    end
end
end