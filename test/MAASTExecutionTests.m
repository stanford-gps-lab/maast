classdef MAASTExecutionTests < matlab.unittest.TestCase %#ok<*GVMIS,*UNRCH>
    % MAASTExecutionTests A collection of tests authored by Todd Walter for MAAST.

    methods (Test)

        function test_dual_frequency_authentication_missing_messages(testCase)
            clearvars -global;
            close all;

            init_const;      % global physical and gps constants
            init_col_labels_pub; % column indices
            init_mops;       % MOPS constants

            global COL_USR_INBND

            global UDREI_CONST GEOUDREI_CONST MT27
            global TRUTH_FLAG
            global BRAZPARAMS RTR_FLAG IPP_SPREAD_FLAG
            global GUI_OUT_AVAIL GUI_OUT_UDREMAP GUI_OUT_GIVEMAP GUI_OUT_COVAVAIL ...
                    GUI_OUT_UDREHIST GUI_OUT_GIVEHIST GUI_OUT_VHPL

            global SBAS_MESSAGE_FILE SBAS_PRIMARY_SOURCE

            global AUTHENTICATION_ENABLED
            global senderTESLA_constructor
            global receiverTESLA_constructor
            global TEST_TESLA_AUTH

            AUTHENTICATION_ENABLED = true;
            senderTESLA_constructor = @SenderTESLA_AMAC36;
            receiverTESLA_constructor = @ReceiverTESLA_AMAC36;
            TEST_TESLA_AUTH = true;

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

            gpsudrefun = 'af_udreconst';
            UDREI_CONST = 6;

            MT27 = []; % MT 27 is not in use - Otherwise specify both MT27{:,1} & {:,2}

            %% UDRE GEO Menu

            geoudrefun = 'af_geoconst';
            GEOUDREI_CONST = 11;

            %% GIVE Menu

            givefun = '';

            dual_freq = 1;

            %% IGP Mask Menu

            % select Release 51 CY18 mask
            igpfile = 'igpjoint_R51CY18.txt';

            %% WRS GPS CNMP Menu

            wrsgpscnmpfun = '';

            %% WRS GEO CNMP Menu

            wrsgeocnmpfun = [];

            %% USER CNMP Menu

            % select SBAS MOPS model
            usrcnmpfun = 'af_cnmp_mops';
            init_cnmp_mops;

            %% WRS Menu

            wrsfile = 'wrs_foc.txt';

            %% USER Menu

            % select North America as the user area
            usrpolyfile = 'usrn_america.txt';

            % select user latitude and longitude grid steps in degrees
            usrlatstep = 2;
            usrlonstep = 2;

            %% SV Menu

            % activate GPS constellation
            svfile = 'alm01jan2020.txt';

            % check if file(s) exist
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

            TStart = 0 + 3 * 86400 + 2086 * 604800; % absolute time (since 1980) (tow + week number * 604800)

            % End time for simulation
            TEnd = TStart + 300.0;

            % Size of time step
            TStep = 1;

            %% GEO Position Menu

            geodata = [131  -117.0  213  401 37 455  51  -28 42  30  3  1   5    1];

            %% Run using a geo broadcast file instead of simulating performance
            % make sure that the start time is synchronized to the data file
            % including week number
            SBAS_MESSAGE_FILE = 'maast_messages_2019_365';
            SBAS_PRIMARY_SOURCE = 131;            %% Mode / Alert limit

            % choose PA mode vs NPA
            pa_mode = 1;

            % choose VAL and HAL
            vhal = [35, 40];

            %% OUTPUT Menu

            % initialize histograms
            init_hist;

            % turn on or off output options
            outputs = [0 0 0 0 0 0 0];

            % Assign percentage
            percent = 0.96; % 1 = 100%

            %% RUN Simulation

            svmrunpub(gpsudrefun, geoudrefun, givefun, usrcnmpfun, ...
                      wrsgpscnmpfun, wrsgeocnmpfun, wrsfile, usrpolyfile, ...
                      igpfile, svfile, geodata, TStart, TEnd, TStep, usrlatstep, ...
                      usrlonstep, outputs, percent, vhal, pa_mode, dual_freq);

            %% Evaluate Output

            load outputs usrlatgrid  usrlongrid vpl hpl usrdata;
            [~, coverage] = avail_contour(usrlatgrid, usrlongrid, vpl, hpl, usrdata(:, COL_USR_INBND), ...
                                          percent, vhal, pa_mode);

            testCase.assertGreaterThan(coverage, 95);

        end

    end
end
