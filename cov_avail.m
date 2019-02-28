function cov_avail (usrdata, vpl, hpl, vhal, pa_mode)
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
% create a coverage vs Availability plot for two sets of information

%Modified Todd Walter June 28, 2007 to include VAL, HAL and PA vs. NPA mode
%modified Todd Walter August 1, 2007 to include latitude weighting for
%coverage


global COL_USR_LL COL_USR_INBND;

isinbnd = usrdata(:, COL_USR_INBND);
cos_lats = cos(usrdata(:, COL_USR_LL(1))*pi/180);

n_times = size(vpl, 2);

coverage_set = [];

%calculate availability
if(pa_mode)
    avail1=sum(((vpl <= vhal(1)) & (hpl <= vhal(2)))')'/n_times;
    title_text = ['Coverage vs Availability (VAL = ' num2str(vhal(1)) ...
                  ', HAL = ' num2str(vhal(2)) ')'];
else
    avail1=sum(((hpl <= vhal(2)))')'/n_times;
    title_text = ['Coverage vs Availability (HAL = ' num2str(vhal(2)) ')'];   
end

percent_ax = .95:.001:1;

for percent = .95:.001:1
    
    idx=find((avail1 >= percent) & isinbnd);
    if(~isempty(idx))
        coverage=sum(cos_lats(idx))/sum(isinbnd.*cos_lats);
        coverage=fix(coverage*10000)/100;
    else
        coverage = 0;
    end;
    
    coverage_set = [coverage_set coverage];
   
end

plot (percent_ax, coverage_set, 'LineWidth', 2);
title(title_text, 'FontSize', 16);
xlabel('Percent Availability', 'FontSize', 12);
minc = min(coverage_set) - .05;
minc = max(0, minc);
minc = min(98, minc);
axis([.95 1 minc 100])
ylabel('Coverage', 'FontSize', 12);