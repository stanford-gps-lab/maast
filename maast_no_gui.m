function maast_no_gui()
%*************************************************************************
%*     Copyright c 2020 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% runs maast without the GUI
% all settings are edited in this file
% allows for repeatable and recorded runs

clearvars -global;
close all;


init_const;      % global physical and gps constants
init_col_labels_pub; % column indices 
init_mops;       % MOPS constants

global MOPS_UDRE MOPS_SIG_UDRE MOPS_SIG2_UDRE MT27
global MOPS_NOT_MONITORED MOPS_DO_NOT_USE;
global UDRE_BIAS_MAX;

global UDREI_CONST GEOUDREI_CONST GIVEI_CONST;
global TRUTH_FLAG
global BRAZPARAMS RTR_FLAG IPP_SPREAD_FLAG
global GUI_OUT_AVAIL GUI_OUT_UDREMAP GUI_OUT_GIVEMAP GUI_OUT_COVAVAIL...
        GUI_OUT_UDREHIST GUI_OUT_GIVEHIST GUI_OUT_VHPL

global SBAS_MESSAGE_FILE SBAS_PRIMARY_SOURCE
    
%% Outputs
GUI_OUT_AVAIL = 1;
GUI_OUT_VHPL = 2;
GUI_OUT_UDREMAP = 3;
GUI_OUT_GIVEMAP = 4;
GUI_OUT_UDREHIST = 5;
GUI_OUT_GIVEHIST = 6;
GUI_OUT_COVAVAIL = 7;

%% Settings Menu
    %process truth data
    TRUTH_FLAG = 0;
    BRAZPARAMS = 0;
    RTR_FLAG = 0;
    IPP_SPREAD_FLAG = 0;

%% UDRE GPS Menu

    
    %choose constant version
    % UDREI values to choose are from the MOPS
    %  0    1    2    3    4   5   6    7   8    9   10  11   12   13   14  15
    %  1    2    3    4    5   6   7    8   9    10  11  12   13   14   15  16 
    %0.75 1.00 1.25 1.75 2.25 3.0 3.75 4.5 5.25 6.0 7.5 15.0 50.0 150.0 NM DNU
    % Note MOPS is 0 to N-1, but matlab is 1 to N
  
   gpsudrefun = 'af_udreconst';
   UDREI_CONST = 6; 

    MT27 = []; %MT 27 is not in use - Otherwise specify both MT27{:,1} & {:,2}
