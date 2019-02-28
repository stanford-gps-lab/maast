function n=svm_hist(y,x)

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

n_edge = length(x);
n_bin=n_edge-1;

n = zeros(n_bin,1);
for i=2:n_edge
  n(i-1,:) = sum(y>x(i-1) & y <= x(i));
end
