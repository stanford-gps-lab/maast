function init_gui()
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
% globals for GUI objects

global GUI_GIVE_MENU
global GUI_UDREGPS_ALGO GUI_UDREGEO_ALGO GUI_GIVE_ALGO GUI_IGPMASK_DAT ...
        GUI_WRSCNMP_ALGO GUI_USRCNMP_ALGO 
global GUI_UDREGPS_INIT GUI_UDREGEO_INIT GUI_GIVE_INIT GUI_WRSTRP_INIT ...
        GUI_USRTRP_INIT GUI_WRSCNMP_INIT GUI_USRCNMP_INIT 
global GUI_WRS_DAT GUI_USR_DAT GUI_SV_DAT GUI_GEOPOS_DAT
global GUI_OUT_AVAIL GUI_OUT_UDREMAP GUI_OUT_GIVEMAP GUI_OUT_COVAVAIL...
        GUI_OUT_UDREHIST GUI_OUT_GIVEHIST GUI_OUT_VHPL
global GUI_UDREGPS_HNDL GUI_UDREGEO_HNDL GUI_GIVE_HNDL GUI_IGPMASK_HNDL ...
        GUI_WRSCNMP_HNDL GUI_USRCNMP_HNDL ...
        GUI_WRS_HNDL GUI_WRSPB_HNDL GUI_USR_HNDL GUI_SV_HNDL GUI_GEO_HNDL ...
        GUI_OUT_HNDL GUI_GPS_HNDL GUI_GALILEO_HNDL
global GUI_PAMODE_HNDL GUI_HAL_HNDL GUI_VAL_HNDL;    
global GUI_RUN_HNDL GUI_PLOT_HNDL GUI_SETTINGS_HNDL GUI_PERCENT_HNDL ...
        GUI_UDRECONST_HNDL GUI_GEOCONST_HNDL GUI_GIVECONST_HNDL ...
        GUI_LATSTEP_HNDL GUI_LONSTEP_HNDL GUI_WEEKNUM_HNDL GUI_TSTART_HNDL ...
        GUI_TEND_HNDL GUI_TSTEP_HNDL
global MOPS_UDRE MOPS_GIVE MOPS_VAL MOPS_HAL;

% init flags from settings menu
global SETTINGS_FIRST TRUTH_FLAG;
SETTINGS_FIRST = 0;
TRUTH_FLAG = 0;

% Algorithms
% Menu items
GUI_UDREGPS_MENU = {'ADD','ADDR8/9','Constant','Custom1','Custom2'};
GUI_UDREGEO_MENU = {'ADD','ADDR8/9','Constant','Custom1','Custom2'};
GUI_GIVE_MENU    = {'ADD','ADDR6/7','Constant','ADDR8/9','Dual Freq'};
GUI_IGPMASK_MENU  = {'IOC','Release 6/7', 'Release 8/9', 'EGNOS', 'MSAS','Brazil'};
GUI_WRSCNMP_MENU = {'ADD-DET','ADD-Agg','Custom'};
GUI_USRCNMP_MENU = {'MOPS','AAD-A','AAD-B'};

GUI_UDREGPS_ALGO = {'af_udreadd','af_udreadd2','af_udreconst',...
                    'af_udrecustom1','af_udrecustom2'};
GUI_UDREGEO_ALGO = {'af_geoadd','af_geoadd2','af_geoconst',...
                    'af_geocustom1','af_geocustom2'};
GUI_GIVE_ALGO    = {'af_giveadd','af_giveadd1','af_giveconst',...
                    'af_giveadd2',''};
GUI_IGPMASK_DAT  = {'igpjoint.txt','igpjoint_R6_7.txt', 'igpjoint_R8_9.txt',...
                    'igpegnos.txt', 'igpmsas.txt', 'igpbrazil.txt'};
GUI_USRTRP_ALGO  = {'af_trpmops','af_trpadd'};
GUI_WRSCNMP_ALGO = {'af_cnmpadd','af_cnmpagg','af_wrscnmpcustom'};
GUI_USRCNMP_ALGO = {'af_cnmp_mops','af_cnmpaad','af_cnmpaad'};

