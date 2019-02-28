function [el, az]=find_elaz(los_enub)

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
%FIND_ELAZ calculates the elevation and azimuth angles from the ENU LOS vectors
%
%[EL AZ]=FIND_ELAZ(LOS_ENU);
%   Given line of sight vectors in the East, North, Up frame this function
%   calculates the elevation and azimuth angles in radians.
%
%   See also: FIND_LOS_XYZB

%2001Mar26 Created by Todd Walter


el=asin(-los_enub(:,3));
az=atan2(-los_enub(:,1),-los_enub(:,2));
