
%% 8 Day Authentication Demo
% @author Jason Anderson
% Generates 8-days of SBAS messages authenticated via two TESLA Hash Path.
% The first path is 7-days long.
% The TESLA hash path and HMACS are distributed with MT50s. 
% Over the air re-keying is done via MT51s.

clearvars -global;
close all;

init_const;      % global physical and gps constants
init_col_labels; % column indices
init_mops;       % MOPS constants

global MT27

global GEOUDREI_CONST;
global TRUTH_FLAG
global BRAZPARAMS RTR_FLAG IPP_SPREAD_FLAG
global GUI_OUT_AVAIL GUI_OUT_UDREMAP GUI_OUT_GIVEMAP GUI_OUT_COVAVAIL ...
    GUI_OUT_UDREHIST GUI_OUT_GIVEHIST GUI_OUT_VHPL

global AUTHENTICATION_ENABLED

%% Outputs
GUI_OUT_AVAIL = 1;
GUI_OUT_VHPL = 2;
GUI_OUT_UDREMAP = 3;
GUI_OUT_GIVEMAP = 4;
GUI_OUT_UDREHIST = 5;
GUI_OUT_GIVEHIST = 6;
GUI_OUT_COVAVAIL = 7;

%% Settings Menu
% process truth data
TRUTH_FLAG = 0;
BRAZPARAMS = 0;
RTR_FLAG = 0;
IPP_SPREAD_FLAG = 0;

%% UDRE GPS Menu

% choose Release 8/9 ADD version
gpsudrefun = 'af_udreadd2';

MT27 = []; % MT 27 is not in use - Otherwise specify both MT27{:,1} & {:,2}

geoudrefun = 'af_geoconst';
GEOUDREI_CONST = 16;

givefun = '';

dual_freq = 1;

igpfile = 'igpjoint_R51CY18.txt';

wrsgpscnmpfun = 'af_cnmpadd';

wrsgeocnmpfun = [];

%% USER CNMP Menu

% select SBAS MOPS model
usrcnmpfun = 'af_cnmp_mops';
init_cnmp_mops;

wrsfile = 'wrs_foc.txt';

%% USER Menu

% select North America as the user area
usrpolyfile = 'usrn_america.txt';

usrlatstep = 5;
usrlonstep = 5;

%% SV Menu

% activate GPS constellation
svfile = 'almmops.txt';

i = 1;
while i <= size(svfile, 2)
    if iscell(svfile)
        fid = fopen(svfile{i});
    else
        fid = fopen(svfile);
        i = size(svfile, 2);
    end
    if fid == -1
        fprintf('Almanac file not found.  Please try again.\n');
        return
    else
        fclose(fid);
    end
    i = i + 1;
end

%% Start time for simulation

TStart = -300.0 + 3 * 86400 + 2086 * 604800; % absolute time (since 1980) (tow + week number * 604800)

% End time for simulation
TEnd = TStart + 8 * 86400;

% Size of time step
TStep = 1;

%% GEO Position Menu

geodata = [131  -117.0  213  401 37 455  51  -28 42  30  3  1   5    1];

%% Mode / Alert limit

% choose PA mode vs NPA
pa_mode = 1;

% choose VAL and HAL
vhal = [35, 40];

%% OUTPUT Menu

% initialize histograms
init_hist;

% turn on or off output options
outputs = [0 1 0 0 0 0 0];

% Assign percentage
percent = 0.99; % 1 = 100%

%% Run using a geo broadcast file instead of simulating performance           

global SBAS_MESSAGE_FILE
global SBAS_PRIMARY_SOURCE 

SBAS_MESSAGE_FILE = 'maast_messages_2019_365';
SBAS_PRIMARY_SOURCE = 131;

encode_msg = false; % instead encode MAAST messages into 250 bits

%% Authentication Objects

AUTHENTICATION_ENABLED = true;

% receiver side
global mt50Receiver;
mt50Receiver = ReceiverTESLA();
global keyStateMachine;
keyStateMachine = ReceiverKeyStateMachine();

%% RUN Simulation

tic;
svmrun(gpsudrefun, geoudrefun, givefun, usrcnmpfun, ...
       wrsgpscnmpfun, wrsgeocnmpfun, wrsfile, usrpolyfile, ...
       igpfile, svfile, geodata, TStart, TEnd, TStep, usrlatstep, ...
       usrlonstep, outputs, percent, vhal, pa_mode, dual_freq);
fprintf('Simulation time: %fs\n', toc);

diary 'demo_authentication_read_key_info.log';

fprintf('\n Current Level 1 Key at and of sim\n');
disp(AuthenticatorECDSA(DERMethods.PK2DER(keyStateMachine.get_current_key(1, TEnd).key,"ECDSA256")).public_key);

fprintf('\nCurrent Level 2 Key at and of sim\n');
disp(AuthenticatorECDSA(DERMethods.PK2DER(keyStateMachine.get_current_key(2, TEnd).key,"ECDSA256")).public_key);

fprintf('\nCurrent Level 3 Key at and of sim\n');
fprintf('Hash 0x%s\n', reshape(dec2hex(keyStateMachine.get_current_key(3, TEnd).key)', 1, []));

diary off