GUI_UDREGPS_INIT = {'init_udre_osp','init_udre2_osp','','',''};
GUI_UDREGEO_INIT = {'init_geo_osp','init_geo2_osp','','',''};
GUI_GIVE_INIT = {'init_give_osp','init_giveadd1_osp','','init_giveadd2_osp',''};
GUI_WRSTRP_INIT = {'init_trop_osp',''};
GUI_USRTRP_INIT = {'','init_trop_osp'};
GUI_WRSCNMP_INIT = {'init_cnmp','',''};
GUI_USRCNMP_INIT = {'init_cnmp_mops','init_aada','init_aadb'};

% Simulation Configs
% Menu items
GUI_WRS_MENU = {'WRS IOC','WRS R6/7','WRS R8/9','EGNOS','MSAS','Brazil',...
                'World_16','World_30','Custom1','Custom2'};
GUI_USR_MENU = {'CONUS','Alaska','Canada','Mexico','N. America','Europe',...
                'Japan', 'Brazil','World'} ;
GUI_SV_MENU = {'Alm MOPS','Alm Yuma'};
GUI_GEO_MENU = {'AOR/POR','waasAOR','waasPOR','Custom'};

GUI_WRS_DAT = {'wrs25.txt','wrs_R6_7.txt','wrs_R8_9.txt','egnos_rims.txt', ...
               'rs_msas.txt','brazil_wrs.txt','wrs_world16.txt','wrs_world30.txt','',''};
GUI_USR_DAT = {'usrconus.txt','usralaska.txt','usrcanada.txt','usrmexico.txt',...
               'usrn_america.txt','usreurope.txt','usrmsas.txt','usrbrazil.txt','usrworld.txt'};
GUI_SV_DAT = {'almmops.txt','almyuma.txt'};
GUI_GEO_DAT = {'GEO1','GEO2','GEO3','GEO4','GEO5','GEO6','GEO7','GEO8','GEO9',...
               'GEO10','GEO11'};

% Outputs
GUI_OUT_AVAIL = 1;
GUI_OUT_VHPL = 2;
GUI_OUT_UDREMAP = 3;
GUI_OUT_GIVEMAP = 4;
GUI_OUT_UDREHIST = 5;
GUI_OUT_GIVEHIST = 6;
GUI_OUT_COVAVAIL = 7;

% tag fields for buttons
GUI_UDREGPS_TAGS = {'UGPS1','UGPS2','UGPS3','UGPS4','UGPS5'};
GUI_UDREGEO_TAGS = {'UGEO1','UGEO2','UGEO3','UGEO4','UGEO5'};
GUI_GIVE_TAGS    = {'GIVE1','GIVE2','GIVE3','GIVE4','GIVE5'};
GUI_IGPMASK_TAGS = {'IGPM1','IGPM2','IGPM3','IGPM4','IGPM5','IGPM6'};
GUI_WRSCNMP_TAGS = {'CNMW1','CNMW2','CNMW3'};
GUI_USRCNMP_TAGS = {'CNMU1','CNMU2','CNMU3'};
GUI_WRS_TAGS = {'WRSS1','WRSS2','WRSS3','WRSS4','WRSS5','WRSS6','WRSS7',...
                'WRSS8','WRSS9','WRSS10'};
GUI_WRSPB_TAGS={'pbWrsList','pbWrsMap'};
GUI_USR_TAGS = {'USER1','USER2','USER3','USER4','USER5','USER6','USER7','USER8','USER9'};
GUI_SV_TAGS  = {'SATS1','SATS2'};
GUI_GPS_TAG = 'GPSSELECT';
GUI_GALILEO_TAG = 'GALILEOSELECT';
GUI_GEO_TAGS = {'GEOpos1','GEOpos2','GEOpos3','GEOpos4','GEOpos5','GEOpos6',...
                'GEOpos7','GEOpos8','GEOpos9','GEOpos10','GEOpos11'};          
