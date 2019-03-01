function result=intriangle(x,y,corner)
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
%INTRIANGLE    Checks if an IPP is in a triangle given the missing corner
%RESULT=INTRIANGLE(X,Y,CORNER)
%   Given an X position (0 to 1) a Y position (0 to 1) and a corner # (1 to 4),
%   this function determines if an IPP is in the triangle (returns 1) or not 
%   (returns 0).  The corners are numbered from SW, SE, NE, and NW
%
%   See also:  IGPFORIPPS CHECKIGPSQUARE GRID2UIVE FIND_INV_IGPMASK

%2001Feb28 Created by Todd Walter

result=zeros(size(corner));

idx=find(corner==1);
if(~isempty(idx))
  result(idx)=(y(idx)>=1-x(idx));
end
idx=find(corner==2);
if(~isempty(idx))
  result(idx)=(y(idx)>=x(idx));
end
idx=find(corner==3);
if(~isempty(idx))
  result(idx)=(y(idx)<=1-x(idx));
end
idx=find(corner==4);
if(~isempty(idx))
  result(idx)=(y(idx)<=x(idx));
end

