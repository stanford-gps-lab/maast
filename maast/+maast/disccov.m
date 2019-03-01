function [dcov, incr]=disccov(cov)
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
% DCOV=DISCCOV(COV) discretizes the covariance matrix

[m n]=size(cov);
if(m~=4 | n~=4)
  error('you must supply a 4x4 covariance matrix(symmetric positive definite');
end

R=chol(cov);
m=max(max(abs(R)));

ee=ceil(log(m)/log(2))-9;
if(ee < -5)
  ee=-5;
else
  if(ee>2)
    m
    error('matrix too large!  Beyond dynamic range');
  end
end

incr=2^ee;
R=incr*round(R/incr);
dcov=R'*R;














