function mapudre(udrei,sat_llh,wrsLL)

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
% function mapudre(udrei,sat_llh,wrsLL)
% Draw contour map of udre
% Inputs:   udrei    - udre indices for each satellite location
%           sat_llh  - the latitiude, longitude and height for each satellite
%                        corresponding to the udreis
%           wrsLL    - list of WRS in lat,lon (degs)

%modified by Todd Walter 05/22/2001

global MOPS_UDRE MOPS_UDREI_NM MOPS_UDREI_DNU
global GRAPH_UDREI_COLORS



svlat = [-55:5:55];
svlon = [-180:5:179];
[t1,t2] = meshgrid(svlat,svlon);
gridlat = t1(:);
gridlon = t2(:);
gridudrei = griddata(sat_llh(:,2),sat_llh(:,1),udrei(:),gridlon,gridlat,...
                     'nearest');

nlat = length(svlat);
nlon = length(svlon);

ticklabels=num2str(MOPS_UDRE', 3);
ticklabels(MOPS_UDREI_NM,:)=' NM ';
ticklabels(MOPS_UDREI_DNU,:)='DNU ';

clf
bartext = ['UDRE (m)'];

svm_contour(svlon,svlat,reshape(gridudrei,nlon,nlat)', ...
            1:MOPS_UDREI_DNU, ticklabels, GRAPH_UDREI_COLORS, bartext, ...
            'vert')

axis([-180 180 -90 90]);
ax=axis;

%lon_circ=(ax(2)-ax(1))*cos([.1:.1:2]*pi)'/100;
%lat_circ=(ax(4)-ax(3))*sin([.1:.1:2]*pi)'/100;
%n_udrei=size(udrei,1);
%for idx=1:n_udrei
%  patch(lon_circ+sat_llh(idx,2),lat_circ+sat_llh(idx,1),udrei(idx));
%end

title('UDRE values');

orient landscape

