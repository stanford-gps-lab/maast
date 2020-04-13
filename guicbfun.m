function guicbfun(hndl)
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
% BUGS: screws up when you open another figure because figure handle is lost
% hndl - handle of button pressed
% Modified 

global GUI_GIVE_MENU
global GUI_UDREGPS_ALGO GUI_UDREGEO_ALGO GUI_GIVE_ALGO GUI_IGPMASK_DAT ...
        GUI_WRSCNMP_ALGO GUI_USRCNMP_ALGO GUI_GPS_SV ...
        GUI_GALILEO_SV
global GUI_UDREGPS_INIT GUI_UDREGEO_INIT GUI_GIVE_INIT  ...
         GUI_WRSCNMP_INIT GUI_USRCNMP_INIT 
global GUI_WRS_DAT GUI_USR_DAT  GUI_GEOPOS_DAT 
global GUI_UDREGPS_HNDL GUI_UDREGEO_HNDL GUI_GIVE_HNDL GUI_IGPMASK_HNDL ...
        GUI_WRSCNMP_HNDL GUI_USRCNMP_HNDL ...
        GUI_WRS_HNDL GUI_WRSPB_HNDL GUI_USR_HNDL GUI_SV_HNDL GUI_GEO_HNDL ...
        GUI_OUT_HNDL GUI_GPS_HNDL GUI_GALILEO_HNDL
global  GUI_PAMODE_HNDL GUI_HAL_HNDL GUI_VAL_HNDL
global GUI_RUN_HNDL GUI_PLOT_HNDL GUI_SETTINGS_HNDL GUI_PERCENT_HNDL ...
        GUI_UDRECONST_HNDL GUI_GEOCONST_HNDL GUI_GIVECONST_HNDL ...
        GUI_LATSTEP_HNDL GUI_LONSTEP_HNDL GUI_WEEKNUM_HNDL GUI_TSTART_HNDL ...
        GUI_TEND_HNDL GUI_TSTEP_HNDL
global UDREI_CONST GEOUDREI_CONST GIVEI_CONST;
global SETTINGS_TR_HNDL SETTINGS_TR_DAT SETTINGS_CLOSE_HNDL SETTINGS_WIND_HNDL SETTINGS_FIRST
global TRUTH_FLAG TRUTH_FILE SETTINGS_TR_FILE
global SETTINGS_BR_HNDL SETTINGS_BR_FILE SETTINGS_BR_DAT
global GUISET_RUN_HNDL BRAZPARAMS RTR_FLAG IPP_SPREAD_FLAG
global MOPS_VAL MOPS_HAL MOPS_NPA_HAL

if ismember(hndl,GUI_UDREGPS_HNDL)
    gui_mexclude(GUI_UDREGPS_HNDL,hndl);
	%only activate popup menu if constant is selected
    if(hndl == GUI_UDREGPS_HNDL(3))
		set(GUI_UDRECONST_HNDL, 'Enable', 'on');
	else
		set(GUI_UDRECONST_HNDL, 'Enable', 'off');
    end
elseif ismember(hndl,GUI_UDREGEO_HNDL)
    gui_mexclude(GUI_UDREGEO_HNDL,hndl);
	%only activate popup menu if constant is selected
    if(hndl == GUI_UDREGEO_HNDL(3))
		set(GUI_GEOCONST_HNDL, 'Enable', 'on');
    else
		set(GUI_GEOCONST_HNDL, 'Enable', 'off');
    end
elseif ismember(hndl,GUI_GIVE_HNDL)
    gui_mexclude(GUI_GIVE_HNDL,hndl);
	%only activate popup menu if constant is selected
    if(hndl == GUI_GIVE_HNDL(3))
		set(GUI_GIVECONST_HNDL, 'Enable', 'on');
	else
		set(GUI_GIVECONST_HNDL, 'Enable', 'off');
    end
elseif ismember(hndl,GUI_IGPMASK_HNDL)
    gui_mexclude(GUI_IGPMASK_HNDL,hndl);
elseif ismember(hndl,GUI_WRSCNMP_HNDL)
    gui_mexclude(GUI_WRSCNMP_ALGO,hndl);
elseif ismember(hndl,GUI_USRCNMP_HNDL)
    gui_mexclude(GUI_USRCNMP_HNDL,hndl);
elseif ismember(hndl,GUI_USR_HNDL)
    gui_mexclude(GUI_USR_HNDL,hndl);
