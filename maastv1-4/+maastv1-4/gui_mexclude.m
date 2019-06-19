function gui_mexclude(obj_list,sel_obj)
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
% obj_list contains handles of objects to be mutually excluded
% sel_obj is handle of selected 

set(obj_list,'Value',0);
set(sel_obj,'Value',1);
