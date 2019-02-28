function init_hist()

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
global HIST_UDRE_NBINS HIST_UDRE_BINS HIST_UDRE_EDGES
global HIST_UDREI_NBINS HIST_UDREI_BINS HIST_UDREI_EDGES
global HIST_UDRE_XSPLIT HIST_UDRE_XRATIO HIST_UDRE_XTICKS

global HIST_GIVE_NBINS HIST_GIVE_BINS HIST_GIVE_EDGES
global HIST_GIVEI_NBINS HIST_GIVEI_BINS HIST_GIVEI_EDGES
global HIST_GIVE_XSPLIT HIST_GIVE_XRATIO HIST_GIVE_XTICKS

global MOPS_UDREI_MIN MOPS_UDREI_MAX MOPS_GIVEI_MIN MOPS_GIVEI_MAX



HIST_UDRE_XSPLIT = 10;
HIST_UDRE_XRATIO = 40;
HIST_UDRE_XTICKS = [0:10 50:50:200];
HIST_UDRE_EDGES  = [0:.125:10 15:5:200];
HIST_UDRE_NBINS  = length(HIST_UDRE_EDGES)-1;
HIST_UDRE_BINS  = HIST_UDRE_EDGES(1:HIST_UDRE_NBINS)+0.5*diff(HIST_UDRE_EDGES);

HIST_GIVE_XSPLIT = 10;
HIST_GIVE_XRATIO = 8;
HIST_GIVE_XTICKS = [0:10 15:10:45];
HIST_GIVE_EDGES  = [0:.125:10 11:1:46];
HIST_GIVE_NBINS  = length(HIST_GIVE_EDGES)-1;
HIST_GIVE_BINS  = HIST_GIVE_EDGES(1:HIST_GIVE_NBINS)+0.5*diff(HIST_GIVE_EDGES);


HIST_UDREI_BINS  = MOPS_UDREI_MIN:MOPS_UDREI_MAX;
HIST_UDREI_EDGES = [HIST_UDREI_BINS-.5 MOPS_UDREI_MAX+.5];
HIST_UDREI_NBINS = length(HIST_UDREI_BINS);

HIST_GIVEI_BINS  = MOPS_GIVEI_MIN:MOPS_GIVEI_MAX;
HIST_GIVEI_EDGES = [HIST_GIVEI_BINS-.5 MOPS_GIVEI_MAX+.5];
HIST_GIVEI_NBINS = length(HIST_GIVEI_BINS);
