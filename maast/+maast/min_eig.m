function y=min_eig(A)
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
%t=cputime;
a=A(1,1);
b=A(1,2);
c=A(1,3);
d=A(1,4);
e=A(2,2);
f=A(2,3);
g=A(2,4);
h=A(3,3);
i=A(3,4);
j=A(4,4);
[p,a0,a1,a2,a3]=char_poly(0,A);
y0=0;
err=1;
iter=0;
%while err>0.0000005
while err>0.000000005
   yn=y0-(a0+a1*y0+a2*y0^2+a3*y0^3+y0^4)/(a1+2*a2*y0+3*a3*y0^2+4*y0^3);
   iter=iter+1;
   err=abs(yn-y0);
   y0=yn;
end
y=yn;
%time=cputime-t;
%iter;
