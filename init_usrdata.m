function [usrdata,grid_lat,grid_lon] = init_usrdata(polyfile,latstep,lonstep)
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
% initialize user data for svm analysis. 
%
% Inputs:   
%   polyfile    -   file containing vertices of polygon bounding user region 
%   latstep,lonstep     -   latitude and longitude steps in degrees

global COL_USR_UID COL_USR_XYZ COL_USR_LL COL_USR_LLH COL_USR_EHAT ...
        COL_USR_NHAT COL_USR_UHAT COL_USR_INBND COL_USR_MAX
global usrllh

maskpoly = load(polyfile);

% create user grid
latmin = max(floor(min(maskpoly(:,1))/latstep)*latstep, -90);
latmax = min(ceil(max(maskpoly(:,1))/latstep)*latstep, 90-latstep);
lonmin = max(floor(min(maskpoly(:,2))/lonstep)*lonstep, -180);
lonmax = min(ceil(max(maskpoly(:,2))/lonstep)*lonstep, 180-lonstep);
grid_lat = [latmin:latstep:latmax];
grid_lon = [lonmin:lonstep:lonmax];
[latmesh,lonmesh] = meshgrid(grid_lat,grid_lon);
nusr = length(grid_lat)*length(grid_lon);
usrllh = [latmesh(:),lonmesh(:),zeros(nusr,1)];
usrxyz = llh2xyz(usrllh);
usrid = [1:nusr]';

inbnd = inpolygon(usrllh(:,2),usrllh(:,1),maskpoly(:,2),maskpoly(:,1));
usr_inbnd = (inbnd>0);  % sometimes inpolygon may return 0.5

%determine the east, north and up unit vectors
temp=findxyz2enu(usrllh(:,1)*pi/180,usrllh(:,2)*pi/180);
usr_ehat=reshape(temp(:,1,:),nusr,3);
usr_nhat=reshape(temp(:,2,:),nusr,3);
usr_uhat=reshape(temp(:,3,:),nusr,3);

usrdata = repmat(NaN,nusr,COL_USR_MAX);
usrdata(:,COL_USR_UID) = usrid;
usrdata(:,COL_USR_XYZ) = usrxyz;
usrdata(:,COL_USR_LLH) = usrllh;
usrdata(:,COL_USR_EHAT) = usr_ehat;
usrdata(:,COL_USR_NHAT) = usr_nhat;
usrdata(:,COL_USR_UHAT) = usr_uhat;
usrdata(:,COL_USR_INBND) = usr_inbnd;


% plot user locations
if 0

load topo;
figure;
contour([1:360], [-89:90], topo, [0 0],'k');
hold on;
plot(360+usrllh(:,2),usrllh(:,1),'*');
idx=find(usr_inbnd);
plot(360+usrllh(idx,2),usrllh(idx,1),'r*');

end