GUI_PAMODE_TAGS = {'PAmode','NPAmode'};
GUI_OUT_TAGS = {'cbAvail','cbVHPL','cbUdremap','cbGivemap',...
                'cbUdrehist','cbGivehist', 'cbCovAvail'};


% handles for buttons
%deactivate buttons without corresponding files 
%default is first active one on the list

%UDRE GPS buttons
default=1;
for i = 1:length(GUI_UDREGPS_TAGS)
    GUI_UDREGPS_HNDL(i) = findobj('Tag',GUI_UDREGPS_TAGS{i});
    if(isempty(GUI_UDREGPS_ALGO{i}) || isempty(which(GUI_UDREGPS_ALGO{i})) || ...
       (~isempty(GUI_UDREGPS_INIT{i}) && isempty(which(GUI_UDREGPS_INIT{i}))))
      set(GUI_UDREGPS_HNDL(i), 'Enable', 'off', 'Value', 0);
    else  
      set(GUI_UDREGPS_HNDL(i), 'Enable', 'on', 'String', GUI_UDREGPS_MENU{i});
      if (default)
        set(GUI_UDREGPS_HNDL(i), 'Value', 1);
        default=0;
      end   
    end
end

%UDRE GEO buttons
default=1;
for i = 1:length(GUI_UDREGEO_TAGS)
    GUI_UDREGEO_HNDL(i) = findobj('Tag',GUI_UDREGEO_TAGS{i});
    if(isempty(GUI_UDREGEO_ALGO{i}) || isempty(which(GUI_UDREGEO_ALGO{i})) || ...
       (~isempty(GUI_UDREGEO_INIT{i}) && isempty(which(GUI_UDREGEO_INIT{i}))))
      set(GUI_UDREGEO_HNDL(i), 'Enable', 'off', 'Value', 0);
    else  
      set(GUI_UDREGEO_HNDL(i), 'Enable', 'on', 'String', GUI_UDREGEO_MENU{i});
      if (default)
        set(GUI_UDREGEO_HNDL(i), 'Value', 1);
        default=0;
      end   
    end
end

%GIVE buttons
default=1;
for i = 1:length(GUI_GIVE_TAGS)
    GUI_GIVE_HNDL(i) = findobj('Tag',GUI_GIVE_TAGS{i});
    if(isempty(GUI_GIVE_ALGO{i}) || isempty(which(GUI_GIVE_ALGO{i})) || ...
       (~isempty(GUI_GIVE_INIT{i}) && isempty(which(GUI_GIVE_INIT{i}))))
      set(GUI_GIVE_HNDL(i), 'Enable', 'off', 'Value', 0);
    else  
      set(GUI_GIVE_HNDL(i), 'Enable', 'on', 'String', GUI_GIVE_MENU{i});
      if (default)
        set(GUI_GIVE_HNDL(i), 'Value', 1);
        default=0;
      end   
    end
end
%activate dual frequency button
i = length(GUI_GIVE_TAGS);
if GUI_GIVE_MENU{i} == 'Dual Freq'
    set(GUI_GIVE_HNDL(i), 'Enable', 'on', 'String', GUI_GIVE_MENU{i});
end

%IGP Mask buttons
default=1;
for i = 1:length(GUI_IGPMASK_TAGS)
    GUI_IGPMASK_HNDL(i) = findobj('Tag',GUI_IGPMASK_TAGS{i});
    if(isempty(GUI_IGPMASK_DAT{i}) || isempty(which(GUI_IGPMASK_DAT{i})))
      set(GUI_IGPMASK_HNDL(i), 'Enable', 'off', 'Value', 0);
    else  
      set(GUI_IGPMASK_HNDL(i), 'Enable', 'on');
      if (default)
        set(GUI_IGPMASK_HNDL(i), 'Value', 1);
        default=0;
      end   
    end
end


