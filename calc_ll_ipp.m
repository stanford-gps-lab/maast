function ll_ipp=calc_ll_ipp(ll_usr, el, az)

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
%CALC_LL_IPP calculates the latitude & longitude of the IPPs
%
%LL_IPP=CALC_LL_IPP(LL_USR, EL, AZ);
%   Given the latitude and longitude of the user locations (in radianss) in
%   LL_USR and the elevation and azimuth angles (in radians) to the different
%   satellites, this function returns the latitudes and longitudes of the
%   Ionospheric Pierce Points (in radians)
%
%   See also: FIND_LL_IPP FIND_EL_AZ

%2001Mar26 Created by Todd Walter

global CONST_R_E CONST_R_IONO

%initialize return value
ll_ipp=ll_usr;

%calcualte earth angle
psi_pp=0.5*pi-el-asin(CONST_R_E*cos(el)/CONST_R_IONO);
sin_psi_pp=sin(psi_pp);

%calulate IPP latitude
ll_ipp(:,1)=asin(sin(ll_usr(:,1)).*cos(psi_pp) +...
                 cos(ll_usr(:,1)).*sin_psi_pp.*cos(az));

%calulate IPP longitude
ll_ipp(:,2)=ll_usr(:,2) + asin(sin_psi_pp.*sin(az)./cos(ll_ipp(:,1)));

%[ll_usr el az ll_ipp]*180/pi
