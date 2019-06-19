function p = mynormcdf(x)

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
% Express normal CDF in terms of the error function.
%p = 0.5 * erfcore( - x ./  sqrt(2),1);

c=[    2.18296718889673e-006;
   -0.000148863457919905;
   0.00384124422196663;
   -0.0482779402306949;
   0.382026575259555]';

if size(x,1)==1
    p = 0.5 + c*[x.^9; x.^7; x.^5; x.^3; x];
elseif size(x,2)==1
    p = 0.5 + [x.^9, x.^7, x.^5, x.^3, x]*c'; 
else
    error('Input must be row or column vector');
end
% Make sure that round-off errors never make P greater than 1.
k2 = find(p > 1);
if any(k2)
    p(k2) = ones(size(k2));
end
