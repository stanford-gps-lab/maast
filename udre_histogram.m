function udre_histogram(udre_hist, udrei_hist)
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

%Created May 25, 2001 by Todd Walter

global MOPS_UDRE MOPS_UDREI_NM MOPS_UDREI_DNU
global HIST_UDRE_BINS HIST_UDRE_XSPLIT HIST_UDRE_XRATIO HIST_UDRE_XTICKS
global HIST_UDREI_BINS


%map the not monitored and do not use to the end of the histogram
udrei_bins = MOPS_UDRE(HIST_UDREI_BINS);
i = length(HIST_UDRE_XTICKS);
dtick = HIST_UDRE_XTICKS(i) - HIST_UDRE_XTICKS(i-1);
udrei_bins(MOPS_UDREI_NM) = HIST_UDRE_XTICKS(i)+dtick/2;
%udrei_bins(MOPS_UDREI_DNU) = HIST_UDRE_XTICKS(i)+dtick;
xticks = [HIST_UDRE_XTICKS HIST_UDRE_XTICKS(i)+dtick*(1:2)/2];

udre_bins=[HIST_UDRE_BINS HIST_UDRE_XTICKS(i)+dtick*(1:2)/2];


%create proper labels for the x axis
xticklabel=num2str([HIST_UDRE_XTICKS HIST_UDRE_XTICKS(i)+(1:2)]');
xticklabel(i+1,:)=' NM';
%xticklabel(i+2,:)='DNU';
xticklabel(i+2,:)='   ';

%plot the histograms
h=svm_histogram(udre_bins, [udre_hist' 0]',udrei_bins, udrei_hist, ...
              HIST_UDRE_XSPLIT, HIST_UDRE_XRATIO, xticks,xticklabel);
legend(h,'UDRE','3.29*\sigma_f_l_t');
%put a line between numerical values and flagged values
ax=axis;
x=HIST_UDRE_XSPLIT+(HIST_UDRE_XTICKS(i)-HIST_UDRE_XSPLIT)/HIST_UDRE_XRATIO;
plot( [x x], [ax(3) ax(4)],'k');
xlabel('3.29*sigma flt [m]');

