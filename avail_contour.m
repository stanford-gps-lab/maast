function [avail, coverage] =avail_contour(lats, lons, vpl, hpl, isinbnd,percent,vhal,pa_mode)
%*************************************************************************
%*     Copyright c 2007 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%AVAIL_CONTOUR contour plot of the availability
%   AVAIL_CONTOUR(LATS, LONS, VPL, HPL)
%   Given the user latitudes in LATS (n_lats,1) and longitudes in LONS 
%   (n_lons,1) both in degrees between -180 and 180, and a matrix of vpls and
%   hpls in VPL(n_lats*n_lons,n_times) and HPL(n_lats*n_lons,n_times) in meters,
%   this function will plot the contour lines according to intervals specified
%   in INIT_GRAPH using the color scheme specified there as well.  The colors
%   can be changed afterward with calls to COLORMAP.
%
%   SEE ALSO SVM_CONTOUR INIT_GRAPH

%  Created by Todd Walter 18 Apr 2001
%Modified Todd Walter June 28, 2007 to include VAL, HAL and PA vs. NPA mode

global GRAPH_AVAIL_CONTOURS GRAPH_AVAIL_COLORS


n_lats=length(lats);
n_lons=length(lons);
n_levels=size(GRAPH_AVAIL_CONTOURS,2);
n_times=size(vpl,2);

temp=num2str(GRAPH_AVAIL_CONTOURS'*100);
ticklabels(1,:)=['<' temp(2,:) '%'];
for idx=2:n_levels
  ticklabels(idx,:)=['>' temp(idx,:) '%'];
end

%calculate availability
if(pa_mode)
    avail=sum(((vpl <= vhal(1)) & (hpl <= vhal(2)))')'/n_times;
else
    avail=sum(((hpl <= vhal(2)))')'/n_times;
end
%change unity values for graphics scaling
idx=find(avail==1);
if(~isempty(idx))
  avail(idx)=GRAPH_AVAIL_CONTOURS(n_levels)+10*eps;
end

idx=find(avail==0);
if(~isempty(idx))
  avail(idx)=NaN;
end

%calculate coverage
coverage=0;
cos_lats = reshape(repmat(cos(lats*pi/180),n_lons,1),n_lons*n_lats,1);
idx=find((avail >= percent) & isinbnd);
if(~isempty(idx))
  coverage=sum(cos_lats(idx))/sum(isinbnd.*cos_lats);
  coverage=fix(coverage*10000)/100;
end

clf

if(pa_mode)
    bartext = ['Availability with VAL = ' num2str(vhal(1)) ',  HAL = ' ...
			   num2str(vhal(2)) ', Coverage(' num2str(percent*100,3) '%) = '...
               num2str(coverage) '%'];
else
    bartext = ['Availability with HAL = ' num2str(vhal(2)) ...
            ', Coverage(' num2str(percent*100,3) '%) = ' num2str(coverage) '%'];
end

svm_contour(lons,lats,reshape(-log10(1-avail),n_lons,n_lats)', ...
            -log10(1-GRAPH_AVAIL_CONTOURS), ...
            ticklabels, GRAPH_AVAIL_COLORS, ...
		    bartext);


title('Availability as a function of user location');

%ax=axis;
%lon_circ=(ax(2)-ax(1))*cos([.1:.1:2]*pi)'/100;
%lat_circ=(ax(4)-ax(3))*sin([.1:.1:2]*pi)'/100;
%[ulat ulon]=meshgrid(lats,lons);
%ulat=ulat(:);
%ulon=ulon(:);
%n_usr=n_lats*n_lons;
%for idx=1:n_usr
%  patch(lon_circ+ulon(idx),lat_circ+ulat(idx),avail(idx));
%end
