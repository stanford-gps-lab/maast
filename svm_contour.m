function svm_contour(lons, lats, data, cnt_int, tick_text, colors, ...
                     bar_text, loc)


%*************************************************************************
%*     Copyright c 2013 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
global GRAPH_LL_WORLD GRAPH_LL_STATE

if nargin < 8, loc = 'horiz'; end;


c=contourf(lons,lats,data,cnt_int, 'LineColor', 'none');

%get the existing colormap
m=colormap;

%find the max and min interval
max_int=max(cnt_int);
min_int=min(cnt_int);

%adjust the color of the lowest filled interval
min_data=min(min(data));
if(min_data ~= 0 && min_data < max_int)
  idx=find(floor(cnt_int/min_data))-1;
else
  idx=1;
end
if (idx(1))
  m(fix((min_data-min_int)*(size(m,1))/(max_int-min_int))+1,:) = ...
              colors(idx(1),:);
end
%adjust the colors for the colorbar
idx=fix((cnt_int-min_int)*(size(m,1))/(max_int-min_int))+1;
idx(length(idx))=size(m,1);
m(idx,:)=colors;
colormap(m);
caxis([min_int max_int]);

% fix special cases of all data at or over the top or all at the bottom
if(isempty(c))
    ax = [min(lons) max(lons) min(lats) max(lats)];
    if (min_data >= max_int)
        patch([ax(1) ax(1) ax(2) ax(2) ax(1)], ...
              [ax(3) ax(4) ax(4) ax(3) ax(3)], length(m));
    elseif (max(max(data)) == 0)
        patch([ax(1) ax(1) ax(2) ax(2) ax(1)], ...
              [ax(3) ax(4) ax(4) ax(3) ax(3)], 0);
    end
    axis(ax);
end

shading flat
hold on


if(length(cnt_int)<20)
  H=colorb(cnt_int, tick_text, loc);
else
  H=colorbar(loc);
end
if(loc(1)=='h')
  set(get(H,'Xlabel'),'String',bar_text, 'FontSize', 12);
else
  set(get(H,'Ylabel'),'String',bar_text, 'FontSize', 12);
end
ax=axis;

dx=(ax(2)-ax(1))/600;
dy=(ax(4)-ax(3))/600;
plot(GRAPH_LL_WORLD(:,2)+dx,GRAPH_LL_WORLD(:,1)-dy,'k');
plot(GRAPH_LL_STATE(:,2)+dx,GRAPH_LL_STATE(:,1)-dy,'k:');
plot(GRAPH_LL_WORLD(:,2)-dx,GRAPH_LL_WORLD(:,1)+dy,'w');
plot(GRAPH_LL_STATE(:,2)-dx,GRAPH_LL_STATE(:,1)+dy,'w:');
if ax(1) < -180
    plot(GRAPH_LL_WORLD(:,2)+dx - 360,GRAPH_LL_WORLD(:,1)-dy,'k');
    plot(GRAPH_LL_STATE(:,2)+dx - 360,GRAPH_LL_STATE(:,1)-dy,'k:');
    plot(GRAPH_LL_WORLD(:,2)-dx - 360,GRAPH_LL_WORLD(:,1)+dy,'w');
    plot(GRAPH_LL_STATE(:,2)-dx - 360,GRAPH_LL_STATE(:,1)+dy,'w:');
end
xlabel('Longitude (deg)', 'FontSize', 12);
ylabel('Latitude (deg)', 'FontSize', 12);
axis(ax)
