function [varargout] = llh2ecef(lat, lon, h)
% llh2ecef    convert from a lat/lon/height in [deg]/[deg]/[m] to an ECEF
% position in [m].
%
%	ecef = maast.tools.llh2ecef(llh) calculates the ECEF position from the
%	llh matrix containing the latitude, longitude, and height information
%	in [deg, deg, m].  The llh matrix must be an Nx3 matrix with each row
%	containing a [lat, lon, h] point to convert.  The resulting ecef matrix
%	will also be an Nx3 matrix with each row containing the [x, y, z]
%	position.
%
%	[x, y, z] = maast.tools.llh2ecef(lat, lon, h) calculates the ECEF
%	position given the latitude ([deg]), longitude ([deg]), and height
%	([m]) as three separate vector.  Each vector must have the same size.
%	The ECEF position is returned as three separate vectors x, y, and z
%	containing the corresponding ECEF position component.
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
	[r, c] = size(lat);
	if c ~= 3
		error('invalid matrix input format');
	end

	% split out the 3 elements
	lon = lat(:,2);
	h = lat(:,3);
	lat = lat(:,1);
end

% TODO: need to validate the input dimensions, etc for the 3 vector case.
%
% TODO: also maybe want to allow one (or multiple) of the inputs to be a
% constant (would just expand it here).

% convert from deg to rad
lonr = lon * pi/180;
latr = lat * pi/180;

% get sin and cos of latitude
slat = sin(latr);
clat = cos(latr);

% setup additional values
f = maast.constants.EarthConstants.f;
e2 = (2 - f) * f;
r_N  = maast.constants.EarthConstants.R ./ sqrt(1 - e2*slat.*slat);

% do the conversion
x = (r_N + h).*clat.*cos(lonr);
y = (r_N + h).*clat.*sin(lonr);
z = (r_N*(1 - e2) + h).*slat;

% if the input was a matrix, return a matrix output, if the input was 3 
% separate vectors, then return 3 separate vectors
if nargin == 1
	varargout{1} = [x y z];
else
	varargout{1} = x;
	varargout{2} = y;
	varargout{3} = z;
end