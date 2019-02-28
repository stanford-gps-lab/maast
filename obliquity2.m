function ob2=obliquity2(el);

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
%OBLIQUITY2 returns the square of the ionospheric obliquity function
%
%OB2=OBLIQUITY2(EL)
%  EL is the elevation angle in radians
%  The height of the ionosphere and the radius of the earth are supplied by
%  INIT_CONST

%Created by Todd Walter 28 Mar 2001

global CONST_R_E CONST_R_IONO

ob2=ones(size(el))./(1-(CONST_R_E*cos(el)/CONST_R_IONO).^2);