%WRS CNMP buttons
default=1;
for i = 1:length(GUI_WRSCNMP_TAGS)
    GUI_WRSCNMP_HNDL(i) = findobj('Tag',GUI_WRSCNMP_TAGS{i});
    if(isempty(GUI_WRSCNMP_ALGO{i}) || isempty(which(GUI_WRSCNMP_ALGO{i})) || ...
       (~isempty(GUI_WRSCNMP_INIT{i}) && isempty(which(GUI_WRSCNMP_INIT{i}))))
      set(GUI_WRSCNMP_HNDL(i), 'Enable', 'off', 'Value', 0);
    else  
      set(GUI_WRSCNMP_HNDL(i), 'Enable', 'on');
      if (default)
        set(GUI_WRSCNMP_HNDL(i), 'Value', 1);
        default=0;
      end   
    end
end

%user CNMP buttons
default=1;
for i = 1:length(GUI_USRCNMP_TAGS)
    GUI_USRCNMP_HNDL(i) = findobj('Tag',GUI_USRCNMP_TAGS{i});
    if(isempty(GUI_USRCNMP_ALGO{i}) || isempty(which(GUI_USRCNMP_ALGO{i})) || ...
       (~isempty(GUI_USRCNMP_INIT{i}) && isempty(which(GUI_USRCNMP_INIT{i}))))
      set(GUI_USRCNMP_HNDL(i), 'Enable', 'off', 'Value', 0, 'String', GUI_USRCNMP_MENU{i});
    else  
      set(GUI_USRCNMP_HNDL(i), 'Enable', 'on', 'String', GUI_USRCNMP_MENU{i});
      if (default)
        set(GUI_USRCNMP_HNDL(i), 'Value', 1);
        default=0;
      end   
    end
end

%WRS menu buttons 
default=1;
for i = 1:length(GUI_WRS_TAGS)
    GUI_WRS_HNDL(i) = findobj('Tag',GUI_WRS_TAGS{i});
    if(isempty(GUI_WRS_DAT{i}) || isempty(which(GUI_WRS_DAT{i})))
      set(GUI_WRS_HNDL(i), 'Enable', 'off', 'Value', 0, 'String', GUI_WRS_MENU{i});
    else  
      set(GUI_WRS_HNDL(i), 'Enable', 'on' ,'Value', 0, 'String', GUI_WRS_MENU{i});
      if (default)
        set(GUI_WRS_HNDL(i), 'Value', 1);
        default=0;
      end   
    end
end
for i = 1:length(GUI_WRSPB_TAGS)
    GUI_WRSPB_HNDL(i) = findobj('Tag',GUI_WRSPB_TAGS{i});
end

%user menu buttons 
default=1;
for i = 1:length(GUI_USR_TAGS)
    GUI_USR_HNDL(i) = findobj('Tag',GUI_USR_TAGS{i});
    if(isempty(GUI_USR_DAT{i}) || isempty(which(GUI_USR_DAT{i})))
      set(GUI_USR_HNDL(i), 'Enable', 'off', 'Value', 0, 'String', GUI_USR_MENU{i});
    else  
      set(GUI_USR_HNDL(i), 'Enable', 'on', 'Value', 0, 'String', GUI_USR_MENU{i});
      if (default)
        set(GUI_USR_HNDL(i), 'Value', 1);
        default=0;
      end   
    end
end

%satellite menu buttons 
for i = 1:length(GUI_SV_TAGS)
    GUI_SV_HNDL(i) = findobj('Tag',GUI_SV_TAGS{i});
end

GUI_GPS_HNDL = findobj('Tag',GUI_GPS_TAG);
GUI_GALILEO_HNDL = findobj('Tag',GUI_GALILEO_TAG);

%GEO position menu buttons 
%search through geo.txt and find PRNs latitudes and button names
load geo.txt;
GUI_GEOPOS_DAT=geo;
ngeo=size(geo,1);
fid=fopen('geo.txt');
line='%';
while(ischar(line))
  if(line(1) ~= '%')
    prn=str2double(line(1:3));
    idx=find(geo(:,1)==prn);
    fst=findstr(line,'%')+1;
    lst=length(line);
    geoname{idx}=sscanf(line(fst:lst),'%s');
  end
  line=fgets(fid);
