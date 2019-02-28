function los_enub=find_los_enub(los_xyzb, usr_ehat, usr_nhat, usr_uhat, losmask)

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
%FIND_LOS_ENUB converts 4D line of sight vectors from XYZ to East North Up
%
%LOS_ENUB=FIND_LOS_XYZB(LOS_XYZB, USR_EHAT, USR_NHAT, USR_UHAT);
%   Given n_los line of sight vectors in ECEF WGS-84 coordinates (X in first
%   column, Y in second column, Z in the third column and 1 in the fourth) in
%   LOS_XYZB and n_usr east, north, and up unit vectors (at the user location)
%   in E_HAT, N_HAT, and U_HAT respectively this function returns the n_los
%   line of sight unit vectors augmented by a one at the end in the East, North
%   and Up frame.  These LOS vectors may then be used to form the position
%   solution.  Optional LOSMASK is a vector of indices (1 to n_usr*n_sat) 
%   that specifies which LOS vectors to selectively compute.
%  
%   See also: FIND_LOS_XYZB CALC_LOS_ENUB

%2001Mar26 Created by Todd Walter
%2001Apr26 Modified by Wyant Chan   -   Added losmask feature

[n_los tmp]=size(los_xyzb);
[n_usr tmp]=size(usr_ehat);
n_sat=n_los/n_usr;
if (nargin==4)
    losmask = [1:n_los]';
end
n_mask = size(losmask,1);    
sat_idx=1:n_sat;

%expand the user east unit vector to match the lines of sight
[t1 t2]=meshgrid(usr_ehat(:,3),sat_idx);
e_hat(:,3)=reshape(t1,n_los,1);

[t1 t2]=meshgrid(usr_ehat(:,2),sat_idx);
e_hat(:,2)=reshape(t1,n_los,1);

[t1 t2]=meshgrid(usr_ehat(:,1),sat_idx);
e_hat(:,1)=reshape(t1,n_los,1);


%expand the user north unit vector to match the lines of sight
[t1 t2]=meshgrid(usr_nhat(:,3),sat_idx);
n_hat(:,3)=reshape(t1,n_los,1);

[t1 t2]=meshgrid(usr_nhat(:,2),sat_idx);
n_hat(:,2)=reshape(t1,n_los,1);

[t1 t2]=meshgrid(usr_nhat(:,1),sat_idx);
n_hat(:,1)=reshape(t1,n_los,1);


%expand the user up unit vector to match the lines of sight
[t1 t2]=meshgrid(usr_uhat(:,3),sat_idx);
u_hat(:,3)=reshape(t1,n_los,1);

[t1 t2]=meshgrid(usr_uhat(:,2),sat_idx);
u_hat(:,2)=reshape(t1,n_los,1);

[t1 t2]=meshgrid(usr_uhat(:,1),sat_idx);
u_hat(:,1)=reshape(t1,n_los,1);

%calculate the LOS vectors in the ENU frame
los_enub=calc_los_enub(los_xyzb(losmask,:), ...
        e_hat(losmask,:), n_hat(losmask,:), u_hat(losmask,:));




