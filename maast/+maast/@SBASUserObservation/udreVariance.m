function [] = udreVariance(obj, udrei)
% This function allocates the udre variance according to the UDREI values
% received from the master station.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Handle empty observations
if (isempty(obj.UserLL))
    return;
end

% Get WAAS MOPS Constants
waasMOPSConstants = maast.constants.WAASMOPSConstants;

obj.Sig2UDRE = waasMOPSConstants.Sig2UDRE(udrei)';