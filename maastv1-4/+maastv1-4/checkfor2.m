function flag=checkfor2(wrs_id)

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
%CHECKFOR2 looks to see that at least 2 different WRSs have 2 IPPs
%
%  FLAG=CHECKFOR2(WRS_ID)
%  WRS_ID (n_ipp,1) is a vector containing the WRS ID numbers for each IPP
%         used in the fit.
%  A value of 1 is returned if two different WRSs have at least two IPPs used
%
% SEE ALSO: GIVE_ADD

%created 28 Mar 2001 by Todd Walter

flag=(max(diff(find(~diff(sort([wrs_id])))))>1);
