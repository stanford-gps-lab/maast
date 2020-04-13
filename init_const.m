function init_const()
%*************************************************************************
%*     Copyright c 2013 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%function init_const()
% 
% assigns values for commonly used GPS constants
%

% References: 	Parkinson, et. al., GPS Theory and Applications, V. 1,
%		AIAA, 1996.
% AJHansen 12 May 1997			Initial coding
% Added more precision to TEC2L1M


global CONST_C CONST_F1 CONST_F2 CONST_F5 CONST_LAMBDA1 CONST_LAMBDA2 CONST_LAMBDA5
global CONST_R_SV CONST_MU_E CONST_OMEGA_E CONST_R_E CONST_FLAT_E
global CONST_H_IONO CONST_R_IONO CONST_GAMMA CONST_K_TEC CONST_TEC2L1M
global CONST_SEC_PER_DAY CONST_SEC_PER_WEEK
global CONST_R_GEO CONST_H_GEO

CONST_C            = 299792458.0;           % velocity of light,  m/sec

CONST_F1           = 1575.42e6;             % L1 frequency, Hz
CONST_F2           = 1227.60e6;             % L2 frequency, Hz
CONST_F5           = 1176.45e6;             % L5 frequency, Hz

CONST_LAMBDA1      = CONST_C/CONST_F1;      % L1 wavelength, m
CONST_LAMBDA2      = CONST_C/CONST_F2;      % L2 wavelength, m
CONST_LAMBDA5      = CONST_C/CONST_F5;      % L5 wavelength, m

CONST_R_SV         = 26561750;              % SV orbit semimajor axis, m

CONST_MU_E         = 3.986005e14;           % Earth's grav. parameter (m^3/s^2)
CONST_OMEGA_E      = 7292115.1467e-11;      % Earth's angular velocity (rad/s)
CONST_R_E          = 6378137;               % Earth's semimajor axis, m 
CONST_B_E          = 6356752.314;           % Earth's semiminor axis, m 
CONST_FLAT_E       = 1.0/298.257223563;     % Earth flattening constant

CONST_H_IONO       = 350000;                % altitude of the ionospher, m
CONST_R_IONO       = CONST_R_E + CONST_H_IONO;  % Iono's approximate radius, m
CONST_GAMMA        = (CONST_F1/CONST_F2)^2; % ionospheric constant for L1/L2


CONST_K_TEC        = CONST_F1^2*CONST_F2^2/(CONST_F1^2+CONST_F2^2)/40.3;
CONST_SEC_PER_DAY  = 24*3600;
CONST_SEC_PER_WEEK = 7*CONST_SEC_PER_DAY;
CONST_TEC2L1M      = 0.16240549;

CONST_R_GEO        = 42241095.8;
CONST_H_GEO        = CONST_R_GEO - CONST_R_E;

