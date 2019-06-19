function num=gui_readnum(hndl,llim,ulim,errmsg)
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
% GUI_READNUM    Reads the value of a numerical text box 
% 
% num = gui_readnum(hndl,llim,ulim,errmsg)
%
% hndl      -   handle of text object
% llim/ulim -   lower and upper limits on the value (optional)
% errmsg    -   error message (optional)
% num       -   numerical value of text, returns NaN if invalid
%
% See also: GUI_READSELECT 

% created by Wyant Chan 2001 May 15

if nargin==1,
    llim=-inf;
    ulim=inf;
    errmsg='';
elseif nargin==3,
    errmsg='';
end
num = str2num(get(hndl,'String'));    
if isempty(num) | num>ulim | num<llim,
    fprintf(errmsg);
    num = NaN;
end
