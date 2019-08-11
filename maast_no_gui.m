function maast_no_gui()
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
% runs maast without the GUI
% all settings are edited in this file
% allows for repeatable and recorded runs

%clear all;
close all;


init_const;      % global physical and gps constants
init_col_labels; % column indices 
init_mops;       % MOPS constants

global MOPS_UDRE MOPS_SIG_UDRE MOPS_SIG2_UDRE 
global MOPS_NOT_MONITORED MOPS_DO_NOT_USE;
global UDRE_BIAS_MAX;

global UDREI_CONST GEOUDREI_CONST GIVEI_CONST;
global TRUTH_FLAG
global BRAZPARAMS RTR_FLAG IPP_SPREAD_FLAG
global GUI_OUT_AVAIL GUI_OUT_UDREMAP GUI_OUT_GIVEMAP GUI_OUT_COVAVAIL...
        GUI_OUT_UDREHIST GUI_OUT_GIVEHIST GUI_OUT_VHPL
% Outputs
GUI_OUT_AVAIL = 1;
GUI_OUT_VHPL = 2;
GUI_OUT_UDREMAP = 3;
GUI_OUT_GIVEMAP = 4;
GUI_OUT_UDREHIST = 5;
GUI_OUT_GIVEHIST = 6;
GUI_OUT_COVAVAIL = 7;

%Settings Menu
    %process truth data
    TRUTH_FLAG = 0;
    BRAZPARAMS = 0;
    RTR_FLAG = 0;
    IPP_SPREAD_FLAG = 0;

% UDRE GPS Menu

    %choose ADD version
%    gpsudrefun = 'af_udreadd';
%    init_udre_osp;
    
%     %choose Release 8/9 ADD version %%%%% Not Public
%     gpsudrefun = 'af_udreadd2';
%     init_udre2_osp;    
    
    %choose constant version
    % UDREI values to choose are from the MOPS
    %  0    1    2    3    4   5   6    7   8    9   10  11   12   13   14  15
    %  1    2    3    4    5   6   7    8   9    10  11  12   13   14   15  16 
    %0.75 1.00 1.25 1.75 2.25 3.0 3.75 4.5 5.25 6.0 7.5 15.0 50.0 150.0 NM DNU
    % Note MOPS is 0 to N-1, but matlab is 1 to N
  
   gpsudrefun = 'af_udreconst';
   UDREI_CONST = 11; 



% UDRE GEO Menu

    %choose ADD version
%    geoudrefun = 'af_geoadd';
%    init_geo_osp;

%     %choose Release 8/9 ADD version %%%%% Not Public
%     geoudrefun = 'af_geoadd2';
%     init_geo2_osp;
    
    %choose constant version
    % UDREI values to choose are from the MOPS
    %  0    1    2    3    4   5   6    7   8    9   10  11   12   13   14  15
    %  1    2    3    4    5   6   7    8   9    10  11  12   13   14   15  16 
    %0.75 1.00 1.25 1.75 2.25 3.0 3.75 4.5 5.25 6.0 7.5 15.0 50.0 150.0 NM DNU
    geoudrefun = 'af_geoconst';
    GEOUDREI_CONST = 13;


% GIVE Menu

    %choose ADD version
%    givefun = 'af_giveadd';
%    init_give_osp;
    
    %choose Release 6/7 version
%    givefun = 'af_giveadd1';
%    init_giveadd1_osp;    
    
%     %choose Release 8/9 version %%%%% Not Public
%     givefun = 'af_giveadd2';
%     init_giveadd2_osp;      
    
    %choose constant version
    % GIVEI values to choose are from the MOPS
    % 0   1   2   3   4   5   6   7   8   9   10  11  12  13   14  15
    % 1   2   3   4   5   6   7   8   9  10   11  12  13  14   15  16 
    %0.3 0.6 0.9 1.2 1.5 1.8 2.1 2.4 2.7 3.0 3.6 4.5 6.0 15.0 45.0 NM
    givefun = 'af_giveconst';
    GIVEI_CONST = 13;

    %dual frequency flag should be set to zero if one of the above GIVE
    %functions are selected.  If it is set to 1 the above should all be
    %commented out.
%    givefun = '';    
%    dual_freq = 1;
    dual_freq = 0;            

        
% IGP Mask Menu

    %select IOC IGP mask    
%    igpfile = 'igpjoint.dat';
    
    %select Release 6/7 mask
%    igpfile = 'igpjoint_R6_7.dat';
    
    %select Release 8/9 mask
    igpfile = 'igpjoint_R8_9.dat';
    
    %select EGNOS mask
%    igpfile = 'igpegnos.dat';
    
    %select MSAS mask
%    igpfile = 'igpmsas.dat';
    
    %select Brazil mask
%    igpfile =  'igpbrazil.dat';
 
% WRS GPS CNMP Menu

%      %select ADD    %%%%% Not Public
%       wrsgpscnmpfun = 'af_cnmpadd';
%       init_cnmp;
      
      %select aggressive model
     wrsgpscnmpfun = 'af_cnmpagg';
 
% WRS GEO CNMP Menu

        wrsgeocnmpfun=[];
        
% USER CNMP Menu

      %select AAD-B model
      usrcnmpfun = 'af_cnmp_mops';      
      init_cnmp_mops;
      
      %select AAD-A model
