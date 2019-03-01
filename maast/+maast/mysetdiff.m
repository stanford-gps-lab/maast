function c = mysetdiff(a,b)
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
% Same as setdiff.m.  Faster.

% created: 2001 Apr 30 by Wyant Chan
if (isempty(a))
    c = [];
    return;
elseif (isempty(b))
    c = unique(a);
    return;
end
a = unique(a);
b = unique(b);

na=length(a);
nb=length(b);
if (size(a,2)==1),
    a0=a';
else
    a0=a;
end
if (size(b,1)==1),
    b=b';
end
%[arows,bcols] = meshgrid(a0,b);
arows = repmat(a0,nb,1);
bcols = repmat(b,1,na);
temp = (arows==bcols);
c=a(find(~sum(temp,1)));

