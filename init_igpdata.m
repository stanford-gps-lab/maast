function [igpdata,inv_igp_mask] = init_igpdata(igpfile)

%*************************************************************************
%*     Copyright c 2020 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% Created by Todd Walter 2001 Mar (init_igps.m)
% Modifications:    
%   Wyant Chan 2001 Apr 9 
%   1) Modified output data format to comply with svm analysis format 
%   2) Input is mask file instead of the actual igp mask
%   3) llh2xyz is converted to the degrees version.  

global CONST_H_IONO;
global COL_IGP_BAND COL_IGP_ID COL_IGP_LL COL_IGP_XYZ COL_IGP_WORKSET ...
        COL_IGP_EHAT COL_IGP_NHAT COL_IGP_MAGLAT COL_IGP_CORNERDEN ...
        COL_IGP_FLOORI COL_IGP_MAX
igpraw = sortrows(load(igpfile),[1,2]);
igp_mask = igpraw(:,3:4);


%convert to radians
igp_mask_rad=igp_mask*pi/180;
n_igp = size(igp_mask,1);
iono_h = repmat(CONST_H_IONO,n_igp,1);

%compute the ECEF XYZ positions of the IGPs
xyz_igp=llh2xyz([igp_mask(:,1),igp_mask(:,2),iono_h]);

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
%TODO make this dynamic from the mask rather than hardcoded for WAAS
ll_give=([igp_mask(:,1)+2.5 igp_mask(:,2)+2.5 ...
          igp_mask(:,1)+2.5 igp_mask(:,2)-2.5 ...
          igp_mask(:,1)-2.5 igp_mask(:,2)+2.5 ...
          igp_mask(:,1)-2.5 igp_mask(:,2)-2.5]);
%look for band 9 IGPs
if ~any(igpraw(:,1) == 9)
    %adjust IGPs at or above 55 degrees for larger cells
    idx=find(igp_mask(:,1)==55);
    if ~isempty(idx)
        ll_give(idx,:)=([igp_mask(idx,1)+5.0 igp_mask(idx,2)+5.0 ...
                         igp_mask(idx,1)+5.0 igp_mask(idx,2)-5.0 ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)+2.5 ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)-2.5]);
    end
    idx=find(igp_mask(:,1)>55);
    if ~isempty(idx)
        ll_give(idx,:)=([igp_mask(idx,1)+5.0 igp_mask(idx,2)+5.0 ...
                         igp_mask(idx,1)+5.0 igp_mask(idx,2)-5.0 ...
                         igp_mask(idx,1)-5.0 igp_mask(idx,2)+5.0 ...
                         igp_mask(idx,1)-5.0 igp_mask(idx,2)-5.0]);
    end
else
    %adjust IGPs at or above 60 degrees for larger cells
    idx=find(igp_mask(:,1)==60 & mod(igp_mask(:,2),10)==0);
    if ~isempty(idx)
        ll_give(idx,:)=([igp_mask(idx,1)+2.5 igp_mask(idx,2)+5.0 ...
                         igp_mask(idx,1)+2.5 igp_mask(idx,2)-5.0 ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)+2.5 ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)-2.5]);
    end
    idx=find(igp_mask(:,1)==60 & mod(igp_mask(:,2),10)~=0);    
    if ~isempty(idx)
        ll_give(idx,:)=([igp_mask(idx,1)     igp_mask(idx,2)     ...
                         igp_mask(idx,1)     igp_mask(idx,2)     ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)+2.5 ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)-2.5]);
    end
    idx=find(igp_mask(:,1)>60);
    if ~isempty(idx)
        ll_give(idx,:)=([igp_mask(idx,1)+2.5 igp_mask(idx,2)+5.0 ...
                         igp_mask(idx,1)+2.5 igp_mask(idx,2)-5.0 ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)+5.0 ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)-5.0]);
    end
    %adjust IGPs at or above 75 degrees for larger cells
    idx=find(igp_mask(:,1)==75 & mod(igp_mask(:,2),30)==0);
    if ~isempty(idx)
        ll_give(idx,:)=([igp_mask(idx,1)+5.0 igp_mask(idx,2)+15.0 ...
                         igp_mask(idx,1)+5.0 igp_mask(idx,2)-15.0 ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)+5.0 ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)-5.0]);
    end
    idx=find(igp_mask(:,1)==75 & mod(igp_mask(:,2),30)~=0);    
    if ~isempty(idx)
        ll_give(idx,:)=([igp_mask(idx,1)     igp_mask(idx,2)     ...
                         igp_mask(idx,1)     igp_mask(idx,2)     ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)+5.0 ...
                         igp_mask(idx,1)-2.5 igp_mask(idx,2)-5.0]);
    end
    idx=find(igp_mask(:,1)>75);
    if ~isempty(idx)
        ll_give(idx,:)=([igp_mask(idx,1)     igp_mask(idx,2)      ...
                         igp_mask(idx,1)     igp_mask(idx,2)      ...
                         igp_mask(idx,1)-5.0 igp_mask(idx,2)+15.0 ...
                         igp_mask(idx,1)-5.0 igp_mask(idx,2)-15.0]);
    end    
end
xyz_give=[llh2xyz([ll_give(:,1),ll_give(:,2),iono_h]) ...
              llh2xyz([ll_give(:,3),ll_give(:,4),iono_h]) ...
              llh2xyz([ll_give(:,5),ll_give(:,6),iono_h]) ...
              llh2xyz([ll_give(:,7),ll_give(:,8),iono_h])];
del_xyz=xyz_give-[xyz_igp xyz_igp xyz_igp xyz_igp];

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

igpdata = zeros(n_igp,COL_IGP_MAX);
igpdata(:,COL_IGP_BAND) = igpraw(:,1);
igpdata(:,COL_IGP_ID) = igpraw(:,2);
igpdata(:,COL_IGP_LL) = igp_mask;
igpdata(:,COL_IGP_XYZ) = xyz_igp;
igpdata(:,COL_IGP_WORKSET) = igpraw(:,5);
igpdata(:,COL_IGP_EHAT) = igp_en_hat(:,1:3);
igpdata(:,COL_IGP_NHAT) = igp_en_hat(:,4:6);
igpdata(:,COL_IGP_MAGLAT) = igp_mag_lat;
igpdata(:,COL_IGP_CORNERDEN) = reshape(igp_corner_den,12,n_igp)';
if size(igpraw,2) > 5
    igpdata(:,COL_IGP_FLOORI) = igpraw(:,6)+1;
else
    igpdata(:,COL_IGP_FLOORI) = 1;
end
