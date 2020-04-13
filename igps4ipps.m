function [IGPs, xyIPP, nBadIGPs]=igps4ipps(ll_ipp, IGPmask, inv_IGPmask)
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
%IGP4IPPS   determines if IPP is inside the IGP mask and finds IGP numbers
%[IGPS, XYIPP, NBADIGPS]=IGPS4IPPS(LL_IPP, IGPMASK, INV_IGPMASK)
%   Given nIPPs of Ionospheric Pierce Point (IPP) latitudes (first column)
%   and longitudes (second column) in LL_IPP(nIPPs,2), an Ionospheric Grid
%   Point (IGP) mask containing nIGPs latitudes (first column) and longitudes
%   (second column) in IGPMASK(nIGPs,2), and an inverse of the IGPMASK,
%   this function will determine the four IGP numbers for each IPP and put it
%   in IGPS(nIPPs,4), it will determine the x and y position of the IPP within
%   the square (each 0 to 1) for use in determining weighting put into
%   XYIPP(nIPPs,2), and the number of needed IGPs that are not in the mask
%   NBADIGPS.  Any IPP that has 1 or fewer bad IGPs is contained within the
%   grid and can be interpolated.  0 bad indicates that all four are defined in
%   the mask, 1 indicates that 3 of the 4 are defined and the IPP is inside the
%   corresponding triangle  and 2 or more indicates it is contained in neither
%   a triangle or a square.  Bad IGPs will be marked as MOPS_NOT_IN_MASK.
%
%   See also:  CHECKIGPSQUARE INTRIANGLE GRID2UIVE FIND_INV_IGPMASK

%2001Feb28 Created by Todd Walter
global MOPS_NOT_IN_MASK;
IGPmask_min_lat=-85;
IGPmask_max_lat=85;

IGPmask_min_lon=0;
IGPmask_max_lon=355;

IGPmask_increment=5;

%initialize return values
[nIPPs temp]=size(ll_ipp);
IGPs=ones(nIPPs,4)*MOPS_NOT_IN_MASK;
xyIPP=zeros(nIPPs,2);
nBadIGPs=ones(nIPPs,1)*4;

%make sure the longitudes run 0 to 360 degrees
ll_ipp(:,2)=mod(ll_ipp(:,2)+360,360);

%convert the latitudes and longitues to 5 degree integer values for SW corner
mask_idx=floor(ll_ipp/IGPmask_increment);
mask_idx(:,2)=mod(mask_idx(:,2),360/IGPmask_increment)+1;

% adjust the latitude indicies to run from 1 to N
mask_idx(:,1)=mask_idx(:,1)-IGPmask_min_lat/IGPmask_increment + 1;

%compute for 5x5 region
idx=find(abs(ll_ipp(:,1))<=60.0);
if(~isempty(idx))

  %Start with 5x5 interpolation
  [IGPs(idx,:) xyIPP(idx,:) nBadIGPs(idx)]=check_igpsquare(ll_ipp(idx,:),...
                         mask_idx(idx,:), inv_IGPmask, 5, 5, 0, 0);

  % are there points that were not in 5x5 masking, if yes look for 10x10
  bad_idx=find(nBadIGPs(idx)>1);

  if(~isempty(bad_idx))
    bad_idx=idx(bad_idx);
    %Try 10x10 interpolation with odd latitude and even longitude
    tmp_mask_idx=mask_idx(bad_idx,:);
    evenlat=find(~mod(tmp_mask_idx(:,1),2));
    if(~isempty(evenlat))
      tmp_mask_idx(evenlat,1)=tmp_mask_idx(evenlat,1)-1;
    end
    oddlon=find(~mod(tmp_mask_idx(:,2),2));
    if(~isempty(oddlon))
      tmp_mask_idx(oddlon,2)=tmp_mask_idx(oddlon,2)-1;
    end
    [IGPs(bad_idx,:) xyIPP(bad_idx,:) nBadIGPs(bad_idx)]=check_igpsquare(...
                   ll_ipp(bad_idx,:), tmp_mask_idx, inv_IGPmask, 10, 10, 5, 0);
  end  

  %TODO add other combinations
end

%compute for 5x10 region
idx=find(abs(ll_ipp(:,1)) > 60.0 & abs(ll_ipp(:,1))<75.0);
if(~isempty(idx))

  %Start with 5x10 interpolation
  oddlon=find(~mod(mask_idx(idx,2),2));
  if(~isempty(oddlon))
    mask_idx(idx(oddlon),2)=mask_idx(idx(oddlon),2)-1;
  end
  [IGPs(idx,:) xyIPP(idx,:) nBadIGPs(idx)]=check_igpsquare(ll_ipp(idx,:),...
                         mask_idx(idx,:), inv_IGPmask, 5, 10, 0, 0);

  % are there points that were not in 5x10 masking, if yes look for 10x10
  bad_idx=find(nBadIGPs(idx)>1);

  if(~isempty(bad_idx))
    bad_idx=idx(bad_idx);
    %Use 10x10 interpolation with odd latitude and even longitude
    tmp_mask_idx=mask_idx(bad_idx,:);
    evenlat=find(~mod(tmp_mask_idx(:,1),2));
    if(~isempty(evenlat))
      tmp_mask_idx(evenlat,1)=tmp_mask_idx(evenlat,1)-1;
    end
    [IGPs(bad_idx,:) xyIPP(bad_idx,:) nBadIGPs(bad_idx)]=check_igpsquare(...
                   ll_ipp(bad_idx,:), tmp_mask_idx, inv_IGPmask, 10, 10, 5, 0);
  end  
end


