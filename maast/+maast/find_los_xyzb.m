function los_xyzb=find_los_xyzb(xyz_usr, xyz_sat, losmask)

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
%FIND_LOS_XYZB calculates the 4D line of sight vectors
%
%LOS_XYZB=FIND_LOS_XYZB(XYZ_USR, XYZ_SAT)
%   Given n_usr user xyz positions and n_sat satellite xyz positions both in
%   ECEF WGS-84 coordinates (X in first column, Y in second column ...) in 
%   XYZ_USR and XYZ_SAT respectively, this function returns the n_usr*n_sat
%   line of sight unit vectors augmented by a one at the end.  These LOS
%   vectors may then be used to form the position solution.  Optional LOSMASK
%   is a vector of indices (1 to n_usr*n_sat) that specifies which LOS vectors 
%   to selectively compute.
%  
%   See also: FIND_LOS_ENUB

%2001Mar26 Created by Todd Walter
%2001Apr26 Modified by Wyant Chan   -   Added losmask feature
%2009Nov23 Modified by Todd Walter - Changed sign convention

[n_usr tmp]=size(xyz_usr);
[n_sat tmp]=size(xyz_sat);
n_los=n_usr*n_sat;
if (nargin==2)
    losmask = [1:n_los]';
end
n_mask = size(losmask,1);

%initialize 4th column of the line of sight vector
los_xyzb = ones(n_mask,4);

%build the line of sight vector
[t1 t2]=meshgrid(xyz_usr(:,1),xyz_sat(:,1));
t1 = reshape(t1,n_los,1);
t2 = reshape(t2,n_los,1);
los_xyzb(:,1) = t2(losmask) - t1(losmask);

[t1 t2]=meshgrid(xyz_usr(:,2),xyz_sat(:,2));
t1 = reshape(t1,n_los,1);
t2 = reshape(t2,n_los,1);
los_xyzb(:,2) = t2(losmask) - t1(losmask);

[t1 t2]=meshgrid(xyz_usr(:,3),xyz_sat(:,3));
t1 = reshape(t1,n_los,1);
t2 = reshape(t2,n_los,1);
los_xyzb(:,3) = t2(losmask) - t1(losmask);

%normalize first three columns
mag=sqrt(sum(los_xyzb(:,1:3)'.^2))';
los_xyzb(:,1)=los_xyzb(:,1)./mag;
los_xyzb(:,2)=los_xyzb(:,2)./mag;
los_xyzb(:,3)=los_xyzb(:,3)./mag;




