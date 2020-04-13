function sig2=af_cnmp_mops(del_t,el)
%*************************************************************************
%*     Copyright c 2009 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%SIG2_AAD calculate airborne psueudorange confidence (variance) per
%WAAS/LAAS MOPS
%SIG2=CNMP_MOPS(DEL_T, EL)
%   DEL_T is the track time in seconds since last cycle slip and is not used
%   EL is the elevation angle in radians
%   SIG2 is the psueudorange confidence (variance) in meters^2 
%   per WAAS/LAAS MOPS DO-229D Do-245A
%
% SEE ALSO INIT_AADA INIT_AADB

%created 12 October, 2007 by Todd Walter

global CNMP_MOPS_A0 CNMP_MOPS_A1 CNMP_MOPS_THETA0
global CNMP_MOPS_B0 CNMP_MOPS_B1 CNMP_MOPS_PHI0 

sig2 = (CNMP_MOPS_A0 + CNMP_MOPS_A1*exp(-el/CNMP_MOPS_THETA0)).^2 +...
       (CNMP_MOPS_B0 + CNMP_MOPS_B1*exp(-el/CNMP_MOPS_PHI0)).^2;

   
