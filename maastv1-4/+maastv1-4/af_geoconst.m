function satdata = af_geoconst(satdata,wrsdata,wrs2satdata,do_mt28, dual_freq)

%*************************************************************************
%*     Copyright c 2009 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
global GEOUDREI_CONST
global COL_SAT_UDREI COL_SAT_COV COL_SAT_SCALEF COL_SAT_MINMON


nsat = size(satdata,1);
nwrs = size(wrsdata,1);
nlos = size(wrs2satdata,1);

%all satellite meet the minimum monitoring criteria (used for histogram)
satdata(:,COL_SAT_MINMON)=repmat(1,nsat,1);

%all satellites have the same UDREI value
satdata(:,COL_SAT_UDREI) = repmat(GEOUDREI_CONST,nsat,1);

%if using MT 28 and no MT 28 already defined,
% put in the identity matrix for XYZ and 0 for clock
if do_mt28 
  i=find(isnan(satdata(:,COL_SAT_SCALEF)));
  if ~isempty(i)
    a=eye(4);
    a(4,4)=0;
    a=a(:)';
    satdata(i,COL_SAT_COV)=repmat(a,nsat,1);
    satdata(i,COL_SAT_SCALEF)=repmat(0,nsat,1);
  end
end   







