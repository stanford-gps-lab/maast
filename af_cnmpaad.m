function sig2=af_usrcnmpaad(del_t,el)
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
%SIG2_AAD calculate airborne psueudorange confidence (variance) per LAAS MASPS
%SIG2=SIG2_AAD(DEL_T, EL)
%   DEL_T is the track time in seconds since last cycle slip and is not used
%   EL is the elevation angle in radians
%   SIG2 is the psueudorange confidence (variance) in meters^2 
%   per LAAS MASPS DO-245
%
% SEE ALSO INIT_AADA INIT_AADB

%created 24 April, 2001 by Todd Walter

global AAD_A0 AAD_A1 AAD_THETA0

sig2 = (AAD_A0 + AAD_A1*exp(-el/AAD_THETA0)).^2;

   
