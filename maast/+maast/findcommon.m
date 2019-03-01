function c = findcommon(a,b)
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
% function c = findcommon(a,b)
% find common elements in vectors a & b
% simplified and sped up version of INTERSECT.M

a = a(:);
b = b(:);
[c,idx] = sort([a;b]);
d = find(c(1:end-1)==c(2:end));
c = c(d);