elseif ismember(hndl,GUI_WRS_HNDL)
    gui_mexclude(GUI_WRS_HNDL,hndl);
elseif ismember(hndl,GUI_SV_HNDL)
    gui_mexclude(GUI_SV_HNDL,hndl);
elseif hndl == GUI_GPS_HNDL
    if (get(GUI_GPS_HNDL,'Value') + get(GUI_GALILEO_HNDL,'Value')) == 0
        set(GUI_GPS_HNDL,'Value', 1);
    end
elseif hndl == GUI_GALILEO_HNDL
    if (get(GUI_GPS_HNDL,'Value') + get(GUI_GALILEO_HNDL,'Value')) == 0
        set(GUI_GPS_HNDL,'Value', 1);
    end    
    if get(GUI_GALILEO_HNDL,'Value')
        set(GUI_SV_HNDL(2),'Value', 0, 'Enable', 'off');
        set(GUI_WEEKNUM_HNDL, 'Enable', 'off');
        set(GUI_SV_HNDL(1),'Value', 1);
    else
        set(GUI_SV_HNDL(2), 'Enable', 'on');        
        set(GUI_WEEKNUM_HNDL, 'Enable', 'on');
    end
elseif ismember(hndl,GUI_GEO_HNDL)
       % do nothing
elseif ismember(hndl,GUI_PAMODE_HNDL)
    gui_mexclude(GUI_PAMODE_HNDL,hndl);
    if get(GUI_PAMODE_HNDL(2),'Value')
        set(GUI_VAL_HNDL, 'Enable', 'off');
        set(GUI_HAL_HNDL, 'String', num2str(MOPS_NPA_HAL));
    else
        set(GUI_VAL_HNDL, 'Enable', 'on');
        set(GUI_HAL_HNDL, 'String', num2str(MOPS_HAL));        
    end
elseif ismember(hndl,GUI_OUT_HNDL)
       % do nothing
elseif ismember(hndl,SETTINGS_TR_HNDL)   % Settings Truth-Data input menu
    gui_mexclude([SETTINGS_TR_HNDL SETTINGS_BR_HNDL], hndl)
    if (hndl == SETTINGS_TR_HNDL(1))
        TRUTH_FLAG = 0;
    else
        TRUTH_FLAG = 1;
    end;
    i = gui_readselect(SETTINGS_TR_HNDL);
    TRUTH_FILE = SETTINGS_TR_FILE(i);
    if (TRUTH_FLAG == 1) % Set alm number, tstart, tend for MAAST
        guicbfun(GUI_SV_HNDL(2));
        set(GUI_WEEKNUM_HNDL, 'String', num2str(SETTINGS_TR_DAT(i, 1)));
        set(GUI_TSTART_HNDL, 'String', num2str(SETTINGS_TR_DAT(i, 2)));
        set(GUI_TEND_HNDL, 'String', num2str(SETTINGS_TR_DAT(i, 3)));
   end;
elseif ismember(hndl, SETTINGS_BR_HNDL)
    % make sure that brazil is selected in wrs menu and usr menu
    guicbfun(GUI_WRS_HNDL(5));
    guicbfun(GUI_USR_HNDL(6));
        
    gui_mexclude([SETTINGS_TR_HNDL SETTINGS_BR_HNDL], hndl)
    TRUTH_FLAG = 1;
    i = gui_readselect(SETTINGS_BR_HNDL);
    TRUTH_FILE = SETTINGS_BR_FILE(i);
    
    guicbfun(GUI_SV_HNDL(2));
    
    set(GUI_WEEKNUM_HNDL, 'String', num2str(SETTINGS_BR_DAT(i, 1)));
    set(GUI_TSTART_HNDL, 'String', num2str(SETTINGS_BR_DAT(i, 2)));
    set(GUI_TEND_HNDL, 'String', num2str(SETTINGS_BR_DAT(i, 3)));
    
elseif hndl == SETTINGS_CLOSE_HNDL
    set(SETTINGS_WIND_HNDL, 'Visible', 'Off');
elseif ismember(hndl, GUISET_RUN_HNDL)
       % do nothing
