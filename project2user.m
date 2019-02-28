function min_rat=project2user(sat_xyz, Cov)

global COL_USR_XYZ COL_USR_LL COL_USR_LLH COL_USR_EHAT ...
        COL_USR_NHAT COL_USR_UHAT COL_USR_MAX
global COL_U2S_MAX COL_U2S_GENUB COL_U2S_GXYZB COL_U2S_SIG2TRP
global MOPS_SIN_USRMASK
global GRAPH_LL_WORLD GRAPH_LL_STATE

% create user grid
latmin = -90;
latstep=2;
latmax = 90;
lonmin = -180;
lonstep=2;
lonmax = 179;
grid_lat = [latmin:latstep:latmax];
grid_lon = [lonmin:lonstep:lonmax];
nlat=length(grid_lat);
nlon=length(grid_lon);
[latmesh,lonmesh] = meshgrid(grid_lat,grid_lon);
nusr = length(grid_lat)*length(grid_lon);
usrllh = [latmesh(:),lonmesh(:),zeros(nusr,1)];
usrxyz = llh2xyz(usrllh);

%determine the east, north and up unit vectors
temp=findxyz2enu(usrllh(:,1)*pi/180,usrllh(:,2)*pi/180);
usr_ehat=reshape(temp(:,1,:),nusr,3);
usr_nhat=reshape(temp(:,2,:),nusr,3);
usr_uhat=reshape(temp(:,3,:),nusr,3);

usrdata = repmat(NaN,nusr,COL_USR_MAX);
usrdata(:,COL_USR_XYZ) = usrxyz;
usrdata(:,COL_USR_LLH) = usrllh;
usrdata(:,COL_USR_EHAT) = usr_ehat;
usrdata(:,COL_USR_NHAT) = usr_nhat;
usrdata(:,COL_USR_UHAT) = usr_uhat;


nusr = size(usrdata,1);
nlos = nusr;
usr2satdata = repmat(NaN,nlos,COL_U2S_MAX);

usr2satdata(:,COL_U2S_GXYZB) = find_los_xyzb(usrdata(:,COL_USR_XYZ), sat_xyz);
usr2satdata(:,COL_U2S_GENUB) = find_los_enub(usr2satdata(:,COL_U2S_GXYZB),...
   usrdata(:,COL_USR_EHAT),usrdata(:,COL_USR_NHAT),usrdata(:,COL_USR_UHAT));
abv_mask = find(-usr2satdata(:,COL_U2S_GENUB(3)) >= MOPS_SIN_USRMASK);

n_abv=length(abv_mask);
los_xyzb=usr2satdata(abv_mask,COL_U2S_GXYZB);
for ipair=1:n_abv
  usr2satdata(abv_mask(ipair),COL_U2S_SIG2TRP) = ...
                                    los_xyzb(ipair,:)*Cov*los_xyzb(ipair,:)';
end

projection = sqrt(usr2satdata(:,COL_U2S_SIG2TRP));

figure
clf;
min_mesh = min(min(projection(find(projection ~= 0))));
max_mesh = max(max(projection));
conLev = [min_mesh:(max_mesh-min_mesh)/100:max_mesh];
contourf([lonmin:lonstep:lonmax],[latmin:latstep:latmax],...
         reshape(projection,nlon,nlat)', conLev)
shading flat
colorbar
hold on

ax=axis;
dx=(ax(2)-ax(1))/600;
dy=(ax(4)-ax(3))/600;
plot(GRAPH_LL_WORLD(:,2)+dx,GRAPH_LL_WORLD(:,1)-dy,'k');
plot(GRAPH_LL_WORLD(:,2)-dx,GRAPH_LL_WORLD(:,1)+dy,'w');
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