%compute for 75 to 85 region 
idx=find(ll_ipp(:,1) >= 75.0 & ll_ipp(:,1)<85.0);
if(~isempty(idx))

  %Start with 10x30 box
  oddlon=find(~mod(mask_idx(idx,2),2));
  if(~isempty(oddlon))
    mask_idx(idx(oddlon),2)=mask_idx(idx(oddlon),2)-1;
  end
  evenlat=find(~mod(mask_idx(idx,1),2));
  if(~isempty(evenlat))
    mask_idx(idx(evenlat),1)=mask_idx(idx(evenlat),1)-1;
  end

  %find 30 degree longitude separations
  mask30_idx=floor(ll_ipp(idx,2)/30)*6 + 1;

  mask_size=size(inv_IGPmask);
  %specify the SW, SE, NE and then NW corners
  IGPs(idx,1)=inv_IGPmask(sub2ind(mask_size,mask_idx(idx,1),mask_idx(idx,2)));
  IGPs(idx,2)=inv_IGPmask(sub2ind(mask_size,mask_idx(idx,1),...
                                            mask_idx(idx,2) + 2));
  IGPs(idx,3)=inv_IGPmask(sub2ind(mask_size,mask_idx(idx,1) + 2,...
                                            mod(mask30_idx + 6, 72)));
  IGPs(idx,4)=inv_IGPmask(sub2ind(mask_size,mask_idx(idx,1) + 2,...
                                            mask30_idx));

  % calculate the x and y for the SW corner
  xyIPP(idx,2)=rem(360+ll_ipp(idx,1)-5, 10)/10;
  xyIPP(idx,1)=rem(360+ll_ipp(idx,2), 10)/10;

  % check for bad IGPs
  nBadIGPs(idx)=0;
  [badcorner badipp]=find(IGPs(idx,:)'==MOPS_NOT_IN_MASK);
  if(~isempty(badipp))
    %determine the number of bad IGPs per IPP
    bad_idx=[1 find(diff(badipp))'+1];
    nBadIGPs(idx(badipp(bad_idx)))=diff([bad_idx length(badipp)+1]);
  end

  %if not 4 points look for 90 degree separation
  mask08=find(nBadIGPs(idx) > 0);
  if(~isempty(mask08))
    %find 90 degree longitude separations
    mask90_idx=floor(ll_ipp(idx(mask08),2)/90)*18 + 1;

    %specify the SW, SE, NE and then NW corners
    IGPs(idx(mask08),1)=inv_IGPmask(...
     sub2ind(mask_size,mask_idx(idx(mask08),1),mask_idx(idx(mask08),2)));
    IGPs(idx(mask08),2)=inv_IGPmask(...
     sub2ind(mask_size,mask_idx(idx(mask08),1), mask_idx(idx(mask08),2) + 2));
    IGPs(idx(mask08),3)=inv_IGPmask(...
     sub2ind(mask_size,mask_idx(idx(mask08),1) + 2, mod(mask90_idx + 18, 72)));
    IGPs(idx(mask08),4)=inv_IGPmask(...
     sub2ind(mask_size,mask_idx(idx(mask08),1) + 2, mask90_idx));

    % calculate the x and y for the SW corner
    xyIPP(idx(mask08),2)=rem(360+ll_ipp(idx(mask08),1)-5, 10)/10;
    xyIPP(idx(mask08),1)=rem(360+ll_ipp(idx(mask08),2), 10)/10;

    % check for bad IGPs
    nBadIGPs(idx(mask08))=0;
    [badcorner badipp]=find(IGPs(idx(mask08),:)'==MOPS_NOT_IN_MASK);
    if(~isempty(badipp))
      %determine the number of bad IGPs per IPP
      bad_idx=[1 find(diff(badipp))'+1];
      nBadIGPs(idx(mask08(badipp(bad_idx))))=diff([bad_idx length(badipp)+1]);
    end
  end
end

%TODO add calculation for -75 to -85

%TODO finish calculation for above 85 region

%compute for 85 degrees and above
i=find(ll_ipp(:,1)>85.0);
if(~isempty(i))

  %specify the 4 IGPs
  lat_idx=85/IGPmask_increment - IGPmask_min_lat/IGPmask_increment + 1;
  lon_idx = floor(ll_ipp(i,2)/90.0)*90.0;
  IGPs(i,1)=inv_IGPmask(lat_idx,rem(lon_idx+180,360)/IGPmask_increment + 1);
  IGPs(i,2)=inv_IGPmask(lat_idx,rem(lon_idx+270,360)/IGPmask_increment + 1);
  IGPs(i,3)=inv_IGPmask(lat_idx,lon_idx/IGPmask_increment + 1);
  IGPs(i,4)=inv_IGPmask(lat_idx,rem(lon_idx+90,360)/IGPmask_increment + 1);

  % calculate the x and y for the SW corner
  xyIPP(i,2)=(ll_ipp(i,1)-85.0)/10.0;
  xyIPP(i,1)=((ll_ipp(i,2)-lon_idx)/90).*(1 - 2*xyIPP(i,2)) + xyIPP(i,2);

  % check for number in the mask 
  nBadIGPs(i) = sum((IGPs(i,:)'==MOPS_NOT_IN_MASK))';
end

%compute for -85 degrees and below
i=find(ll_ipp(:,1)<-85.0);
if(~isempty(i))

  %specify the 4 IGPs
  lat_idx=-85/IGPmask_increment - IGPmask_min_lat/IGPmask_increment + 1;
  IGPs(i,1)=inv_IGPmask(lat_idx,220/IGPmask_increment + 1);
  IGPs(i,2)=inv_IGPmask(lat_idx,310/IGPmask_increment + 1);
  IGPs(i,3)=inv_IGPmask(lat_idx,40/IGPmask_increment + 1);
  IGPs(i,4)=inv_IGPmask(lat_idx,130/IGPmask_increment + 1);
end
