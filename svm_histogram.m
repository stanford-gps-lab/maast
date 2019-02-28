function h=svm_histogram(x,n,xi,ni,xsplit,xratio,xticks,xticklabels)

%*************************************************************************
%*     Copyright c 2007 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
clf

i=find(x>xsplit);
x(i)=xsplit + (x(i)-xsplit)/xratio;

i=find(xi>xsplit);
xi(i)=xsplit + (xi(i)-xsplit)/xratio;

i=find(xticks>xsplit);
xticks(i)=xsplit + (xticks(i)-xsplit)/xratio;

n_pts=sum(n);
n_idx=sum(ni) ;
%determine the lower bound for a semilog plot
lo_bnd = 10.^(-(ceil(log10(max([n_pts n_idx])))));

%get the x and y coordinates for the index histogram bars
[msg,xout,yout,XX,YY] = makebars(xi,ni/n_idx);

%reset the zeros to the lowerbound for the semilog plot
jdx=find(YY==0);
if(~isempty(jdx))
  YY(jdx) = lo_bnd;
end

%plot the bar data for the indicies
grid on
hold on

h1=patch(XX, YY,'r','EdgeColor', 'none');

set(gca, 'YScale', 'log');


%get the x and y coordinates for the user histogram bars
[msg,xout,yout,XX,YY] = makebars(x,n/n_pts,1);


%reset the zeros to the lowerbound for the semilog plot
jdx=find(YY==0);
if(~isempty(jdx))
  YY(jdx) = lo_bnd;
end
nx = length(x);
nXX = length(XX);
kdx = [ 1 2 reshape([(3:5:nXX-3)' (4:5:nXX-2)']',2*nx,1)' nXX-1 nXX];
%plot the user bar data and set the axes
h2=semilogy(XX(kdx),YY(kdx),'b');
axis([min(xticks) max(xticks) lo_bnd 1]);

set(gca,'XTick',xticks);
set(gca,'XTickLabel',xticklabels);
plot([xsplit xsplit], [lo_bnd 1], 'k');

ylabel('Probability')

h=[h1 h2];
