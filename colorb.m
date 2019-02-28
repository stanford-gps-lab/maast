function handle=colorb(levels, ticklabels, loc)
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
%COLORB Modified Display color bar (color scale).
%   COLORB(levels, tick_labels, 'vert') appends a vertical color scale to
%   the current axis. COLORB(levels, tick_labels, 'horiz') appends a
%   horizontal color scale. levels specifies the intervals for the colorbar
%   and ticklabels contains the text to label them
%
%   H = COLORB(...) returns a handle to the colorbar axis.

%   Clay M. Thompson 10-9-92
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.31 $  $Date: 1998/07/24 18:08:03 $
%   Modified by Todd Walter 02 Apr 2001

%   If called with COLORBAR(H) or for an existing colorbar, don't change
%   the NextPlot property.
changeNextPlot = 1;

if nargin<1, levels=1:size(colormap,1); ticklabels=[]; loc = 'vert'; end
if nargin<2, ticklabels=[]; loc = 'vert'; end
if nargin<3, loc = 'vert'; end



ax = [];
if nargin==3,
    if ishandle(loc)
        ax = loc;
        if ~strcmp(get(ax,'type'),'axes'),
            error('Requires axes handle.');
        end
        units = get(ax,'units'); set(ax,'units','pixels');
        rect = get(ax,'position'); set(ax,'units',units)
        if rect(3) > rect(4), loc = 'horiz'; else loc = 'vert'; end
        changeNextPlot = 0;
    end
end

% Determine color limits by context.  If any axes child is an image
% use scale based on size of colormap, otherwise use current CAXIS.

ch = get(gcda,'children');
hasimage = 0; t = [];
cdatamapping = 'direct';

for i=1:length(ch),
    typ = get(ch(i),'type');
    if strcmp(typ,'image'),
        hasimage = 1;
        cdatamapping = get(ch(i), 'CDataMapping');
    elseif strcmp(typ,'surface') & ...
            strcmp(get(ch(i),'FaceColor'),'texturemap') % Texturemapped surf
        hasimage = 2;
        cdatamapping = get(ch(i), 'CDataMapping');
    elseif strcmp(typ,'patch') | strcmp(typ,'surface')
        cdatamapping = get(ch(i), 'CDataMapping');
    end
end

if ( strcmp(cdatamapping, 'scaled') )
  % Treat images and surfaces alike if cdatamapping == 'scaled'
  t = caxis;
  d = (t(2) - t(1))/size(colormap,1);
  t = [t(1)+d/2  t(2)-d/2];
else
    if hasimage,
        t = [1, size(colormap,1)]; 
    else
        t = [1.5  size(colormap,1)+.5];
    end
end
n_levels=length(levels);
t=[1 n_levels];
h = gcda;



origNextPlot = get(gcf,'NextPlot');
if strcmp(origNextPlot,'replacechildren') | strcmp(origNextPlot,'replace'),
    set(gcf,'NextPlot','add')
end

if loc(1)=='v', % Append vertical scale to right of current plot
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position'); 
        [az,el] = view;
        stripe = 0.075; edge = 0.02; 
        if all([az,el]==[0 90]), space = 0.05; else space = .1; end
        set(h,'Position',[pos(1) pos(2) pos(3)*(1-stripe-edge-space) pos(4)])
        rect = [pos(1)+(1-stripe-edge)*pos(3) pos(2) stripe*pos(3) pos(4)];
        ud.origPos = pos;
        
        % Create axes for stripe and
        % create DeleteProxy object (an invisible text object in
        % the target axes) so that the colorbar will be deleted
        % properly.
        ud.DeleteProxy = text('parent',h,'visible','off',...
                              'tag','ColorbarDeleteProxy',...
                              'handlevisibility','off',...
             'deletefcn','eval(''delete(get(gcbo,''''userdata''''))'','''')');
        ax = axes('Position', rect);
%        setappdata(ax,'NonDataObject',[]); % For DATACHILDREN.M
        set(ud.DeleteProxy,'userdata',ax)
        set(h,'units',units)
    else
        axes(ax);
        ud = get(ax,'userdata');
    end
    
    % Create color stripe
    n = size(colormap,1);
    idx=fix((levels-min(levels))*n/(max(levels)-min(levels)))+1;
    idx(n_levels)=n;
    image([0 1],t, idx', 'Tag', 'TMW_COLORBAR', 'deletefcn',...
          'colorbar(''delete'')'); 
    set(ax,'Ydir','normal');
    set(ax,'YAxisLocation','right')
    set(ax,'ytick',(1:n_levels));
    if(~isempty(ticklabels))
      set(ax,'yticklabel',ticklabels);
    end
    set(ax,'xtick',[]);

    % set up axes deletefcn
    set(ax,'tag','Colorbar','deletefcn','colorbar(''delete'')')
    
elseif loc(1)=='h', % Append horizontal scale to top of current plot
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position');
        stripe = 0.075; space = 0.1;
        set(h,'Position',...
            [pos(1) pos(2)+(stripe+space)*pos(4) pos(3) (1-stripe-space)*pos(4)])
        rect = [pos(1) pos(2) pos(3) stripe*pos(4)];
        ud.origPos = pos;

        % Create axes for stripe and
        % create DeleteProxy object (an invisible text object in
        % the target axes) so that the colorbar will be deleted
        % properly.
        ud.DeleteProxy = text('parent',h,'visible','off',...
                              'tag','ColorbarDeleteProxy',...
                              'handlevisibility','off',...
             'deletefcn','eval(''delete(get(gcbo,''''userdata''''))'','''')');
        ax = axes('Position', rect);
%        setappdata(ax,'NonDataObject',[]); % For DATACHILDREN.M
        set(ud.DeleteProxy,'userdata',ax)
        set(h,'units',units)
    else
        axes(ax);
        ud = get(ax,'userdata');
    end
    
    % Create color stripe
    n = size(colormap,1);
    idx=fix((levels-min(levels))*n/(max(levels)-min(levels)))+1;
    idx(n_levels)=n;
    image(t,[0 1], idx, 'Tag','TMW_COLORBAR', 'deletefcn', ...
          'colorbar(''delete'')');
    set(ax,'Ydir','normal');
    set(ax,'xtick',(1:n_levels));
    if(~isempty(ticklabels))
      set(ax,'xticklabel',ticklabels);
    end
    set(ax,'ytick',[]);

    % set up axes deletefcn
    set(ax,'tag','Colorbar','deletefcn','colorbar(''delete'')')
    
else
  error('COLORBAR expects a handle, ''vert'', or ''horiz'' as input.')
end

if ~isfield(ud,'DeleteProxy'), ud.DeleteProxy = []; end
if ~isfield(ud,'origPos'), ud.origPos = []; end
ud.PlotHandle = h;
set(ax,'userdata',ud)
axes(h)
set(gcf,'NextPlot',origNextPlot)
%if ~isempty(legend)
%  legend % Update legend
%end
if nargout>0, handle = ax; end

%--------------------------------
function h = gcda
%GCDA Get current data axes

%h = datachildren(gcf);
h = [];
if isempty(h) | any(h == gca)
  h = gca;
else
  h = h(1);
end

