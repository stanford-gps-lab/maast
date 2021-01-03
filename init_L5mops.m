function init_L5mops()
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
% References: 	EUROCAE ED-259A the SBAS DFMC MOPS

% Created November 3, 2020 by Todd Walter

global L5MOPS_PREAMBLE L5MOPS_DO_NOT_USE_SBAS
global L5MOPS_DFRE L5MOPS_SIG_DFRE L5MOPS_SIG2_DFRE
global L5MOPS_DFREI_DNUSBAS L5MOPS_DFREI_MIN L5MOPS_DFREI_MAX

global L5MOPS_KV_PA L5MOPS_KH_PA L5MOPS_KH_NPA;
global L5MOPS_WRSMASK L5MOPS_USRMASK L5MOPS_SIN_WRSMASK L5MOPS_SIN_USRMASK 
global L5MOPS_VAL L5MOPS_HAL L5MOPS_NPA_HAL
global L5MOPS_MIN_GPSPRN L5MOPS_MAX_GPSPRN L5MOPS_MIN_GLOPRN L5MOPS_MAX_GLOPRN 
global L5MOPS_MIN_GALPRN L5MOPS_MAX_GALPRN L5MOPS_MIN_GEOPRN L5MOPS_MAX_GEOPRN
global L5MOPS_MIN_BDSPRN L5MOPS_MAX_BDSPRN

global L5MOPS_MT31_PATIMEOUT L5MOPS_MT32_PATIMEOUT L5MOPS_MT35_PATIMEOUT 
global L5MOPS_DFRE_PATIMEOUT L5MOPS_MT39_PATIMEOUT L5MOPS_MT40_PATIMEOUT 
global L5MOPS_MT37_PATIMEOUT 

L5MOPS_DO_NOT_USE_SBAS = -16;         % flag to indicate sat is not to be used with SBAS

L5MOPS_PREAMBLE = ['0101'; '1100'; '0110'; '1001'; '0011'; '1010'];

L5MOPS_SIG_DFRE  = [0.625 0.75 0.875 1.0 1.125 1.5 1.75 2.0 2.25 2.5 3.0 ...
                      3.5 4.0 7.0 10.0 L5MOPS_DO_NOT_USE_SBAS];
L5MOPS_DFRE      = [(L5MOPS_SIG_DFRE(1:15))*3.29 L5MOPS_DO_NOT_USE_SBAS];
                  
L5MOPS_SIG2_DFRE = [(L5MOPS_SIG_DFRE(1:15)).^2 L5MOPS_DO_NOT_USE_SBAS];

L5MOPS_DFREI_DNUSBAS = 16;
L5MOPS_DFREI_MIN     = 1;
L5MOPS_DFREI_MAX     = 16;

L5MOPS_KV_PA         = 5.33;        % K value for VPL calc
L5MOPS_KH_PA         = 6.0;         % K value for HPL calc
L5MOPS_KH_NPA        = 6.18;        % K value for NPA HPL calc

L5MOPS_WRSMASK = 5;     % WRS Elevation mask angle
L5MOPS_SIN_WRSMASK = sin(L5MOPS_WRSMASK*pi/180);
L5MOPS_USRMASK = 5;     % User mask angle
L5MOPS_SIN_USRMASK = sin(L5MOPS_USRMASK*pi/180);

L5MOPS_VAL            = 50;
L5MOPS_HAL            = 40;
L5MOPS_NPA_HAL        = 556;

L5MOPS_MIN_GPSPRN     = 1; 
L5MOPS_MAX_GPSPRN     = 37; 
L5MOPS_MIN_GLOPRN     = 38; 
L5MOPS_MAX_GLOPRN     = 74;
L5MOPS_MIN_GALPRN     = 75; 
L5MOPS_MAX_GALPRN     = 111;
L5MOPS_MIN_GEOPRN     = 120;
L5MOPS_MAX_GEOPRN     = 158;
L5MOPS_MIN_BDSPRN     = 159; 
L5MOPS_MAX_BDSPRN     = 195;

L5MOPS_MT31_PATIMEOUT = 600;
L5MOPS_MT32_PATIMEOUT = 240;
L5MOPS_MT35_PATIMEOUT = 12;
L5MOPS_DFRE_PATIMEOUT = 12;
L5MOPS_MT37_PATIMEOUT = 600;
L5MOPS_MT39_PATIMEOUT = 240;
L5MOPS_MT40_PATIMEOUT = 240;
