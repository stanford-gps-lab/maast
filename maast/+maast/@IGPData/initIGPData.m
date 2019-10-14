function [] = initIGPData(obj,igpfile)
% Function created mostly from original code that was used to create
% IGPData. To be replaced at a later date.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast
    
maastConstants = maast.constants.MAASTConstants;
ionoAlt = maastConstants.IonoAlt;
    
igpraw = sortrows(load(igpfile),[3,4]);
igp_mask = igpraw(:,3:4);


%convert to radians
igp_mask_rad=igp_mask*pi/180;
n_igp = size(igp_mask,1);
iono_h = repmat(ionoAlt,n_igp,1);

%compute the ECEF XYZ positions of the IGPs
xyz_igp=sgt.tools.llh2ecef([igp_mask(:,1),igp_mask(:,2),iono_h]);

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
B9 = find(igpraw(:,1) == 9);
if isempty(B9)
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
xyz_give=[sgt.tools.llh2ecef([ll_give(:,1),ll_give(:,2),iono_h]) ...
              sgt.tools.llh2ecef([ll_give(:,3),ll_give(:,4),iono_h]) ...
              sgt.tools.llh2ecef([ll_give(:,5),ll_give(:,6),iono_h]) ...
              sgt.tools.llh2ecef([ll_give(:,7),ll_give(:,8),iono_h])];
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

% Set properties
obj.Band = igpraw(:,1);
obj.ID = igpraw(:,2);
obj.IGPMask = igp_mask;
obj.InvIGPMask = inv_igp_mask;
obj.Workset = igpraw(:,5);
obj.Ehat = igp_en_hat(:,1:3);
obj.Nhat = igp_en_hat(:,4:6);
obj.MagLat = igp_mag_lat;
obj.CornerDen = reshape(igp_corner_den,12,n_igp)';

% igpdata(:,COL_IGP_XYZ) = xyz_igp;
% igpdata(:,COL_IGP_WORKSET) = igpraw(:,5);
% igpdata(:,COL_IGP_CORNERDEN) = reshape(igp_corner_den,12,n_igp)';
% if size(igpraw,2) > 5
%     igpdata(:,COL_IGP_FLOORI) = igpraw(:,6)+1;
% else
%     igpdata(:,COL_IGP_FLOORI) = 1;
% end
end

function inv_IGPmask=find_inv_IGPmask(IGPmask)

NOT_IN_MASK=-12;
IGPmask_min_lat=-85;
IGPmask_max_lat=85;

IGPmask_min_lon=0;
IGPmask_max_lon=355;

IGPmask_increment=5;

%set all values as not being in the mask
inv_IGPmask=ones(length(IGPmask_min_lat:IGPmask_increment:...
                    IGPmask_max_lat), length(IGPmask_min_lon:...
                    IGPmask_increment:IGPmask_max_lon))*NOT_IN_MASK;

%convert the latitudes and longitues to 5 degree integer values
mask_idx=round(IGPmask(:,1:2)/IGPmask_increment);

%make sure the longitudes run 0 to 360 degrees
mask_idx(:,2)=mod(mask_idx(:,2),360/IGPmask_increment)+1;

% adjust the latitude indicies to run from 1 to N
mask_idx(:,1)=mask_idx(:,1)-IGPmask_min_lat/IGPmask_increment + 1;

%set the IGP numbers
num_IGP=length(IGPmask);
%create the inverse mask
inv_IGPmask(sub2ind(size(inv_IGPmask),mask_idx(:,1),mask_idx(:,2)))=...
           (1:num_IGP)';

%Repeat matrix to handle wrap around at 360
inv_IGPmask = [inv_IGPmask inv_IGPmask(:,1:18)];

end
