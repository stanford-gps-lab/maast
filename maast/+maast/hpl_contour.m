function hpl_contour(lats, lons, vpl,percent)
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
%HPL_CONTOUR contour plot of the horizontal protection level
%   HPL_CONTOUR(LATS, LONS, HPL)
%   Given the user latitudes in LATS (n_lats,1) and longitudes in LONS 
%   (n_lons,1) both in degrees between -180 and 180, and a vector of hpls in
%   HPL(n_lats*n_lons,1) in meters, this function will plot the contour lines
%   according to intervals specified in INIT_GRAPH using the color scheme
%   specified there as well.  The colors can be changed afterward with calls
%   to COLORMAP.
%
%   SEE ALSO SVM_CONTOUR INIT_GRAPH

%  Created by Todd Walter 02 Apr 2001

global GRAPH_HPL_CONTOURS GRAPH_HPL_COLORS

n_lats=length(lats);
n_lons=length(lons);
n_levels=size(GRAPH_HPL_CONTOURS,2);

temp=num2str(GRAPH_HPL_CONTOURS');
ticklabels(n_levels,:)=['> ' temp(n_levels,:)];
for idx=1:n_levels-1
  ticklabels(idx,:)=['< ' temp(idx+1,:)];
end


clf
bartext = ['HPL (m) - ' num2str(percent*100,4) '%'];
svm_contour(lons,lats,sqrt(reshape(vpl,n_lons,n_lats)'), ...
            sqrt(GRAPH_HPL_CONTOURS), ...
            ticklabels, GRAPH_HPL_COLORS, bartext);

title('HPL as a function of user location');
