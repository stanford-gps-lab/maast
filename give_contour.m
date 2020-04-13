function give_contour(igp_mask, inv_igp_mask, givei, percent, ax)

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
global MOPS_SIG2_GIVE MOPS_GIVE MOPS_GIVEI_NM
global GRAPH_GIVEI_COLORS
global GRAPH_LL_WORLD GRAPH_LL_STATE

%adjust longitude to -180 to 180
ll_igp=igp_mask; 
idx=find(ll_igp(:,2)>=180);
ll_igp(idx,2)=ll_igp(idx,2)-360;
span180 = max(ll_igp(:,2)) - min(ll_igp(:,2));
span360 = max(igp_mask(:,2)) - min(igp_mask(:,2));
if(span360 < span180)
  ll_igp=igp_mask; 
end
if nargin < 5
  ax=[min(ll_igp(:,2)) max(ll_igp(:,2)) min(ll_igp(:,1)) max(ll_igp(:,1))];
end

%create a mesh for uive interpolation
lx=ax(1):(ax(2)-ax(1))/75:ax(2);
ly=ax(3):(ax(4)-ax(3))/75:ax(4);
[lons lats]=meshgrid(lx,ly);
[n m]=size(lons);
n_map=n*m;
ll_map=[reshape(lats, n_map, 1) reshape(lons, n_map, 1)];

%initialize the map
givei_map=repmat(MOPS_GIVEI_NM,n_map,1);

%interpolate onto the mesh
temp=grid2uive(ll_map, igp_mask, inv_igp_mask, givei)-20*eps;

%determine the index values
for idx = 2:MOPS_GIVEI_NM-1
  i=find(temp > MOPS_SIG2_GIVE(idx-1) & temp <= MOPS_SIG2_GIVE(idx));
  if(~isempty(i))
    givei_map(i)=idx;
  end
end
  i=find(temp > 0 & temp <= MOPS_SIG2_GIVE(1));
if(~isempty(i))
  givei_map(i)=1;
end


ticklabels=num2str(MOPS_GIVE');
ticklabels(MOPS_GIVEI_NM,:)=' NM';

clf
bartext = ['GIVE (m) - ' num2str(percent*100,2) '%'];

svm_contour(lx,ly,reshape(givei_map,length(ly),length(lx)), ...
            1:MOPS_GIVEI_NM, ticklabels, GRAPH_GIVEI_COLORS, bartext, ...
            'vert')
if(span360 < span180)        
  ax1=axis;
  dx=(ax1(2)-ax1(1))/600;
  dy=(ax1(4)-ax1(3))/600;
  plot(GRAPH_LL_WORLD(:,2)+360+dx,GRAPH_LL_WORLD(:,1)-dy,'k');
  plot(GRAPH_LL_STATE(:,2)+360+dx,GRAPH_LL_STATE(:,1)-dy,'k:');
  plot(GRAPH_LL_WORLD(:,2)+360-dx,GRAPH_LL_WORLD(:,1)+dy,'w');
  plot(GRAPH_LL_STATE(:,2)+360-dx,GRAPH_LL_STATE(:,1)+dy,'w:');
  xticklabel=get(gca,'XTickLabel');
  if iscell(xticklabel)
      xticklabel = cell2mat(xticklabel);
  end
  xticks=str2num(xticklabel);
  idx=find(xticks>=180);
  xticks(idx)=xticks(idx)-360;
  set(gca,'XTickLabel',num2str(xticks));
end
lon_circ=(ax(2)-ax(1))*cos([.1:.1:2]*pi)'/100;
lat_circ=(ax(4)-ax(3))*sin([.1:.1:2]*pi)'/100;
n_igp=size(ll_igp,1);
for idx=1:n_igp
  patch(lon_circ+ll_igp(idx,2),lat_circ+ll_igp(idx,1),givei(idx));
end

axis(ax);

title('GIVE values');




