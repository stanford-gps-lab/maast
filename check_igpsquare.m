function [IGPs, xyIPP, nBadIGPs]=check_igpsquare(ll_ipp, mask_idx, inv_IGPmask, lat_spacing, lon_spacing, lat_base, lon_base)
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
%CHECK_IGPSQUARE   determines if IPP is in a square or triangle of the IGP mask
%[IGPS, XYIPP, NBADIGPS]=CHECK_IGPSQUARE(LL_IPP, MASK_IDX, INV_IGPMASK, 
%                                 LAT_SPACING, LON_SPACING, LAT_BASE, LON_BASE)
%   Given nIPPs of Ionospheric Pierce Point (IPP) latitudes (first column)
%   and longitudes (second column) in LL_IPP(nIPPs,2), a matrix of indicies for
%   the inverse mask corresponding to LL_IPP, an inverse of the IGPMASK, the
%   latitude and longitude spacings for the square we are checking and the
%   base latitudes and longitudes for this square, this function will
%   determine the four IGP numbers for each IPP and put it in IGPS(nIPPs,4),
%   it will determine the x and y position of the IPP within the square
%   (each 0 to 1) for use in determining weighting put into XYIPP(nIPPs,2),
%   and the number of needed IGPs that are not in the mask NBADIGPS.  Any IPP
%   that has 1 or fewer bad IGPs is contained within the grid and can be
%   interpolated.  0 bad indicates that all four are defined in the mask,
%   1 indicates that 3 of the 4 are defined and the IPP is inside the
%   corresponding triangle  and 2 or more indicates it is contained in neither
%   a triangle or a square.  Bad IGPs will be marked as NOT_IN_MASK in IGPS.
%
%   See also:  IGPFORIPPS INTRIANGLE GRID2UIVE FIND_INV_IGPMASK

%2001Feb28 Created by Todd Walter




global MOPS_NOT_IN_MASK;

%initialize return values
[nIPPs temp]=size(ll_ipp);
IGPs=repmat(MOPS_NOT_IN_MASK,nIPPs,4);
xyIPP=zeros(nIPPs,2);
nBadIGPs=zeros(nIPPs,1);

mask_size=size(inv_IGPmask);

%specify the SW, SE, NE and then NW corners
IGPs(:,1)=inv_IGPmask(sub2ind(mask_size,mask_idx(:,1),mask_idx(:,2)));
IGPs(:,2)=inv_IGPmask(sub2ind(mask_size,mask_idx(:,1),...
                                        mask_idx(:,2) + lon_spacing/5));
IGPs(:,3)=inv_IGPmask(sub2ind(mask_size,mask_idx(:,1) + lat_spacing/5,...
                                        mask_idx(:,2) + lon_spacing/5));
IGPs(:,4)=inv_IGPmask(sub2ind(mask_size,mask_idx(:,1) + lat_spacing/5,...
                                        mask_idx(:,2)));

% calculate the x and y for the SW corner
xyIPP(:,2)=rem(360+ll_ipp(:,1)-lat_base,lat_spacing)/lat_spacing;
xyIPP(:,1)=rem(360+ll_ipp(:,2)-lon_base,lon_spacing)/lon_spacing;

% check for at least 3 in the mask 
%[badcorner badipp]=find(IGPs'==MOPS_NOT_IN_MASK);
[badcorner badipp]=find(IGPs'==MOPS_NOT_IN_MASK);
if(~isempty(badipp))
  %determine the number of bad IGPs per IPP
  bad_idx=[1 find(diff(badipp))'+1];
  nBadIGPs(badipp(bad_idx))=diff([bad_idx length(badipp)+1]);

  %if just one bad IPP try triangular interpolation
  mask3=find(nBadIGPs==1);
  if(~isempty(mask3))
    inv_badipp(badipp)=(1:length(badipp))';
    out=find(~intriangle(xyIPP(mask3,1),xyIPP(mask3,2),...
                                        badcorner(inv_badipp(mask3))));
    if(~isempty(out))
        nBadIGPs(mask3(out))=2;
    end
  end
end

