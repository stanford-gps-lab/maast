function wrsdata = init_wrsdata(wrsfile)

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
global COL_USR_UID COL_USR_XYZ COL_USR_LL COL_USR_LLH COL_USR_EHAT ...
        COL_USR_NHAT COL_USR_UHAT COL_USR_INBND COL_USR_MEX COL_USR_MAX

% get user positions
wrsraw = load(wrsfile);
nwrs = size(wrsraw,1);
uid = wrsraw(:,1);
wrsllh = wrsraw(:,2:4);

wrsxyz = llh2xyz(wrsllh);

fid=fopen(wrsfile);
line='%';
polyname=[];
while(isstr(line))
  fst=findstr(line,'%');
  if(fst==1)
    lst=length(line);
    polyname=sscanf(line(fst+1:lst),'%s');
  end
  line=fgets(fid);
end
%conuspoly = load('usrconus.txt');

if(~isempty(polyname))
  conuspoly = load(polyname);
  wrs_isconus = inpolygon(wrsllh(:,2),wrsllh(:,1),conuspoly(:,2),conuspoly(:,1));
else
  wrs_isconus = 0;
  fprintf('No reference station interior polygon specified');
end
%determine the east, north and up unit vectors
temp=findxyz2enu(wrsllh(:,1)*pi/180,wrsllh(:,2)*pi/180);
wrs_ehat=reshape(temp(:,1,:),nwrs,3);
wrs_nhat=reshape(temp(:,2,:),nwrs,3);
wrs_uhat=reshape(temp(:,3,:),nwrs,3);

wrsdata = repmat(NaN,nwrs,COL_USR_MAX);
wrsdata(:,COL_USR_UID) = uid;
wrsdata(:,COL_USR_XYZ) = wrsxyz;
wrsdata(:,COL_USR_LLH) = wrsllh;
wrsdata(:,COL_USR_EHAT) = wrs_ehat;
wrsdata(:,COL_USR_NHAT) = wrs_nhat;
wrsdata(:,COL_USR_UHAT) = wrs_uhat;
wrsdata(:,COL_USR_INBND) = wrs_isconus;
if size(wrsraw,2) > 4
   wrsdata(:,COL_USR_MEX) = wrsraw(:,5);
else
   wrsdata(:,COL_USR_MEX) = 0;
end

