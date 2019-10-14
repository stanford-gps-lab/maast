function ob2 = obliquity2(el)
% This function takes the elevation angle in radians and returns the square
% of the ionospheric obliquity function.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

maastConstants = maast.constants.MAASTConstants;
earthConstants = sgt.constants.EarthConstants;

ob2=ones(size(el))./(1-(earthConstants.R*cos(el)/maastConstants.IonoRadius).^2);
end