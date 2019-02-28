function [XYZ] = llh2xyz( LLH )

%*************************************************************************
%*     Copyright c 2001 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% function [XYZ] = llh2xyz( LLH )
% 
% Calculate location in ECEF given location in Lat Lon Height.
% Input: 	Matrix LLH: Latitude [deg], Longitude [deg], Height [m]
%								One row for each point to be converted
% Output: 	Matrix XYZ [m] in ECEF: One row for each point

re 	= 6378137.0;		           % Earth equatorial radius
eflat = (1.0/298.257223563);  % Earth Flattening
d2r = pi/180;

lat	= LLH(:,1)*d2r;
lon = LLH(:,2)*d2r;
ht  = LLH(:,3);

e2 = (2- eflat)* eflat;
slat = sin(lat);
clat = cos(lat);
r_N  = re./sqrt( 1 - e2*slat.*slat );

XYZ(:,1) = ( r_N+ ht ).*clat.*cos(lon);
XYZ(:,2) = ( r_N+ ht ).*clat.*sin(lon);
XYZ(:,3) = ( r_N*(1-e2)+ ht ).*slat;














