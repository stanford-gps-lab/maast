function satdata = af_udreconst(satdata,wrsdata,wrs2satdata,do_mt28)

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
global UDREI_CONST
global COL_SAT_UDREI COL_SAT_COV COL_SAT_SCALEF COL_SAT_MINMON


nsat = size(satdata,1);
nwrs = size(wrsdata,1);
nlos = size(wrs2satdata,1);

%all satellite meet the minimum monitoring criteria (used for hisogram)
satdata(:,COL_SAT_MINMON)=repmat(1,nsat,1);

%all satellites have the same UDREI value
satdata(:,COL_SAT_UDREI) = repmat(UDREI_CONST,nsat,1);

%if using MT 28 put in the identity matrix for XYZ and 0 for clock
if do_mt28
  a=eye(4);
  a(4,4)=0;
  a=a(:)';
  satdata(:,COL_SAT_COV)=repmat(a,nsat,1);
  satdata(:,COL_SAT_SCALEF)=repmat(0,nsat,1);
end   