end
for i = 1:length(GUI_GEO_TAGS)
    GUI_GEO_HNDL(i) = findobj('Tag',GUI_GEO_TAGS{i});
    if(i > ngeo || isempty(geoname{i}))
      set(GUI_GEO_HNDL(i), 'Enable', 'off', 'Value', 0);
    else  
      set(GUI_GEO_HNDL(i), 'Enable', 'on', 'String', geoname{i}, ...
                           'Value', geo(i,14));
    end
end

% mode / alert limit buttons & boxes
for i = 1:length(GUI_PAMODE_TAGS)
    GUI_PAMODE_HNDL(i) = findobj('Tag',GUI_PAMODE_TAGS{i});
end
GUI_HAL_HNDL = findobj('Tag','txtHAL');
set(GUI_HAL_HNDL, 'String', num2str(MOPS_HAL));
GUI_VAL_HNDL = findobj('Tag','txtVAL');
set(GUI_VAL_HNDL, 'String', num2str(MOPS_VAL));

% output menu buttons
for i = 1:length(GUI_OUT_TAGS)
    GUI_OUT_HNDL(i) = findobj('Tag',GUI_OUT_TAGS{i});
end
GUI_RUN_HNDL = findobj('Tag','pbRun');
GUI_PLOT_HNDL = findobj('Tag','pbPlot');
GUI_SETTINGS_HNDL = findobj('Tag','pbSettings');
GUI_PERCENT_HNDL = findobj('Tag','txtPercent');

%UDRE GPS constant popup menu
GUI_UDRECONST_HNDL = findobj('Tag','PopupUDREGPS');
set(GUI_UDRECONST_HNDL,'String',num2str(MOPS_UDRE(1:14)'),'Value',5);
if(get(GUI_UDREGPS_HNDL(3),'Value') == 1)
  set(GUI_UDRECONST_HNDL, 'Enable', 'on');
else
  set(GUI_UDRECONST_HNDL, 'Enable', 'off');
end

%UDRE GEO constant popup menu
GUI_GEOCONST_HNDL = findobj('Tag','PopupUDREGEO');
set(GUI_GEOCONST_HNDL,'String',num2str(MOPS_UDRE(1:14)'),'Value',12);
if(get(GUI_UDREGEO_HNDL(3),'Value') == 1)
  set(GUI_GEOCONST_HNDL, 'Enable', 'on');
else
  set(GUI_GEOCONST_HNDL, 'Enable', 'off');
end

%GIVE constant popup menu
GUI_GIVECONST_HNDL = findobj('Tag','PopupGIVE');
set(GUI_GIVECONST_HNDL,'String',num2str(MOPS_GIVE(1:15)'),'Value',12);
if(get(GUI_GIVE_HNDL(3),'Value') == 1)
  set(GUI_GIVECONST_HNDL, 'Enable', 'on');
else
  set(GUI_GIVECONST_HNDL, 'Enable', 'off');
end
GUI_LATSTEP_HNDL = findobj('Tag','txtUsrLatStep');
GUI_LONSTEP_HNDL = findobj('Tag','txtUsrLonStep');
GUI_WEEKNUM_HNDL = findobj('Tag','txtWeekNum');
GUI_TSTART_HNDL = findobj('Tag','txtTStart');
GUI_TEND_HNDL = findobj('Tag','txtTEnd');
GUI_TSTEP_HNDL = findobj('Tag','txtTStep');

%% TODO:  Automatic creation of gui menu

% fix text sizing to 10 points

allh = get(gcf,'Children');
n = length(allh);

for i=1:n,
    set(allh(i),'units','normalized');
end
for i=1:n,
    set(allh(i),'fontunits','points');
    set(allh(i),'fontsize',10);
end