else   % Other non-option buttons

    switch (hndl)
    case {GUI_RUN_HNDL,GUI_PLOT_HNDL,GUI_WRSPB_HNDL(1),GUI_WRSPB_HNDL(2)}

    % READ SELECTIONS FROM EACH MENU
    
    % Run Options Menu (Settings) 
    if SETTINGS_FIRST == 0 % we haven't opened this menu, all flags are 0
        BRAZPARAMS = 0;
        RTR_FLAG = 0;
        IPP_SPREAD_FLAG = 0;
    else
        i = gui_readselect(GUISET_RUN_HNDL);
        BRAZPARAMS = sum(ismember(i,1));
        RTR_FLAG = sum(ismember(i,2));
        IPP_SPREAD_FLAG = sum(ismember(i,3));
    end;
    
    % OUTPUT Menu
        init_hist;
        outputs = zeros(length(GUI_OUT_HNDL),1);
        i = gui_readselect(GUI_OUT_HNDL);
        outputs(i) = 1;
        % read percentage
        percent = gui_readnum(GUI_PERCENT_HNDL,0,100,...
            'Please input valid Percent and run again.') / 100;
        if isnan(percent)
            return;
        end

    % UDRE GPS Menu

        i = gui_readselect(GUI_UDREGPS_HNDL);
        gpsudrefun = GUI_UDREGPS_ALGO{i};
        if(~isempty(GUI_UDREGPS_INIT{i}))
          feval(GUI_UDREGPS_INIT{i});
        end
        % check udre constant
        if strcmp(gpsudrefun,'af_udreconst')
            UDREI_CONST = get(GUI_UDRECONST_HNDL,'Value');
        end

    % UDRE GEO Menu

        i = gui_readselect(GUI_UDREGEO_HNDL);
        geoudrefun = GUI_UDREGEO_ALGO{i};
        if(~isempty(GUI_UDREGEO_INIT{i}))
          feval(GUI_UDREGEO_INIT{i});
        end
        % check udre constant
        if strcmp(geoudrefun,'af_geoconst')
            GEOUDREI_CONST = get(GUI_GEOCONST_HNDL,'Value');
        end
        % see if geo cnmp function needs to be initialized
        if strcmp(geoudrefun,'af_geoadd2')
            init_geo_cnmp;
        end


    % GIVE Menu

        i = gui_readselect(GUI_GIVE_HNDL);
        givefun = GUI_GIVE_ALGO{i};
        if(~isempty(GUI_GIVE_INIT{i}))
          feval(GUI_GIVE_INIT{i});
        end
        % check give constant
        if strcmp(givefun,'af_giveconst')
            GIVEI_CONST = get(GUI_GIVECONST_HNDL,'Value');
        end
        % check dual frequency
        if strcmp(GUI_GIVE_MENU{i},'Dual Freq')
            dual_freq = 1;
        else
            dual_freq = 0;            
        end
        
    % IGP Mask Menu

        i = gui_readselect(GUI_IGPMASK_HNDL);
        igpfile = GUI_IGPMASK_DAT{i};
 
    % CNMP Menu

        i = gui_readselect(GUI_WRSCNMP_HNDL);
        if isempty(i)
            wrsgpscnmpfun = [];
        else
            wrsgpscnmpfun = GUI_WRSCNMP_ALGO{i};
            if(~isempty(GUI_WRSCNMP_INIT{i}))
              feval(GUI_WRSCNMP_INIT{i});
            end
        end
        i = gui_readselect(GUI_USRCNMP_HNDL);
        if isempty(i)
            wrsgpscnmpfun = [];
        else
            usrcnmpfun = GUI_USRCNMP_ALGO{i};
            if(~isempty(GUI_USRCNMP_INIT{i}))
              feval(GUI_USRCNMP_INIT{i});
            end
        end
        wrsgeocnmpfun=[];

    % WRS Menu

        i = gui_readselect(GUI_WRS_HNDL);
        wrsfile = GUI_WRS_DAT{i};
        
    % USER Menu

        i = gui_readselect(GUI_USR_HNDL);
        usrpolyfile = GUI_USR_DAT{i};
        
        % check user latitude and longitude steps
        usrlatstep = gui_readnum(GUI_LATSTEP_HNDL,0,360,...
                'Please input valid Lat Step and run again.');
        if isnan(usrlatstep)
            return;
        end        
        usrlonstep = gui_readnum(GUI_LONSTEP_HNDL,0,180,...
                'Please input valid Lon Step and run again.');
        if isnan(usrlonstep)
            return;
        end        
        usrlatstep = ceil(usrlatstep*2)/2;  % resolution up to 0.5 degrees
        usrlonstep = ceil(usrlonstep*2)/2;

    % SV Menu
        GUI_GPS_SV = get(GUI_GPS_HNDL,'Value'); 
        GUI_GALILEO_SV = get(GUI_GALILEO_HNDL,'Value');
        
        i = gui_readselect(GUI_SV_HNDL);        
        % check week number for almanac
        if i==2 % using yuma
            svfile = ['almyuma'  get(GUI_WEEKNUM_HNDL,'String')  '.txt']; 
        else
            if GUI_GPS_SV
                if GUI_GALILEO_SV
                  svfile = {'almmops.txt', 'almgalileo.txt'};
                else
                  svfile = 'almmops.txt';
                end
            else     
                svfile =  'almgalileo.txt';
            end
        end
        % check if file(s) exist
        i=1;
        while i<=size(svfile,2)
          if iscell(svfile)
            fid=fopen(svfile{i});
          else
            fid=fopen(svfile);
            i = size(svfile,2);
          end
          if fid==-1
              fprintf('Almanac file not found.  Please try again.\n');
              return;
          else
              fclose(fid);
          end 
          i=i+1;
        end
        %check validity of time steps
        %TStart = gui_readnum(GUI_TSTART_HNDL,0,86400,...
        TStart = gui_readnum(GUI_TSTART_HNDL,-604800,604800,...
                'Please input valid TStart and run again.');
        %TEnd = gui_readnum(GUI_TEND_HNDL,TStart,86400,...
        TEnd = gui_readnum(GUI_TEND_HNDL,TStart,604800,...
                'Please input valid TEnd and run again.');
        %if TEnd>=86400,
        %    TEnd = 86399;
        %end
        TStep = gui_readnum(GUI_TSTEP_HNDL,1,inf,...
            'Please input valid TStep and run again.');
        if isnan(TStart) || isnan(TEnd) || isnan(TStep) 
            return;
        end

    % GEO Position Menu
        ngeo=0;
        geodata = [];
        for i=1:size(GUI_GEOPOS_DAT,1)
          if(get(GUI_GEO_HNDL(i),'Value') == 1)
            ngeo=ngeo+1;
            geodata(ngeo,:)=GUI_GEOPOS_DAT(i,1:13);
          end
        end
    % Mode / Alert limit
        pa_mode = get(GUI_PAMODE_HNDL(1),'Value');
        vhal = [MOPS_VAL, MOPS_HAL];
        vhal(1) = gui_readnum(GUI_VAL_HNDL,0,10000,...
                'Please input valid VAL and run again.');
        vhal(2) = gui_readnum(GUI_HAL_HNDL,0,10000,...
                'Please input valid HAL and run again.');            


    % RUN Simulation

    
        if hndl==GUI_RUN_HNDL
            % do simulation run
            if (RTR_FLAG && ~TRUTH_FLAG)
                fprintf('Can''t use Real Time R-irreg without using Real Data');
                return;
            end;
            svmrun(gpsudrefun, geoudrefun, givefun, usrcnmpfun, wrsgpscnmpfun, ...
                   wrsgeocnmpfun, wrsfile,usrpolyfile, igpfile, svfile, ...
                   geodata, TStart, TEnd, TStep, usrlatstep, usrlonstep, ...
                   outputs, percent, vhal, pa_mode, dual_freq);
        elseif hndl==GUI_PLOT_HNDL
            % plots only
            load 'outputs';
            outputprocess(satdata,usrdata,wrsdata,igpdata,inv_igp_mask,...
                sat_xyz,udrei,givei,vpl,hpl,usrlatgrid,usrlongrid,outputs,...
				percent,vhal,pa_mode,udre_hist,give_hist,udrei_hist,givei_hist);
        elseif hndl==GUI_WRSPB_HNDL(1)
            %list WRSs
            fid=fopen(wrsfile,'r');
            buffr=fgetl(fid);
            while(buffr>0)
                disp(buffr);
                buffr=fgetl(fid);
            end
        elseif hndl==GUI_WRSPB_HNDL(2)
            %plot WRSs
            wrsplot(wrsfile, igpfile, usrpolyfile);           
        end

    case GUI_SETTINGS_HNDL
        if (SETTINGS_FIRST == 0)
            settingsgui;
            init_gui_settings;
            SETTINGS_FIRST = 1;
        else
            set(SETTINGS_WIND_HNDL, 'Visible', 'On');
        end;

    otherwise
        disp('Function not yet operational.');
    end
end    