%     MT27{1,1} = [0  1  1  0   0  15]; %[IODS, # of messages, mesg#, priority, inside_dudrei, outside_dudrei]
%     MT27{1,2} = [[20 -40]; [70 -40]; [70 40]; [20 40]; [20 -40];]; %EGNOS MT27 rectangle prior to March 26, 2019
%     MT27{1,2} = [[20 -40]; [72 -40]; [72 40]; [20 40]; [20 -40];]; %EGNOS MT27 rectangle after March 26, 2019

%% UDRE GEO Menu

    
    %choose constant version
    % UDREI values to choose are from the MOPS
    %  0    1    2    3    4   5   6    7   8    9   10  11   12   13   14  15
    %  1    2    3    4    5   6   7    8   9    10  11  12   13   14   15  16 
    %0.75 1.00 1.25 1.75 2.25 3.0 3.75 4.5 5.25 6.0 7.5 15.0 50.0 150.0 NM DNU
    geoudrefun = 'af_geoconst';
    GEOUDREI_CONST = 11;


%% GIVE Menu

    
    %choose constant version
    % GIVEI values to choose are from the MOPS
    % 0   1   2   3   4   5   6   7   8   9   10  11  12  13   14  15
    % 1   2   3   4   5   6   7   8   9  10   11  12  13  14   15  16 
    %0.3 0.6 0.9 1.2 1.5 1.8 2.1 2.4 2.7 3.0 3.6 4.5 6.0 15.0 45.0 NM
    givefun = 'af_giveconst';
    GIVEI_CONST = 10;

%    dual_freq = 1;
   dual_freq = 0;            

        
%% IGP Mask Menu

    %select IOC IGP mask    
%    igpfile = 'igpjoint.txt';
    
    %select Release 6/7 mask
%    igpfile = 'igpjoint_R6_7.txt';
    
    %select Release 8/9 mask
%     igpfile = 'igpjoint_R8_9.txt';
    
    %select WFO Release 3A1 mask
%     igpfile = 'igpjoint_R3A1.txt';

    %select Release 51 CY18 mask
    igpfile = 'igpjoint_R51CY18.txt';
    
    %select EGNOS mask
%    igpfile = 'igpegnos.txt';
    
    %select MSAS mask
%    igpfile = 'igpmsas.txt';
    
    %select Brazil mask
%    igpfile =  'igpbrazil.txt';
 
%% WRS GPS CNMP Menu

      %select aggressive model
     wrsgpscnmpfun = 'af_cnmpagg';
 
%% WRS GEO CNMP Menu

        wrsgeocnmpfun='af_cnmpagg';

        
%% USER CNMP Menu

      %select SBAS MOPS model
      usrcnmpfun = 'af_cnmp_mops';      
      init_cnmp_mops;
      
      %select AAD-A model
%      usrcnmpfun = 'af_cnmpaad';
%      init_aada;
      
      %select AAD-B model
%      usrcnmpfun = 'af_cnmpaad';      
%      init_aadb;

%% WRS Menu

      %select IOC WRS network
%      wrsfile = 'wrs25.txt';
      
      %select Release 6/7 WRS network      
%      wrsfile = 'wrs_R6_7.txt';
      
      %select Release 8/9 WRS network      
      wrsfile = 'wrs_foc.txt';
      
      %select EGNOS RIMS network      
%      wrsfile = 'egnos_rims.txt';
      
      %select MSAS RS network      
%      wrsfile = 'rs_msas.txt';
      
      %select Brazil WRS network      
%      wrsfile = 'brazil_wrs.txt';
      
      %select a worldwide 16 WRS network      
%      wrsfile = 'wrs_world16.txt';
      
      %select a worldwide 30 WRS network      
%      wrsfile = 'wrs_world30.txt';
        
%% USER Menu

      %select CONUS as the user area
%      usrpolyfile = 'usrconus.txt';
      
      %select Alaska as the user area
%      usrpolyfile = 'usralaska.txt';
      
      %select Canada as the user area
%      usrpolyfile = 'usrcanada.txt';
      
      %select Mexico as the user area
%      usrpolyfile = 'usrmexico.txt';
      
      %select North America as the user area
      usrpolyfile = 'usrn_america.txt';
      
      %select Europe as the user area
%      usrpolyfile = 'usreurope.txt';
      
      %select Japan as the user area
%      usrpolyfile = 'usrmsas.txt';
      
      %select Brazil as the user area
%      usrpolyfile = 'usrbrazil.txt';
      
      %select the world as the user area
%      usrpolyfile = 'usrworld.txt';
        
      % select user latitude and longitude grid steps in degrees
      usrlatstep = 2;
      usrlonstep = 2;

%% SV Menu

      %activate GPS constellation
      svfile = 'almmops.txt'; 
      %Use Yuma file instead
%      svfile = ['almyuma#.txt'];
%      svfile = ['SV24Week7031.alm'];

      %activate Galileo constellation
%      svfile =  'almgalileo.txt';
      
      %activate both
%      svfile = {'almmops.txt', 'almgalileo.txt'};
%      svfile = {'almyuma#.txt', 'almgalileo.txt'};

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
        
%% Start time for simulation

      TStart = 0;                         % time of day
%       TStart = 0 + 4*86400;               % time of week (day of week * 86400
%       TStart = 0 + 3*86400 + 2086*604800; % absolute time (since 1980) (tow + week number * 604800)
      
      %End time for simulation
      TEnd = TStart + 86400;
%       TEnd = 86164.1;
      
      % Size of time step
      TStep = 288;

%% GEO Position Menu

% geodata = []; % no GEOs
      
% Table taken from https://www.gps.gov/technical/prn-codes/L1-CA-PRN-code-assignments-2019-Oct.pdf      
% PRN   Lat.  MT28 parameters                 scale_exp Default Name
%121    -5.0    1    0  0   0   1    0  0   1  0  0   5    0   %EGNOS (Eutelsat 5WB)
%122   143.5    1    0  0   0   1    0  0   1  0  0   5    0   %AUS-NZ (INMARSAT 4F1)
%123    31.5    1    0  0   0   1    0  0   1  0  0   5    0   %EGNOS (ASTRA 5B)
%125   -16.0    1    0  0   0   1    0  0   1  0  0   5    0   %SDCM (Luch-5A)
%126    63.9    1    0  0   0   1    0  0   1  0  0   5    0   %EGNOS (INMARSAT 4F2)
%127    55.0    1    0  0   0   1    0  0   1  0  0   5    0   %GAGAN (GSAT-8)
%128    83.0    1    0  0   0   1    0  0   1  0  0   5    0   %GAGAN (GSAT-10)
%129   145.0    1    0  0   0   1    0  0   1  0  0   5    0   %MSAS (MTSAT-2)iv
%130    80.0    1    0  0   0   1    0  0   1  0  0   5    0   %BDSBAS (G6)
%131  -117.0    1    0  0   0   1    0  0   1  0  0   5    0   %WAAS (Eutelsat 117 West B)
%132    93.5    1    0  0   0   1    0  0   1  0  0   5    0   %GAGAN (GSAT-15)
%133  -129.0    1    0  0   0   1    0  0   1  0  0   5    0   %WAAS (SES-15)
%134    91.5    1    0  0   0   1    0  0   1  0  0   5    0   %KASS (MEASAT-3D)
%135  -125.0    1    0  0   0   1    0  0   1  0  0   5    0   %WAAS (Intelsat Galaxy 30)
%136     5.0    1    0  0   0   1    0  0   1  0  0   5    0   %EGNOS (SES-5)
%137   145.0    1    0  0   0   1    0  0   1  0  0   5    0   %MSAS (MTSAT-2)iv
%138  -107.3    1    0  0   0   1    0  0   1  0  0   5    0   %WAAS (ANIK F1R)
%140    95.0    1    0  0   0   1    0  0   1  0  0   5    0   %SDCM (Luch-5B)
%141   167.0    1    0  0   0   1    0  0   1  0  0   5    0   %SDCM (Luch-4)
%143   110.5    1    0  0   0   1    0  0   1  0  0   5    0   %BDSBAS (G3)
%144   140.0    1    0  0   0   1    0  0   1  0  0   5    0   %BDSBAS (G1)
%147    42.5    1    0  0   0   1    0  0   1  0  0   5    0   %NSAS (NIGCOMSAT-1R)
%148   -24.8    1    0  0   0   1    0  0   1  0  0   5    0   %ASAL (ALCOMSAT-1)

% WAAS GEOs
%122   -54.0  144 -133 11  43 146 -100 69 268 27 16   1    0   %AOR-W      Active before 2003 through July 2007
%134   178.0  177  -24 21 181  84   -2 -7 152 15  8   2    0   %POR        Active before 2003 through July 2007
%135  -133.0  317  312 41 446  41  -59 22  28  3  1   5    1   %CRW        Active November 2006  through July 25, 2019
%138  -107.3  157  484 48 510  63  -11 58  38  4  1   5    1   %CRE        Active July 2007 through May 2022
%133   -98.0   57  458 44 461  35  -15 34   2  0  4   3    0   %AMR        Active Nov. 2010 through Nov. 2017 
%131  -117.0  213  401 37 455  51  -28 42  30  3  1   5    1   %SM9 - GEO5 Active March 2018
%133  -129.0  302  356 30 466  42  -42 27  30  3  1   5    1   %S15 - GEO6 Active July 15, 2019
%135  -125.0  167  223 27 279  46  -32 33  38  4  1   5    1   %G30 - GEO7 Active April 26, 2022

      geodata = [[131  -117.0  213  401 37 455  51  -28 42  30  3  1   5    1];...
                 [133  -129.0  302  356 30 466  42  -42 27  30  3  1   5    1];...
                 [135  -125.0  167  223 27 279  46  -32 33  38  4  1   5    1];];
             
             
             
%% Run using a geo broadcast file instead of simulating performance           
      % make sure that the start time is synchronized to the data file
      % including week number
      % Comment out next two lines to run in simulation mode
%       SBAS_MESSAGE_FILE = 'sbas_messages_2020_001';
%       SBAS_PRIMARY_SOURCE = 131;
%            
%       %%%  These need to be changed to work with above message file
%       svfile = 'almyuma_01jan2020.txt'; 
%       TStart = 0 + 3*86400 + 2086*604800; % absolute time (since 1980) (tow + week number * 604800)
%       TEnd = TStart + 86400;
%       TStep = 1;

%% Mode / Alert limit

      %choose PA mode vs NPA  
      pa_mode = 1;
      
      %choose VAL and HAL
      vhal = [35, 40];
%      vhal = [Inf, 1668];
      
%% OUTPUT Menu

      %initialize histograms
      init_hist;
        
      % turn on or off output options
      outputs = [0 1 0 0 0 0 0];
      %          1 2 3 4 5 6 7
      %1: Availability  2: V/HPL  3: UDRE map  4: GIVE map  
      %4: UDRE histogram  5: GIVE histogram  6: Coverage vs Availability
        
      % Assign percentage
      percent = 0.99; % 1 = 100%

        
%% RUN Simulation

      svmrunpub(gpsudrefun, geoudrefun, givefun, usrcnmpfun, ...
             wrsgpscnmpfun, wrsgeocnmpfun, wrsfile,usrpolyfile, ...
             igpfile, svfile, geodata, TStart, TEnd, TStep, usrlatstep, ...
             usrlonstep, outputs, percent, vhal, pa_mode, dual_freq);









