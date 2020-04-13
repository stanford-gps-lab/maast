function wrsplot(wrsfile, igpfile, usrpolyfile)

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
% Modified Todd Walter June 27, 2007 to fix igp and poly off options,
%    and plotting span

init_graph;
global GRAPH_LL_WORLD GRAPH_LL_STATE GRAPH_WRSMAP_FIGNO

plot_igpdata = 1;
plot_usr_poly = 1;

%load wrs data
wrsraw = load(wrsfile);
nwrs = size(wrsraw,1);

%load igp data
if plot_igpdata
  igpraw = sortrows(load(igpfile),[3,4]);
  igp_mask = igpraw(:,3:4);
else
  igp_mask = wrsraw(:,2:3);
  %adjust to 0 to 360
  idx=find(igp_mask(:,2)<0);
  igp_mask(idx,2) = igp_mask(idx,2)+360;
end

%load user polygon file

if(plot_usr_poly)
  usrpoly = load(usrpolyfile);
else
  usrpoly = wrsraw(:,2:3);
end

%adjust IGP longitude to -180 to 180
ll_igp=igp_mask; 
idx=find(ll_igp(:,2)>=180);
ll_igp(idx,2)=ll_igp(idx,2)-360;

ax180=[min([ll_igp(:,2)' wrsraw(:,3)' usrpoly(:,2)'])...
       max([ll_igp(:,2)' wrsraw(:,3)' usrpoly(:,2)'])...
       min([ll_igp(:,1)' wrsraw(:,2)' usrpoly(:,1)'])...
       max([ll_igp(:,1)' wrsraw(:,2)' usrpoly(:,1)'])];
span180 = ax180(2) - ax180(1);

%adjust reference station and user polygon values to 0 to 360
ll_wrs=wrsraw(:,2:3); 
idx=find(ll_wrs(:,2)<0);
ll_wrs(idx,2)=ll_wrs(idx,2)+360;

ll_usr=usrpoly; 
idx=find(ll_usr(:,2)<0);
ll_usr(idx,2)=ll_usr(idx,2)+360;

ax360=[min([igp_mask(:,2)' ll_wrs(:,2)' ll_usr(:,2)'])...
       max([igp_mask(:,2)' ll_wrs(:,2)' ll_usr(:,2)'])...
       min([igp_mask(:,1)' ll_wrs(:,1)' ll_usr(:,1)'])...
       max([igp_mask(:,1)' ll_wrs(:,1)' ll_usr(:,1)'])];
span360 = ax360(2)-ax360(1);
%find best way to display on map
if(span360 <= 180 && span360 < span180)
 wrsraw(:,2:3)=ll_wrs;
  usrpoly=ll_usr;
  ll_igp=igp_mask; 
  ax=ax360;
else
  ax=ax180;
end


figure(GRAPH_WRSMAP_FIGNO);
clf

%plot map
plot(GRAPH_LL_WORLD(:,2),GRAPH_LL_WORLD(:,1),'k');
hold on
plot(GRAPH_LL_STATE(:,2),GRAPH_LL_STATE(:,1),'k:');
if(span360 < span180)        
  plot(GRAPH_LL_WORLD(:,2)+360,GRAPH_LL_WORLD(:,1),'k');
  plot(GRAPH_LL_STATE(:,2)+360,GRAPH_LL_STATE(:,1),'k:');
  xticklabel=get(gca,'XTickLabel');
  xticks=str2double(xticklabel);
  idx=find(xticks>=180);
  xticks(idx)=xticks(idx)-360;
  set(gca,'XTickLabel',num2str(xticks));
end

if plot_usr_poly
    plot(usrpoly(:,2),usrpoly(:,1),'r');
end

%plot reference stations
lon_circ=(ax(2)-ax(1))*cos((.1:.1:2)*pi)'/100;
lat_circ=(ax(4)-ax(3))*sin((.1:.1:2)*pi)'/100;
n_igp=size(ll_igp,1);
for idx=1:nwrs
  patch(lon_circ+wrsraw(idx,3),lat_circ+wrsraw(idx,2),'b');
end

%plot grid points
if plot_igpdata
  lon_tri=(ax(2)-ax(1))*cos((-1:4:7)*pi/6)'/100;
  lat_tri=(ax(4)-ax(3))*sin((-1:4:7)*pi/6)'/100;
 n_igp=size(ll_igp,1);
 for idx=1:n_igp
    patch(lon_tri+ll_igp(idx,2),lat_tri+ll_igp(idx,1),'g');
  end
end
axis(ax);
grid on;
title('Reference Station Locations');




