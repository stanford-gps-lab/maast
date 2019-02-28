function ll_ipp=find_ll_ipp(ll_usr, el, az, idx)

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
%FIND_LL_IPP calculates the latitude & longitude of the IPPs
%
%LL_IPP=CALC_LL_IPP(LL_USR, EL, AZ);
%   Given the latitude and longitude of the user locations (in degrees) in
%   LL_USR (n_usr,2) and the elevation and azimuth angles (in radians) in EL
%   (n_los, 1) and AZ (n_los,1) to the different satellites, this function
%   returns the latitudes and longitudes of the Ionospheric Pierce Points
%  (in degrees)
%
%   See also: CALC_LL_IPP FIND_EL_AZ

%2001Mar26 Created by Todd Walter


[n_los tmp]=size(el);
[n_usr tmp]=size(ll_usr);
n_sat=n_los/n_usr;

sat_idx=1:n_sat;

%convert to radians
ll_usr=ll_usr*pi/180;

%expand the user latitudes and longitudes to match the lines of sight
[t1 t2]=meshgrid(ll_usr(:,2),sat_idx);
latlon(:,2)=reshape(t1,n_los,1);

[t1 t2]=meshgrid(ll_usr(:,1),sat_idx);
latlon(:,1)=reshape(t1,n_los,1);

%calcualte the IPP latitudes and longitudes
ll_ipp=calc_ll_ipp(latlon(idx,:), el(idx), az(idx));

%convert back to degrees
ll_ipp=ll_ipp*180/pi;


