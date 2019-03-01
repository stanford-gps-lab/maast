function inv_IGPmask=find_inv_IGPmask(IGPmask)
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
%FIND_INV_IGPMASK  create a matrix to determine IGP number given lat and lon
%INV_IGPMASK=FIND_INV_IGPMASK(IGPMASK)
%   Given an Ionospheric Grid Point (IGP) mask containing nIGPs latitudes
%   (first column) and longitudes (second column) in IGPMASK(nIGPs,2), this
%   function creates a 35x72 matrix that points back to the IGP number. 
%   The matrix is latitude divided by 5 deg + 18 for rows and longitude 
%   (0 to 355) divided by 5 for columns.  The matrix entries are the index for
%   the corresponding IGP or NOT_IN_MASK if the IGP is not activated.
%
%   See also: GRID2UIVE IGPFORIPPS INTRIANGLE CHECKIGPSQUARE 

%2001Feb28 Created by Todd Walter


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

