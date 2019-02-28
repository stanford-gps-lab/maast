function los_enub=calc_los_enub(los_xyzb, e_hat, n_hat, u_hat)

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
%CALC_LOS_ENUB converts 4D line of sight vectors from XYZ to East North Up
%
%LOS_ENUB=CALC_LOS_XYZB(LOS_XYZB, E_HAT, N_HAT, U_HAT);
%   Given n_los line of sight vectors in ECEF WGS-84 coordinates (X in first
%   column, Y in second column, Z in the third column and 1 in the fourth) in
%   LOS_XYZB and n_los east, north, and up unit vectors (at the user location)
%   in E_HAT, N_HAT, and U_HAT respectively this function returns the n_los
%   line of sight unit vectors augmented by a one at the end in the East, North
%   and Up frame.  These LOS vectors may then be used to form the position
%   solution.
%
%   See also: FIND_LOS_XYZB FIND_LOS_ENUB

%2001Mar26 Created by Todd Walter
%2009Nov23 Modified by Todd Walter - Changed sign convention

%initialize 4th column of the line of sight vector
los_enub(:,4)=los_xyzb(:,4);

%dot the east unit vector with the los vector to determine -cos(elev)*sin(azim)
los_enub(:,1)=sum((-e_hat.*los_xyzb(:,1:3))')';

%dot the north unit vector with the los vector to determine -cos(elev)cos(azim)
los_enub(:,2)=sum((-n_hat.*los_xyzb(:,1:3))')';

%dot the up unit vector with the los vector to determine -sin(elevation)
los_enub(:,3)=sum((-u_hat.*los_xyzb(:,1:3))')';


