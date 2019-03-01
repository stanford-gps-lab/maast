function init_col_labels()
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
%function init_col_labels()
% initialize labels for column numbers of matrix structures 
%   SATDATA, WRSDATA, USRDATA, IGPDATA, WRS2SATDATA, USR2SATDATA

% Created: 2001 April 5 by Wyant Chan

global COL_SAT_PRN COL_SAT_XYZ COL_SAT_XYZDOT COL_SAT_SIG2CP COL_SAT_UDREI ...
        COL_SAT_COV COL_SAT_SCALEF COL_SAT_MINMON COL_SAT_MAX
global COL_USR_UID COL_USR_XYZ COL_USR_LL COL_USR_LLH COL_USR_EHAT ...
        COL_USR_NHAT COL_USR_UHAT COL_USR_INBND COL_USR_MEX COL_USR_MAX
global COL_IGP_BAND COL_IGP_ID COL_IGP_LL COL_IGP_XYZ COL_IGP_WORKSET ...
        COL_IGP_EHAT COL_IGP_NHAT COL_IGP_MAGLAT COL_IGP_CORNERDEN ...
        COL_IGP_GIVEI COL_IGP_MINMON COL_IGP_UPMGIVEI COL_IGP_MAX ...
        COL_IGP_DELAY COL_IGP_UPMGIVEI COL_IGP_BETA COL_IGP_CHI2RATIO COL_IGP_FLOORI
global COL_U2S_UID COL_U2S_PRN COL_U2S_LOSXYZ COL_U2S_GXYZB ...
        COL_U2S_LOSENU COL_U2S_GENUB COL_U2S_EL COL_U2S_AZ COL_U2S_SIG2TRP ...
        COL_U2S_SIG2L1MP COL_U2S_SIG2L2MP COL_U2S_IPPLL COL_U2S_IPPXYZ ...
        COL_U2S_TTRACK0 COL_U2S_IVPP COL_U2S_MAX COL_U2S_INITNAN 

% column numbers of specific data in SATDATA, WRSDATA, 
%   USRDATA, IGPDATA, WRS2SATDATA, USR2SATDATA matrices
% SAT - satellite / sv
% IGP - ionospheric grid point
% USR - user or wrs
% U2S - user or wrs to satellite

% SATDATA
COL_SAT_PRN    = 1;
COL_SAT_XYZ    = 2:4;
COL_SAT_XYZDOT = 5:7;
COL_SAT_NWRS   = 8; 
COL_SAT_UDREI  = 9;
COL_SAT_COV    = 10:25;
COL_SAT_SCALEF = 26;
COL_SAT_MINMON = 27;
COL_SAT_MAX    = 27;

% WRSDATA & USRDATA
COL_USR_UID = 1;
COL_USR_XYZ = 5:7;
COL_USR_LL = 2:3;
COL_USR_LLH = 2:4;
COL_USR_EHAT = 8:10;
COL_USR_NHAT = 11:13;
COL_USR_UHAT = 14:16;
COL_USR_INBND = 17;
COL_USR_MEX = 18;
COL_USR_MAX = 18;

% IGPDATA
COL_IGP_BAND      = 1;
COL_IGP_ID        = 2;
COL_IGP_LL        = 3:4;
COL_IGP_XYZ       = 5:7;
COL_IGP_WORKSET   = 8;
COL_IGP_EHAT      = 9:11;
COL_IGP_NHAT      = 12:14;
COL_IGP_MAGLAT    = 15;
COL_IGP_CORNERDEN = 16:27;
COL_IGP_GIVEI     = 28;
COL_IGP_MINMON    = 29;
COL_IGP_UPMGIVEI  = 30;
COL_IGP_DELAY     = 31;
COL_IGP_BETA      = 32;
COL_IGP_CHI2RATIO = 33;
COL_IGP_FLOORI    = 34;
COL_IGP_MAX       = 34;

% WRS2SATDATA & USR2SATDATA
COL_U2S_UID = 1;
COL_U2S_PRN = 2;
COL_U2S_LOSXYZ = 3:5;
COL_U2S_GXYZB = [3:5,9];
COL_U2S_LOSENU = 6:8;
COL_U2S_GENUB = 6:9;
COL_U2S_EL = 10;
COL_U2S_AZ = 11;
COL_U2S_SIG2TRP = 12;
COL_U2S_SIG2L1MP = 13;
COL_U2S_SIG2L2MP = 14;
COL_U2S_IPPLL = 15:16;
COL_U2S_IPPXYZ = 17:19;
COL_U2S_TTRACK0 = 20;
COL_U2S_IVPP = 21;
COL_U2S_MAX = 21;
COL_U2S_INITNAN = 3:21;
