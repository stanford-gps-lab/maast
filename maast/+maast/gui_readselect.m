function iselect = gui_readselect(objlist)
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
% function iselect = gui_readselect(objlist)
%
% Returns the index of the selected option/s (Value field = 1) 
% in a list of object handles

iselect=[];  
for i = 1:length(objlist),
    if get(objlist(i),'Value')==1,
        iselect = [iselect,i];
    end
end

