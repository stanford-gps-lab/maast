function init_mops()
%*************************************************************************
%*     Copyright c 2020 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%function init_mops()
% 
% assigns values used by the WAAS MOPS
%
% References: 	RTCA DO-229B the WAAS MOPS

% Created 2001Mar28 by Todd Walter
% Modified 2001Apr3 by Wyant Chan:  
%   - added MOPS_SIG_UDRE MOPS_UDREI_MIN
% Modified 2013Mar14 by Todd Walter added min and max PRN values for GPS,
%               GLONASS, Galileo, Beidou, and GEOs
% Modified 2020Mar28 by Todd Walter added message time out values

global MOPS_L1_PREAMBLE
global MOPS_NOT_IN_MASK MOPS_NOT_MONITORED MOPS_DO_NOT_USE
global MOPS_UDRE MOPS_SIG_UDRE MOPS_SIG2_UDRE ...
        MOPS_UDREI_MIN MOPS_UDREI_MAX MOPS_UDREI_NM MOPS_UDREI_DNU

global MOPS_GIVE MOPS_SIG2_GIVE MOPS_GIVEI_MIN MOPS_GIVEI_MAX MOPS_GIVEI_NM
global MOPS_KV_PA MOPS_KH_PA MOPS_KH_NPA;
global MOPS_C_COVARIANCE MOPS_MT27_DUDRE
global MOPS_WRSMASK MOPS_USRMASK MOPS_SIN_WRSMASK MOPS_SIN_USRMASK 
global MOPS_VAL MOPS_HAL MOPS_NPA_HAL
global MOPS_MIN_GPSPRN MOPS_MAX_GPSPRN MOPS_MIN_GLOPRN MOPS_MAX_GLOPRN 
global MOPS_MIN_GALPRN MOPS_MAX_GALPRN MOPS_MIN_GEOPRN MOPS_MAX_GEOPRN
global MOPS_MIN_BDUPRN MOPS_MAX_BDUPRN
global MOPS_UIRE_NUM MOPS_UIRE_DEN MOPS_UIRE_CONST 

global MOPS_MT1_PATIMEOUT MOPS_MT2_PATIMEOUT MOPS_MT7_PATIMEOUT 
global MOPS_MT9_PATIMEOUT MOPS_MT10_PATIMEOUT MOPS_MT17_PATIMEOUT 
global MOPS_MT18_PATIMEOUT MOPS_MT25_PATIMEOUT MOPS_MT26_PATIMEOUT  
global MOPS_MT27_PATIMEOUT MOPS_MT28_PATIMEOUT

global MOPS_MT7_AI MOPS_MT7_FCTIMEOUT

MOPS_NOT_IN_MASK   = -12;         % flag to indicate not in current mask
MOPS_NOT_MONITORED = -16;         % flag to indicate sat or igp is not observed
MOPS_DO_NOT_USE    = -18;         % flag to indicate sat or igp is not safe

MOPS_L1_PREAMBLE = dec2bin([83 154 198]);

MOPS_UDRE          = [0.75 1.00 1.25 1.75 2.25 3.0 3.75 4.5 5.25 6.0 7.5 ...
                      15.0 50.0 150.0 MOPS_NOT_MONITORED MOPS_DO_NOT_USE];
MOPS_SIG2_UDRE     = [0.0520 0.0924 0.1444 0.2830 0.4678 0.8315 1.2992 ...
                      1.8709 2.5465 3.3260 5.1968 20.787 230.9661 ...
                      2078.695 MOPS_NOT_MONITORED MOPS_DO_NOT_USE];
MOPS_SIG_UDRE     = [sqrt(MOPS_SIG2_UDRE(1:14))...
                           MOPS_NOT_MONITORED MOPS_DO_NOT_USE];
MOPS_UDREI_NM      = 15;
MOPS_UDREI_DNU     = 16;
MOPS_UDREI_MIN     = 1;
MOPS_UDREI_MAX     = 16;

MOPS_GIVE          = [0.3 0.6 0.9 1.2 1.5 1.8 2.1 2.4 2.7 3.0 3.6 4.5 6.0 15.0 45.0 MOPS_NOT_MONITORED];
MOPS_SIG2_GIVE     = [0.0084 0.0333 0.0749 0.1331 0.2079 0.2994 0.4075 ...
                       0.5322 0.6735 0.8315 1.1974 1.8709 3.3260 20.787 ...
                       187.0826 MOPS_NOT_MONITORED];   %GIVE variance values
MOPS_GIVEI_NM      = 16;          % Not monitored GIVEI index
MOPS_GIVEI_MIN     = 1;
MOPS_GIVEI_MAX     = 16;


MOPS_UIRE_NUM = 40.0*((pi/180)^2);    % Numerator of fraction to provide upper bound on residual iono error (rad^2 * meters) 
MOPS_UIRE_DEN = 261.0*((pi/180)^2);   % Denominator of higher order terms bound (rad^2) added to elevation angle
MOPS_UIRE_CONST = 0.018; % Constant term added to fraction (meters)


MOPS_KV_PA         = 5.33;        % K value for VPL calc
MOPS_KH_PA         = 6.0;         % K value for HPL calc
MOPS_KH_NPA         = 6.18;        % K value for NPA HPL calc

MOPS_MT27_DUDRE    = [1 1.1 1.25 1.5 2 3 4 5 6 8 10 20 30 40 50 100]; % MT 27 delta_UDRE terms

MOPS_C_COVARIANCE  = 0.0;         % MT 10 parameter for MT 28


MOPS_WRSMASK = 5;     % WRS Elevation mask angle
MOPS_SIN_WRSMASK = sin(MOPS_WRSMASK*pi/180);
MOPS_USRMASK = 5;     % User mask angle
MOPS_SIN_USRMASK = sin(MOPS_USRMASK*pi/180);

MOPS_VAL            = 50;
MOPS_HAL            = 40;
MOPS_NPA_HAL        = 556;

MOPS_MIN_GPSPRN     = 1; 
MOPS_MAX_GPSPRN     = 37; 
MOPS_MIN_GLOPRN     = 38; 
MOPS_MAX_GLOPRN     = 74;
MOPS_MIN_GALPRN     = 75; 
MOPS_MAX_GALPRN     = 111;
MOPS_MIN_GEOPRN     = 120;
MOPS_MAX_GEOPRN     = 158;
MOPS_MIN_BDUPRN     = 174; 
MOPS_MAX_BDUPRN     = 210;

MOPS_MT1_PATIMEOUT = 600;
MOPS_MT2_PATIMEOUT = 12;
MOPS_MT7_PATIMEOUT = 240;
MOPS_MT9_PATIMEOUT = 240;
MOPS_MT10_PATIMEOUT = 240;
MOPS_MT17_PATIMEOUT = 900;
MOPS_MT18_PATIMEOUT = 1200;
MOPS_MT25_PATIMEOUT = 240;
MOPS_MT26_PATIMEOUT = 600;
MOPS_MT27_PATIMEOUT = 86400;
MOPS_MT28_PATIMEOUT = 240;

MOPS_MT7_AI = [0.00000 0.00005 0.00009 0.00012 0.00015 0.00020 ...
               0.00030 0.00045 0.00060 0.00090 0.00150 0.00210 ...
               0.00270 0.00330 0.00460 0.00580]';
MOPS_MT7_FCTIMEOUT = [120 120 102 90 90 78 66 54 42 30 30 18 18 18 12 12]';