function [xyz_igp, igp_en_hat, igp_corner_den, igp_mag_lat, inv_igp_mask] =...
         init_igps(igp_mask)

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
global CONST_H_IONO;

%convert to radians
igp_mask_rad=igp_mask*pi/180;

%compute the ECEF XYZ positions of the IGPs
xyz_igp=llh2xyz(igp_mask_rad(:,1),igp_mask_rad(:,2), CONST_H_IONO);

%calculate east and north unit vectors for each IGP
cos_lat=cos(igp_mask_rad(:,1));
sin_lat=sin(igp_mask_rad(:,1));
cos_lon=cos(igp_mask_rad(:,2));
sin_lon=sin(igp_mask_rad(:,2));
igp_en_hat(:,6)=cos_lat;
igp_en_hat(:,5)=-sin_lat.*sin_lon;
igp_en_hat(:,4)=-sin_lat.*cos_lon;
igp_en_hat(:,3)=0*igp_en_hat(:,4);
igp_en_hat(:,2)=cos_lon;
igp_en_hat(:,1)=-sin_lon;

%calculate lat and lon for cell centers surrounding grid
%TODO make this dynamic from the mask rahter than hardcoded for WAAS
ll_give=([igp_mask(:,1)+2.5 igp_mask(:,2)+2.5 ...
          igp_mask(:,1)+2.5 igp_mask(:,2)-2.5 ...
          igp_mask(:,1)-2.5 igp_mask(:,2)+2.5 ...
          igp_mask(:,1)-2.5 igp_mask(:,2)-2.5])*pi/180;
%adjust IGPs at or above 55 degrees for larger cells
idx=find(igp_mask(:,1)==55);
ll_give(idx,:)=([igp_mask(idx,1)+5.0 igp_mask(idx,2)+5.0 ...
                 igp_mask(idx,1)+5.0 igp_mask(idx,2)-5.0 ...
                 igp_mask(idx,1)-2.5 igp_mask(idx,2)+2.5 ...
                 igp_mask(idx,1)-2.5 igp_mask(idx,2)-2.5])*pi/180;
idx=find(igp_mask(:,1)>55);
ll_give(idx,:)=([igp_mask(idx,1)+5.0 igp_mask(idx,2)+5.0 ...
                 igp_mask(idx,1)+5.0 igp_mask(idx,2)-5.0 ...
                 igp_mask(idx,1)-5.0 igp_mask(idx,2)+5.0 ...
                 igp_mask(idx,1)-5.0 igp_mask(idx,2)-5.0])*pi/180;
xyz_give=[llh2xyz(ll_give(:,1),ll_give(:,2),CONST_H_IONO) ...
          llh2xyz(ll_give(:,3),ll_give(:,4),CONST_H_IONO) ...
          llh2xyz(ll_give(:,5),ll_give(:,6),CONST_H_IONO) ...
          llh2xyz(ll_give(:,7),ll_give(:,8),CONST_H_IONO)];
del_xyz=xyz_give-[xyz_igp xyz_igp xyz_igp xyz_igp];

[n_igp temp]=size(igp_mask);
igp_corner_den=ones(4,3,n_igp);
igp_corner_den(1,2,:)=sum((del_xyz(:,1:3).*igp_en_hat(:,1:3))')'*1e-6;
igp_corner_den(1,3,:)=sum((del_xyz(:,1:3).*igp_en_hat(:,4:6))')'*1e-6;
igp_corner_den(2,2,:)=sum((del_xyz(:,4:6).*igp_en_hat(:,1:3))')'*1e-6;
igp_corner_den(2,3,:)=sum((del_xyz(:,4:6).*igp_en_hat(:,4:6))')'*1e-6;
igp_corner_den(3,2,:)=sum((del_xyz(:,7:9).*igp_en_hat(:,1:3))')'*1e-6;
igp_corner_den(3,3,:)=sum((del_xyz(:,7:9).*igp_en_hat(:,4:6))')'*1e-6;
igp_corner_den(4,2,:)=sum((del_xyz(:,10:12).*igp_en_hat(:,1:3))')'*1e-6;
igp_corner_den(4,3,:)=sum((del_xyz(:,10:12).*igp_en_hat(:,4:6))')'*1e-6;

%find the magnetic latitude (see ICD-200)
igp_mag_lat=igp_mask(:,1) + 0.064*180*cos(igp_mask_rad(:,2)-1.617*pi);

%find the inverse IGP mask
inv_igp_mask=find_inv_IGPmask(igp_mask);

