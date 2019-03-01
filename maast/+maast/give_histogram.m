function give_histogram(give_hist, givei_hist)
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
global MOPS_GIVE MOPS_GIVEI_NM
global HIST_GIVE_BINS HIST_GIVE_XSPLIT HIST_GIVE_XRATIO HIST_GIVE_XTICKS
global HIST_GIVEI_BINS


%map the not monitored to the end of the histogram
givei_bins = MOPS_GIVE(HIST_GIVEI_BINS);
i = length(HIST_GIVE_XTICKS);
dtick = HIST_GIVE_XTICKS(i) - HIST_GIVE_XTICKS(i-1);
givei_bins(MOPS_GIVEI_NM) = HIST_GIVE_XTICKS(i)+dtick/2;
xticks = [HIST_GIVE_XTICKS HIST_GIVE_XTICKS(i)+dtick*(1:2)/2];

give_bins=[HIST_GIVE_BINS HIST_GIVE_XTICKS(i)+dtick*(1:2)/2];

%create proper labels for the x axis
xticklabel=num2str([HIST_GIVE_XTICKS HIST_GIVE_XTICKS(i)+(1:2)]');
xticklabel(i+1,:)='NM';
xticklabel(i+2,:)='  ';

%plot the histograms
h=svm_histogram(give_bins, [give_hist' 0]', givei_bins, givei_hist, ...
                HIST_GIVE_XSPLIT, HIST_GIVE_XRATIO, xticks,xticklabel);
legend(h,'GIVE','UIVE');
%put a line between numerical values and flagged values
ax=axis;
x=HIST_GIVE_XSPLIT+(HIST_GIVE_XTICKS(i)-HIST_GIVE_XSPLIT)/HIST_GIVE_XRATIO;
plot( [x x], [ax(3) ax(4)],'k');
xlabel('UIVE [m]');
