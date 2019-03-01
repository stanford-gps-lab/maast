function [llh] = xyz2llh(xyz)
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
%XYZ2LLH convert from ECEF XYZ frame to latitude, longitude and height
%    [LLH] = XYZ2LLH(XYZ)
%  XYZ is the matrix of corresponding points in the WGS84 ECEF frame
%  LAT, LON, HEIGHT specify the coordinates to convert in DEGREES and meters

%   TWalter 13 Oct 00
% Modified: wchan - output in degrees

global CONST_R_E CONST_FLAT_E %defined in svmconst.m

[n,m]=size(xyz);
if (m < 3)
  error('You must supply an xyz 3 vector');
end

e2 = (2- CONST_FLAT_E)* CONST_FLAT_E;
p2= xyz(:,1).^2 + xyz(:,2).^2;
p = sqrt(p2);
llh(:,2) = atan2( xyz(:,2), xyz(:,1));

% interation on Lat and Height 

llh(:,1)   = atan2( xyz(:,3)./p, 0.01 );
r_N = CONST_R_E*ones(n,1)./ sqrt( 1- e2* sin(llh(:,1)).^2);

llh(:,3) = p./cos(llh(:,1)) - r_N;

% iteration 
old_H  = -1e-9;
num    = xyz(:,3)./p;

while abs(llh(:,3)- old_H) > 1e-4

	  old_H  = llh(:,3);
	  den    =  1- e2 * r_N./(r_N+llh(:,3));
	  llh(:,1)   = atan2(num,den);

	  r_N    = CONST_R_E./ sqrt(1- e2* sin(llh(:,1)).^2);
	  llh(:,3)      = p./cos(llh(:,1))- r_N;
end
llh(:,1:2) = llh(:,1:2)*180/pi;











