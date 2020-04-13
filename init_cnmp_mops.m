function init_cnmp_mops()
%*************************************************************************
%*     Copyright c 2011 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%calculate airborne psueudorange confidence (variance) per WAAS/LAAS MOPS
% initializes constants
%   per WAAS/LAAS MOPS DO-229D DO-245A
%
% SEE ALSO: CNMP_MOPS

%created 12 October, 2007 by Todd Walter
%updated 29 March 2011 by Todd Walter - corrected noise term
%updated 30 June 2018 by Todd Walter - corrected noise term to AAD-B

global  CNMP_MOPS_A0  CNMP_MOPS_A1  CNMP_MOPS_THETA0
global CNMP_MOPS_B0 CNMP_MOPS_B1 CNMP_MOPS_PHI0

 CNMP_MOPS_A0     = 0.13;      % meters
 CNMP_MOPS_A1     = 0.53;      % meters
 CNMP_MOPS_THETA0 = 10*pi/180; % radians

 CNMP_MOPS_B0     = 0.11;      % meters
 CNMP_MOPS_B1     = 0.13;      % meters
 CNMP_MOPS_PHI0 = 4*pi/180;  % radians   
