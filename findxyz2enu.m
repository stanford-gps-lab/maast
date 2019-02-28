function [xyz2enu] = findxyz2enu(lat, lon)
%*************************************************************************
%*     Copyright c 2009 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%FINDXYZ2ENU find the rotation matrix to go from XYZ ECEF coordinates
%     to a local East North Up frame
%   [xyz2enu] = FINDXYZ2ENU(LAT, LON)
%  LAT, LON specify the coordinates of the center of the local frame in radians
%  XYZ2ENU is the rotation matrix such that DELTA_ENU = XYZ2ENU*DELTA_XYZ

%   TWalter 14 Mar 00
%   2009 fixed transpose problem if only a single location

if (nargin < 2)
  error('You must supply lat and lon in radians!');
end

n=length(lon);

xyz2enu=zeros(n,3,3);

xyz2enu(:,1,1) = sin(lon);
xyz2enu(:,1,2) = cos(lon);
xyz2enu(:,1,3) = 0.0;

xyz2enu(:,2,3) = cos(lat);
xyz2enu(:,3,3) = sin(lat);

xyz2enu(:,2,1) = -xyz2enu(:,1,2).*xyz2enu(:,3,3);
xyz2enu(:,2,2) = -xyz2enu(:,1,1).*xyz2enu(:,3,3);

xyz2enu(:,3,1) = xyz2enu(:,1,2).*xyz2enu(:,2,3);
xyz2enu(:,3,2) = xyz2enu(:,1,1).*xyz2enu(:,2,3);

xyz2enu(:,1,1) = -xyz2enu(:,1,1);

if(n == 1)
  xyz2enu=reshape(xyz2enu,3,3)';
end