%      usrcnmpfun = 'af_cnmpaad';
%      init_aada;
      
      %select AAD-B model
%      usrcnmpfun = 'af_cnmpaad';      
%      init_aadb;

% WRS Menu

      %select IOC WRS network
%      wrsfile = 'wrs25.dat';
      
      %select Release 6/7 WRS network      
%      wrsfile = 'wrs_R6_7.dat';
      
      %select Release 8/9 WRS network      
      wrsfile = 'wrs_foc.dat';
      
      %select EGNOS RIMS network      
%      wrsfile = 'egnos_rims.dat';
      
      %select MSAS RS network      
%      wrsfile = 'rs_msas.dat';
      
      %select Brazil WRS network      
%      wrsfile = 'brazil_wrs.dat';
      
      %select a worldwide 16 WRS network      
%      wrsfile = 'wrs_world16.dat';
      
      %select a worldwide 30 WRS network      
%      wrsfile = 'wrs_world30.dat';
        
% USER Menu

      %select CONUS as the user area
%      usrpolyfile = 'usrconus.dat';
      
      %select Alaska as the user area
%      usrpolyfile = 'usralaska.dat';
      
      %select Canada as the user area
%      usrpolyfile = 'usrcanada.dat';
      
      %select Mexico as the user area
%      usrpolyfile = 'usrmexico.dat';
      
      %select North America as the user area
      usrpolyfile = 'usrn_america.dat';
      
      %select Europe as the user area
%      usrpolyfile = 'usreurope.dat';
      
      %select Japan as the user area
%      usrpolyfile = 'usrmsas.dat';
      
      %select Brazil as the user area
%      usrpolyfile = 'usrbrazil.dat';
      
      %select the world as the user area
%      usrpolyfile = 'usrworld.dat';
        
      % select user latitude and longitude grid steps in degrees
      usrlatstep = 2;
      usrlonstep = 2;

% SV Menu

      %activate GPS constellation
      svfile = 'almmops.dat'; 
%      svfile = 'current.alm'; 
      %Use Yuma file instead
%      svfile = ['almyuma#.dat'];
%      svfile = ['SV24Week7031.alm'];

      %activate Galileo constellation
%      svfile =  'almgalileo.dat';
      
      %activate both
%      svfile = {'almmops.dat', 'almgalileo.dat'};
%      svfile = {'almyuma#.dat', 'almgalileo.dat'};

        % check if file(s) exist
        i=1;
        while i<=size(svfile,2)
          if iscell(svfile)
            fid=fopen(svfile{i});
          else
            fid=fopen(svfile);
            i = size(svfile,2);
          end
          if fid==-1,
              fprintf('Almanac file not found.  Please try again.\n');
              return;
          else
              fclose(fid);
          end 
          i=i+1;
        end
        
      %Start time for simulation
      TStart = 0;
      
      %End time for simulation
      TEnd = 86400;
      
      % Size of time step
      TStep = 300;

% GEO Position Menu

      %geodata = [];
% PRN   Lat.  MT28 parameters                 scale_exp Default Name
%120   -15.5    1    0  0   0   1    0  0   1  0  0   5    0   %AOR-E
%122   -54.0  144 -133 11  43 146 -100 69 268 27 16   1    0   %AOR-W
%124    21.5    1    0  0   0   1    0  0   1  0  0   5    0   %ARTEMIS
%131    64.0    1    0  0   0   1    0  0   1  0  0   5    0   %IOR
%134   178.0  177  -24 21 181  84   -2 -7 152 15  8   2    0   %POR
%137  -107.0  157  484 48 510  63  -11 58  38  4  1   5    1   %CRE
%138  -133.0  317  312 41 446  41  -59 22  28  3  1   5    1   %CRW
%135   135.0    1    0  0   0   1    0  0   1  0  0   5    0   %MTSAT-1
%136   140.0    1    0  0   0   1    0  0   1  0  0   5    0   %MTSAT-2
  
      geodata = [[137  -107.0  157  484 48 510  63  -11 58  38  4  1   5    1];...
                 [138  -133.0  317  312 41 446  41  -59 22  28  3  1   5    1];];

% Mode / Alert limit

      %choose PA mode vs NPA  
      pa_mode = 1;
      
      %choose VAL and HAL
      vhal = [35, 40];
%      vhal = [Inf, 1668];
      
% OUTPUT Menu

      %initialize histograms
      init_hist;
        
      % turn on or off output options
      outputs = [0 1 0 0 0 0 0];
      %          1 2 3 4 5 6 7
      %1: Availability  2: V/HPL  3: UDRE map  4: GIVE map  
      %4: UDRE histogram  5: GIVE histogram  6: Coverage vs Availability
        
      % Assign percentage
      percent = 0.99; % 1 = 100%

        
% RUN Simulation

      svmrun(gpsudrefun, geoudrefun, givefun, usrcnmpfun, ...
             wrsgpscnmpfun, wrsgeocnmpfun, wrsfile,usrpolyfile, ...
             igpfile, svfile, geodata, TStart, TEnd, TStep, usrlatstep, ...
             usrlonstep, outputs, percent, vhal, pa_mode, dual_freq);









