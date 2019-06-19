function init_graph()


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

global GRAPH_AVAIL_FIGNO GRAPH_VPL_FIGNO GRAPH_HPL_FIGNO
global GRAPH_UDREMAP_FIGNO GRAPH_GIVEMAP_FIGNO
global GRAPH_UDREHIST_FIGNO GRAPH_GIVEHIST_FIGNO GRAPH_WRSMAP_FIGNO
global GRAPH_COV_AVAIL_FIGNO

global GRAPH_DARK_PURPLE GRAPH_LIGHT_PURPLE GRAPH_DARK_BLUE 
global GRAPH_CYAN GRAPH_DARK_GREEN GRAPH_LIGHT_GREEN 
global GRAPH_YELLOW GRAPH_ORANGE GRAPH_RED 

global GRAPH_VPL_CONTOURS GRAPH_VPL_COLORS
global GRAPH_HPL_CONTOURS GRAPH_HPL_COLORS
global GRAPH_AVAIL_CONTOURS GRAPH_AVAIL_COLORS
global GRAPH_UDREI_COLORS GRAPH_GIVEI_COLORS

global GRAPH_LL_WORLD GRAPH_LL_STATE


GRAPH_AVAIL_FIGNO    = 5;
GRAPH_VPL_FIGNO      = 6;
GRAPH_HPL_FIGNO      = 7;
GRAPH_UDREMAP_FIGNO  = 8;
GRAPH_GIVEMAP_FIGNO  = 9;
GRAPH_UDREHIST_FIGNO = 10;
GRAPH_GIVEHIST_FIGNO = 11;
GRAPH_WRSMAP_FIGNO = 12;
GRAPH_COV_AVAIL_FIGNO = 13;


GRAPH_DEEP_PURPLE    = [1.0 0.0 1.0]*.25; 
GRAPH_DARK_PURPLE    = [1.0 0.0 1.0]*.5; 
GRAPH_LIGHT_PURPLE   = [1.0 0.0 1.0]*.75; 
GRAPH_DARK_BLUE      = [0.0 0.0 1.0]*.6; 
GRAPH_LIGHT_BLUE     = [0.1 0.1 1.0]; 
GRAPH_CYAN           = [0.0 1.0 1.0]*.9; 
GRAPH_AQUA           = [0.0 1.0 1.0]*.5;
GRAPH_DARK_GREEN     = [0.0 1.0 0.0]*0.75;
GRAPH_LIGHT_GREEN    = [0.1 1.0 0.1];
GRAPH_LIME           = [0.5 1.0 0.0];
GRAPH_YELLOW         = [1.0 1.0 0.0]*.95;
GRAPH_MUSTARD        = [1.0 1.0 0.0]*.75;
GRAPH_ORANGE         = [1.0 0.5 0.0];
GRAPH_MAGENTA        = [1.0 0.0 0.5];
GRAPH_RED            = [1.0 0.0 0.0];
GRAPH_DARK_RED       = [1.0 0.0 0.0]*.6;

%GRAPH_VPL_CONTOURS   = [0 5 10 12 15 20 30 40 50];
GRAPH_VPL_CONTOURS   = [0 12 15 20 25 30 35 40 50];
%GRAPH_VPL_CONTOURS    = [10 20 30 40 50 60 80 100 120];
%GRAPH_VPL_CONTOURS    = [100 200 300 400 500 600 800 1000 1200];
GRAPH_VPL_COLORS     = [[GRAPH_DARK_PURPLE];...
                        [GRAPH_LIGHT_PURPLE];...
                        [GRAPH_DARK_BLUE];...
                        [GRAPH_CYAN];...
                        [GRAPH_DARK_GREEN];...
                        [GRAPH_LIGHT_GREEN];...
                        [GRAPH_YELLOW];...
                        [GRAPH_ORANGE];...
                        [GRAPH_RED]];

GRAPH_HPL_CONTOURS   = [0 20 40 60 80 100 150 250 556];
GRAPH_HPL_COLORS     = GRAPH_VPL_COLORS;

GRAPH_AVAIL_CONTOURS = [0 50 75 85 90 95 99 99.5 99.9]/100;
GRAPH_AVAIL_COLORS   = flipud(GRAPH_VPL_COLORS);


GRAPH_UDREI_COLORS   = [[GRAPH_DEEP_PURPLE];
                        [GRAPH_DARK_PURPLE];
                        [GRAPH_LIGHT_PURPLE];
                        [GRAPH_DARK_BLUE];
                        [GRAPH_LIGHT_BLUE];
                        [GRAPH_CYAN];
                        [GRAPH_AQUA];
                        [GRAPH_DARK_GREEN];
                        [GRAPH_LIGHT_GREEN];
                        [GRAPH_LIME];
                        [GRAPH_YELLOW];
                        [GRAPH_MUSTARD];
                        [GRAPH_ORANGE];
                        [GRAPH_MAGENTA];
                        [GRAPH_RED];
                        [GRAPH_DARK_RED]];

GRAPH_GIVEI_COLORS   = GRAPH_UDREI_COLORS;


%load usalo
%load worldlo
%[blat, blon]=extractm(POline);
load mapdata

GRAPH_LL_WORLD       = ll_world;
GRAPH_LL_STATE       = ll_state;
