function usr2satdata = init_usr2satdata(usrdata,satdata);

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
global COL_U2S_UID COL_U2S_PRN COL_U2S_MAX COL_SAT_PRN COL_USR_UID
global COL_U2S_TTRACK0
global MOPS_MIN_GEOPRN

nusr = size(usrdata,1);
nsat = size(satdata,1);
nlos = nsat*nusr;
usr2satdata = repmat(NaN,nlos,COL_U2S_MAX);
[t1 t2]=meshgrid(usrdata(:,COL_USR_UID),satdata(:,COL_SAT_PRN));
usr2satdata(:,COL_U2S_UID) = reshape(t1,nlos,1);    %usr id
usr2satdata(:,COL_U2S_PRN) = reshape(t2,nlos,1);    %prn

%start the geo timetrack days in the past
geo=find(usr2satdata(:,COL_U2S_PRN) >= MOPS_MIN_GEOPRN);

usr2satdata(geo,COL_U2S_TTRACK0) = -7*24*3600;

