function gmst = utc2gmst(date1)
%% DESCRIPTION
%
%       Written by:           Tyler Reid
%       Lab:                  Stanford GPS Lab
%       Project Title:        Arctic Navigation / WAAS
%       Project Start Date:   March 28, 2011
%       Last updated:         April 19, 2011
%
% -------------------------------------------------------------------------
% FUNCTION DESCRIPTION
%
% Given the UTC date / time compute the Greenwich Mean Sidereal Time in
% radians.  This algorithm is based on Vallado (2007) p. 195.
%
% -------------------------------------------------------------------------
% INPUT:
%   
%           date1 = date / time vector UTC.
%
% ------------------------------------------------------------------------- 
%
% OUTPUT:
%      
%            GMST = Greenwich Mean Sidereal Time                 [rad]
%
% -------------------------------------------------------------------------
%
%% IMPLEMENTATION

% compute the Julian date for the given input date vector
JD = juliandate(date1);

% compute UT1
UT1 = (JD-2451545.0)/36525;

% compute the Greenwich Mean Sidereal Time (GMST) [seconds]
gmst = 67310.54841 + (876600*3600 + 8640184.812866)*UT1 + 0.093104*UT1^2 - 6.2e-6*UT1^3;

% convert GMST to radians and put in the range [0 2*pi]
gmst = mod((gmst/240)*pi/180,2*pi);
