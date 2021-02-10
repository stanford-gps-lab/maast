function coverage = continuity_contour(lats, lons, cbreak, avail, isinbnd, vhal, pa_mode)
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

global GRAPH_VPL_COLORS

contour_colors = GRAPH_VPL_COLORS(end:-1:1,:);

cont_contours = -log10([1e-2 3e-3 1e-3 3e-4 1e-4 3e-5 1e-5 3e-6 1e-6]);
ticklabels = {'< 10^-^2' '< 3 \times 10^-^3' '< 10^-^3' '< 3 \times 10^-^4' ...
              '< 10^-^4' '< 3 \times 10^-^5' '< 10^-^5' '< 3 \times 10^-^6' ...
              '< 10^-^6'};
          
n_lats=length(lats);
n_lons=length(lons);
n_times=size(cbreak,2);

tmp = sum(cbreak, 2)/n_times;
tmp(~any(avail,2)) = NaN;
cntnty = -log10(tmp);
cntnty(tmp == 0) = cont_contours(end);

cont_req = 8e-6;
%calculate coverage
coverage=0;
cos_lats = reshape(repmat(cos(lats*pi/180),n_lons,1),n_lons*n_lats,1);
idx=find((cntnty >= -log10(cont_req)) & isinbnd);
if(~isempty(idx))
  coverage=sum(cos_lats(idx))/sum(isinbnd.*cos_lats);
  coverage=fix(coverage*10000)/100;
end

clf

if(pa_mode)
    bartext = ['Continuity with VAL = ' num2str(vhal(1)) ',  HAL = ' ...
			   num2str(vhal(2)) ', Coverage(< 8 \times 10^-^6) = '...
               num2str(coverage) '%'];
else
    bartext = ['Continuity with HAL = ' num2str(vhal(2)) ...
            ', Coverage(< 8 \times 10^-^6) = ' num2str(coverage) '%'];
end


% clf
% 
% if(pa_mode)
%     bartext = ['Continuity with VAL = ' num2str(vhal(1)) ',  HAL = ' ...
% 			   num2str(vhal(2))];
% else
%     bartext = ['Continuity with HAL = ' num2str(vhal(2))];
% end

svm_contour(lons,lats,reshape(cntnty,n_lons,n_lats)', ...
            cont_contours, ticklabels, contour_colors, ...
		    bartext);


title('Continuity as a function of user location');

