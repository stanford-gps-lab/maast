function skyplot(el, az, prn, sig, sigma_text, clim)

if nargin < 3
    prn = [];
    sig = [];
    sigma_text =[];
    clim =[];
elseif nargin < 4    
    sig = [];
    sigma_text =[];
    clim =[];
elseif nargin < 5    
    sigma_text =[];   
    clim =[];
elseif nargin < 6    
    clim =[];
end

if length(prn) < length(el)
    prn = [];
end


% el = acos(-G(:,3));
% az = atan2(-G(:,1), -G(:,2));

clf
hold off

xcirc = cos((0:199)*pi/100);
ycirc = sin((0:199)*pi/100);

plot(90*xcirc, 90*ycirc,'k')
hold on
plot(60*xcirc, 60*ycirc,'k')
plot(30*xcirc, 30*ycirc,'k')
plot(80*xcirc, 80*ycirc,'k:')
plot(70*xcirc, 70*ycirc,'k:')
plot(50*xcirc, 50*ycirc,'k:')
plot(40*xcirc, 40*ycirc,'k:')
plot(20*xcirc, 20*ycirc,'k:')
plot(10*xcirc, 10*ycirc,'k:')
plot([0 0],[90 -90], 'k')
plot([90 -90],[0 0], 'k')
plot(90*[cos(pi/6) -cos(pi/6)], 90*[-sin(pi/6) sin(pi/6)], 'k:')
plot(90*[cos(pi/6) -cos(pi/6)], 90*[sin(pi/6) -sin(pi/6)], 'k:')
plot(90*[sin(pi/6) -sin(pi/6)], 90*[-cos(pi/6) cos(pi/6)], 'k:')
plot(90*[sin(pi/6) -sin(pi/6)], 90*[cos(pi/6) -cos(pi/6)], 'k:')
text(0,91,'0 N','FontSize',11, 'HorizontalAlignment', 'Center', 'VerticalAlignment','Bottom')
text(1,63,'30','FontSize',11)
text(1,33,'60','FontSize',11)
text(91*sin(pi/6),91*cos(pi/6),'30','FontSize',11,'HorizontalAlignment', 'Left', 'VerticalAlignment','Bottom')
text(91*cos(pi/6),91*sin(pi/6),'60','FontSize',11,'HorizontalAlignment', 'Left', 'VerticalAlignment','Bottom')
text(91,0,'90 E','FontSize',11, 'HorizontalAlignment', 'Left', 'VerticalAlignment','Middle')
text(91*cos(pi/6),-91*sin(pi/6),'120','FontSize',11,'HorizontalAlignment', 'Left', 'VerticalAlignment','Top')
text(91*sin(pi/6),-91*cos(pi/6),'150','FontSize',11,'HorizontalAlignment', 'Left', 'VerticalAlignment','Top')
text(0,-91,'180 S','FontSize',11, 'HorizontalAlignment', 'Center', 'VerticalAlignment','Top')
text(-91*sin(pi/6),-91*cos(pi/6),'210','FontSize',11,'HorizontalAlignment', 'Right', 'VerticalAlignment','Top')
text(-91*cos(pi/6),-91*sin(pi/6),'240','FontSize',11,'HorizontalAlignment', 'Right', 'VerticalAlignment','Top')
text(-91,0,'W 270','FontSize',11,'HorizontalAlignment', 'Right', 'VerticalAlignment','Middle')
text(-91*cos(pi/6),91*sin(pi/6),'300','FontSize',11,'HorizontalAlignment', 'Right', 'VerticalAlignment','Bottom')
text(-91*sin(pi/6),91*cos(pi/6),'330','FontSize',11,'HorizontalAlignment', 'Right', 'VerticalAlignment','Bottom')

xx = (90-el*180/pi).*sin(az);
yy = (90-el*180/pi).*cos(az);

if ~isempty(sig)
    if ~isempty(clim)
        cmax = clim(2);
        cmin = clim(1);
    else
        cmax = ceil(2*max(sig))/2;
        cmin = floor(2*min(sig))/2;
    end
    colors   = colormap;

    for i =length(xx):-1:1
        c_idx   = ceil(63*((sig(i)-cmin)/(cmax-cmin))) + 1;
        plot(xx(i),yy(i),'go', 'MarkerFaceColor',colors(c_idx,:), 'MarkerSize', 21,'LineWidth',2);
        if ~isempty(prn)
            text(xx(i),yy(i),num2str(prn(i)),'FontSize',12,'HorizontalAlignment', 'Center', 'VerticalAlignment','Middle', 'Color', 'k');
        end
    end
    set(gca,'CLim',[cmin cmax]);
else
    for i =length(xx):-1:1
        plot(xx(i),yy(i),'go', 'MarkerSize', 21,'LineWidth',2);
        if ~isempty(prn)
            text(xx(i),yy(i),num2str(prn(i)),'FontSize',12,'HorizontalAlignment', 'Center', 'VerticalAlignment','Middle', 'Color', 'k');
        end
    end
end

set(gca, 'XTick', [])
set(gca, 'YTick', [])
axis('square')

if ~isempty(sigma_text)
    H = colorbar('vert');
    set(get(H,'Ylabel'),'String',['{\fontsize{14pt}' sigma_text '}']);
end
axis off
set(gca,'Box','Off')
