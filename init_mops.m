function init_mops()
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
%function init_mops()
% 
% assigns values used by the WAAS MOPS
%
% References: 	RTCA DO-229B the WAAS MOPS

% Created 2001Mar28 by Todd Walter
% Modified 2001Apr3 by Wyant Chan:  
%   - added MOPS_SIG_UDRE MOPS_UDREI_MIN

global MOPS_NOT_IN_MASK MOPS_NOT_MONITORED;
global MOPS_UDRE MOPS_SIG_UDRE MOPS_SIG2_UDRE ...
        MOPS_UDREI_MIN MOPS_UDREI_MAX MOPS_UDREI_NM MOPS_UDREI_DNU

global MOPS_GIVE MOPS_SIG2_GIVE MOPS_GIVEI_MIN MOPS_GIVEI_MAX MOPS_GIVEI_NM
global MOPS_KV_PA MOPS_KH_PA MOPS_KH_NPA;
global MOPS_C_COVARIANCE;
global MOPS_WRSMASK MOPS_USRMASK MOPS_SIN_WRSMASK MOPS_SIN_USRMASK 
global MOPS_VAL MOPS_HAL MOPS_NPA_HAL
global MOPS_MAX_GPSPRN MOPS_MIN_GEOPRN

MOPS_NOT_IN_MASK   = -12;         % flag to indicate not in current mask
MOPS_NOT_MONITORED = -16;         % flag to indicate sat or igp is not observed
MOPS_DO_NOT_USE    = -18;         % flag to indicate sat or igp is not safe

MOPS_UDRE          = [0.75 1.00 1.25 1.75 2.25 3.0 3.75 4.5 5.25 6.0 7.5 ...
                      15.0 50.0 150.0 MOPS_NOT_MONITORED MOPS_DO_NOT_USE];
MOPS_SIG2_UDRE     = [0.0520 0.0924 0.1444 0.2830 0.4678 0.8315 1.2992 ...
                      1.8709 2.5465 3.3260 5.1968 20.787 230.9661 ...
                      2078.695 MOPS_NOT_MONITORED MOPS_DO_NOT_USE];
MOPS_SIG_UDRE     = [sqrt(MOPS_SIG2_UDRE(1:14)),...
                        MOPS_NOT_MONITORED,MOPS_DO_NOT_USE];
MOPS_UDREI_NM      = 15;
MOPS_UDREI_DNU     = 16;
MOPS_UDREI_MIN     = 1;
MOPS_UDREI_MAX     = 16;

%MOPS_GIVE          = [4 5 6 7 8 9 10 11 12 13 15 20 25 35 45 MOPS_NOT_MONITORED];  %GIVE values
%MOPS_GIVE           = [.3:.1:45 MOPS_NOT_MONITORED];
%MOPS_SIG2_GIVE     = (MOPS_GIVE(1:length(MOPS_GIVE)) ./ 3.29) .^ 2;
%MOPS_SIG2_GIVE(length(MOPS_GIVE)+1) = MOPS_NOT_MONITORED;

MOPS_GIVE          = [0.3 0.6 0.9 1.2 1.5 1.8 2.1 2.4 2.7 3.0 3.6 4.5 6.0 15.0 45.0 MOPS_NOT_MONITORED];
 MOPS_SIG2_GIVE     = [0.0084 0.0333 0.0749 0.1331 0.2079 0.2994 0.4075 ...
                       0.5322 0.6735 0.8315 1.1974 1.8709 3.3260 20.787 ...
                       187.0826 MOPS_NOT_MONITORED];   %GIVE variance values
 MOPS_GIVEI_NM      = 16;          % Not monitored GIVEI index
 MOPS_GIVEI_MIN     = 1;
 MOPS_GIVEI_MAX     = 16;

%MOPS_GIVEI_NM      = length(MOPS_GIVE)+1;          % Not monitored GIVEI index
%MOPS_GIVEI_MIN     = 1;
%MOPS_GIVEI_MAX     = length(MOPS_GIVE)+1;





MOPS_KV_PA         = 5.33;        % K value for VPL calc
MOPS_KH_PA         = 6.0;         % K value for HPL calc
MOPS_KH_NPA         = 6.18;        % K value for NPA HPL calc

MOPS_C_COVARIANCE  = 0.0;         % MT 10 parameter for MT 28


MOPS_WRSMASK = 5;     % WRS Elevation mask angle
MOPS_SIN_WRSMASK = sin(MOPS_WRSMASK*pi/180);
MOPS_USRMASK = 5;     % User mask angle
MOPS_SIN_USRMASK = sin(MOPS_USRMASK*pi/180);


MOPS_VAL            = 50;
MOPS_HAL            = 40;
MOPS_NPA_HAL        = 556;

MOPS_MAX_GPSPRN     = 74;  %expanded to include galileo
MOPS_MIN_GEOPRN     = 120;
