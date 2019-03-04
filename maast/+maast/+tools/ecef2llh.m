function [varargout] = ecef2llh(x, y, z)
% ecef2llh    convert from an ECEF position in [m] to a lat/lon/height
% position in [deg]/[deg]/[m]
%
%	llh = maast.tools.ecef2llh(ecef) calculates the LLH position from the
%	ecef matrix containing the x, y, z information in [m].  The ecef matrix
%	must be an Nx3 matrix with each row containing an [x, y, z] point to
%	convert.  The resulting llh matrix will also be an Nx3 matrix with each
%	row containing the [lat, lon, height] position.
%
%	[lat, lon, h] = maast.tools.ecef2llh(x, y, z) calculates the LLH
%	position given the ECEF x ([m]), y ([m]), and z ([m]) as three separate
%	vector.  Each vector must have the same size. The LLH position is
%	returned as three separate vectors lat, lon, and h containing the
%	corresponding LLH position component.
%
% 	See Also: maast.tools.llh2ecef

% Copyright 2001-2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details.
%   Questions and comments should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% want to allow either a matrix input or 3 separate arrays, so check to see
% if the user entered a matrix
if nargin == 1
	[r, c] = size(x);
	if c ~= 3
		error('invalid matrix input format');
	end

	% split out the 3 elements
	y = x(:,2);
	z = x(:,3);
	x = x(:,1);
end

% TODO: need to validate the input dimensions, etc for the 3 vector case.
%
% TODO: also maybe want to allow one (or multiple) of the inputs to be a
% constant (would just expand it here).

% setup
f = maast.constants.EarthConstants.f;
e2 = (2 - f) * f;
p = sqrt(x.^2 + y.^2);

% compute longitude
%	this can be calculated directly
lon = atan2(y, x);

% setup the iterations that are required for computing latitude and height
lat = atan2(z./p, 0.01);
r_N = maast.constants.EarthConstants.R./sqrt(1 - e2*sin(lat).^2);
h = p./cos(lat) - r_N;

% iterate until end condition is met (height value change is <1e-4)
oldH = -1e-9; 		% the old height value
num = z./p;			% atan2 numerator (constant for all iterations)

while abs(h - oldH) > 1e-4

		% save the old height
		oldH = h;

		% compute latitude
		den =  1 - e2*r_N./(r_N + h);
		lat = atan2(num, den);

		% compute height
		r_N = maast.constants.EarthConstants.R./sqrt(1 - e2*sin(lat).^2);
		h = p./cos(lat) - r_N;
end

% convert lat and lon to degrees
lat = lat * 180/pi;
lon = lon * 180/pi;

% if the input was a matrix, return a matrix output, if the input was 3 
% separate vectors, then return 3 separate vectors
if nargin == 1
	varargout{1} = [lat lon h];
else
	varargout{1} = lat;
	varargout{2} = lon;
	varargout{3} = h;
end
