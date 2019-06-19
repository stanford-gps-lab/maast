function sig2_trop = af_wrstrpmops(El)
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
% tropo confidence bound (variance)
% El can be any n-by-m matrix of elevations.
% Returns tropo variance for each elevation element.  
% NaN is returned for NaN elevations.
 
idxvis = find(~isnan(El));
sig2_trop = repmat(NaN,size(El));
%from MOPS
sig2_trop(idxvis) = (0.12*1.001)^2 ./ (0.002001+sin(El(idxvis)).^2);    

