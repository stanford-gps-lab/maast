function svmrun(gpsudrefun, geoudrefun, givefun, usrcnmpfun,...
                wrsgpscnmpfun, wrsgeocnmpfun,...
                wrsfile, usrfile, igpfile, svfile, geodata, tstart, tend, ...
				tstep, usrlatstep, usrlonstep, outputs, percent, vhal, ...
                pa_mode, dual_freq)
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
% SVMRUN    Run the Service Volume Model (SVM) simulation.
%   svmrun(gpsudrefun, geoudrefun, givefun, usrtrpfun, usrcnmpfun,...
%                wrstrpfun, wrsgpscnmpfun, wrsgeocnmpfun,...
%                wrsfile, usrfile, igpfile, svfile, tstart, tend, tstep,...
%                usrlatstep, usrlonstep, outputs, percent);
% Inputs:
%   gpsudrefun    -   function to run for udre calculation for GPS satellites
%   geoudrefun    -   function to run for udre calculation for GEO satellites
%   givefun       -   function to run for give calculation
%   usrcnmpfun    -   function to run for cnmp delay calculation for user
%   wrsgpscnmpfun -   function to run for cnmp delay calculation for wrs   
%   wrsfile       -   file containing wrs position data
%   usrfile       -   file containing user position boundary polygon
%   igpfile       -   file containing IGP mask points
%   svfile        -   Yuma almanac file if TStep not zero
%                     Static satellite position file if TStep is zero
%   geodata       -   matrix with geo information
%   tstart        -   start time of simulation (for almanac option)
%   tend          -   end time of simulation (for almanac option)
%   tstep         -   time step of simulation (for almanac option),
%                     should be 0 for static satellite position option
%   userlatstep   -   latitude spacing of user grid
%   userlonstep   -   longitude spacing of user grid
%   outputs       -   array of ON-OFF flags (1 for ON, 0 for OFF) for 
%                     output options, corresponding to:
%                     1) availability     2) udre map     3) give map
%                     4) udre histogram   5) give histogram 6) V/HPL
%                     7) coverage/availability
%   percent       -   percent value to use for calculating availability, 
%                     give map, and/or V/HPL
%   vhal          -   VAL / HAL to use calculating availability
%   pa_mode       -   Whether to calulate vertical and horizontal or 
%                     horizontal only
%   dual_freq     -   Whether or not to calculate GIVE or have a dual
%                     frequency user

%Modified Todd Walter June 28, 2007 to include VAL, HAL and PA vs. NPA mode
% Clean up 2013 Aug 30 by Todd Walter
%Modified by Todd Walter March 29, 2020 to add the capability to decode and
%    use broadcast 250 bit messages in place of emulating the WMS
global COL_SAT_UDREI COL_SAT_DEGRAD COL_SAT_COV COL_SAT_XYZ COL_SAT_MINMON ...
        COL_U2S_UID  COL_U2S_GENUB COL_SAT_PRN COL_SAT_SCALEF ...
        COL_IGP_GIVEI COL_IGP_BAND COL_IGP_ID COL_IGP_MINMON COL_IGP_BETA...
        COL_IGP_DEGRAD COL_IGP_LL COL_IGP_DELAY COL_IGP_CHI2RATIO
global  COL_USR_XYZ COL_USR_EHAT ...
        COL_USR_NHAT COL_USR_UHAT COL_USR_INBND 
global COL_U2S_SIGFLT COL_U2S_SIG2UIRE COL_U2S_OB2PP
global HIST_UDRE_NBINS HIST_GIVE_NBINS HIST_UDRE_EDGES HIST_GIVE_EDGES
global HIST_UDREI_NBINS HIST_GIVEI_NBINS HIST_UDREI_EDGES HIST_GIVEI_EDGES
global MOPS_SIN_USRMASK MOPS_SIN_WRSMASK MOPS_NOT_MONITORED
global MOPS_UDREI_NM MOPS_GIVEI_NM
global CNMP_TL3 MT27

global SBAS_MESSAGE_FILE SBAS_PRIMARY_SOURCE
global MOPS_MAX_GPSPRN MOPS_MIN_GEOPRN MOPS_MAX_GEOPRN 
global MOPS_MIN_GLOPRN MOPS_MAX_GLOPRN
global MOPS_MT1_PATIMEOUT MOPS_MT18_PATIMEOUT 

global TRUTH_FLAG 

global TRIP_COUNT
TRIP_COUNT = 0;

fprintf('initializing run\n');
alm_param = read_yuma(svfile);

%is time provided in time of week or absolute time (since 1980)?
if tstart > 604800
    alm_param(:,3) = alm_param(:,3) + 604800*alm_param(:,12); % abs time
end

if tstep>0
    tend = tend - 1; % e.g. 86400 becomes 86399
    ntstep = floor((tend-tstart)/tstep)+1;
else
    ntstep = 1;
end

% initialize sat & wrs matrices
% see documentation for format of SATDATA & WRSDATA
satdata=[];
satdata = init_satdata(geodata, alm_param, satdata, 0);
ngps = size(alm_param,1);
ngeo = size(geodata,1);
nsat = ngps + ngeo;
wrsdata = init_wrsdata(wrsfile);
nwrs=size(wrsdata,1);
added_prns = [];
  
%Run using either recorded SBAS 250 bit messages or simulate the SBAS
%processing  to create UDREs/DFREs and GIVEIs
if isempty(SBAS_MESSAGE_FILE)
    % initialize wrs2satdata & igp matrices
    % see documentation for format of WRS2SATDATA & IGPDATA

    wrs2satdata = init_usr2satdata(wrsdata,satdata);
    wrstrpfun = 'af_trpmops';
    
    % find all los rise times for cnmp calculation, 
    % start from tstart-CNMP_TL3 (below this, cnmp is at floor value)
    if isempty(CNMP_TL3)
        CNMP_TL3 = 12000*2;
    end
    wrs2sat_trise = find_trise(tstart-CNMP_TL3,tend,MOPS_SIN_WRSMASK,alm_param,...
                wrsdata(:,COL_USR_XYZ),wrsdata(:,COL_USR_EHAT),...
                wrsdata(:,COL_USR_NHAT),wrsdata(:,COL_USR_UHAT));
    %add blank rows for geos
    nrise=size(wrs2sat_trise,2);
    wrs2sat_trise = reshape(wrs2sat_trise, ngps, nwrs, nrise);
    wrs2sat_trise(ngps+1:ngps+ngeo,:,:)=zeros(ngeo, nwrs, nrise) - 4*86400;
    wrs2sat_trise = reshape(wrs2sat_trise, nsat*nwrs, nrise);
    
    [igpdata, inv_igp_mask] = init_igpdata(igpfile);
    igpdata(:,COL_IGP_DEGRAD) = 0;
    rss_iono = 1;
    satdata(:, COL_SAT_DEGRAD) = 0;
    rss_udre = 1;    
else
    % read in the MOPS messages that correspond to the almanac day
    % file can be generated with get_sbas_broadcast_from_rinex.m
    % make sure that the times correspond and include data from before the 
    % start time so that the msg data can be initialized
    load(SBAS_MESSAGE_FILE, 'sbas', 'sbas_msgs', 'sbas_msg_time');
     
    % Find the corresponding geo message channels
    [idx, gdx] = ismember(geodata(:,1), sbas.prns);
    n_channels = sum(idx);
    if n_channels < 1
        error(['No matching SBAS messages found in ' SBAS_MESSAGE_FILE]);
    elseif n_channels < ngeo
        disp(['Message streams only found  for ' geodata(idx,1)]);
    end    
    % Remove uneeded geo data channels
    sbas_msgs = sbas_msgs(gdx);
    sbas_msg_time = sbas_msg_time(gdx);
    sbas.prns = sbas.prns(gdx);

    % Make sure the primary source is included
    [idx, gprime] = ismember(SBAS_PRIMARY_SOURCE, sbas.prns);
    if sum(idx) < 1
        fprintf('Primary source %d not located, using %d instead\n', ...
                  SBAS_PRIMARY_SOURCE, sbas.prns(1));
        gprime = 1;
    end
    
    % Loop over all geo SBAS message channels (backwards to preallocate)
    for gdx = n_channels:-1:1
        %init decoding data
        svdata(gdx) = init_svdata();
        ionodata(gdx) = init_igp_msg_data();
        mt10(gdx) = init_mt10data();

        %initialize decoded message data with prior ten minutes 
        idx = find(sbas_msg_time{gdx} < tstart & ...
                    sbas_msg_time{gdx} >= (tstart - 600));
        if ~isempty(idx)
            for i = 1:length(idx)
                msg = reshape(dec2bin(sbas_msgs{gdx}(idx(i),:))', 1,256);
                [svdata(gdx), ionodata(gdx), mt10(gdx), ~] = ...
                    L1_decode_messages(sbas_msg_time{gdx}(idx(i)), msg, ...
                    svdata(gdx), ionodata(gdx), mt10(gdx));
            end
        end
        smtidx(gdx) = idx(end) + 1;
        
        % Only need to match satdata and get iono mask from primary source
        if gdx == gprime
            % check PRN mask and initialize  svdata
            if svdata(gdx).mt1_time >= tstart - MOPS_MT1_PATIMEOUT
                kdx = 1:212;
                prns = kdx(svdata(gdx).mt1_mask>0)';
                svdata(gdx).prns(1:length(prns)) = prns;
                svdata(gdx).mt1_ngps = sum(prns <= MOPS_MAX_GPSPRN);
                svdata(gdx).mt1_nglo = sum(prns >= MOPS_MIN_GLOPRN & ...
                                            prns <= MOPS_MAX_GLOPRN);
                svdata(gdx).mt1_ngeo = sum(prns >= MOPS_MIN_GEOPRN & ...
                                            prns <= MOPS_MAX_GEOPRN);
                %check that the mask matches the almanac
                while svdata(gdx).mt1_ngps ~= ngps || svdata(gdx).mt1_ngeo ~= ngeo || ...
                                       ~isequal(prns, satdata(:,COL_SAT_PRN))
                    if svdata(gdx).mt1_ngps > ngps %needs to also handle different number of geos
                        [missing_prns, idx] = setdiff(prns(1:svdata(gdx).mt1_ngps), ...
                                                 satdata(1:ngps,COL_SAT_PRN));
                        while ~isempty(missing_prns)
                            %creates a repeated row that hopefully is always set to NM
                            satdata(idx(1):(end+1),:) = satdata((idx(1)-1):end,:);
                            satdata(idx(1),COL_SAT_PRN) = missing_prns(1);
                            satdata(idx(1),(COL_SAT_PRN+1):end) = NaN;
                            alm_param(idx(1):(end+1),:) = alm_param((idx(1)-1):end,:);
                            alm_param(idx(1),1) = missing_prns(1); 
                            alm_param(idx(1),2:end) = NaN; 
                            ngps = ngps + 1;
                            nsat = nsat + 1;
                            added_prns = [added_prns missing_prns(1)];
                            [missing_prns, idx] = setdiff(prns(1:svdata(gdx).mt1_ngps), ...
                                                 satdata(1:ngps,COL_SAT_PRN));
                        end
                    elseif svdata(gdx).mt1_ngps < ngps
                        % delete uneeded row(s) in satdata and almparam
                        [missing_prns, idx] = setdiff(satdata(1:ngps,COL_SAT_PRN), ...
                                                 prns(1:svdata(gdx).mt1_ngps));
                        satdata(idx,:) = [];
                        alm_param(idx,:) = []; 
                        ngps = ngps - length(idx);
                        nsat = nsat - length(idx);
                    else 
                        %erase previous GEO data and just put in mask PRNs
                        ngeo = svdata(gdx).mt1_ngeo;
                        nsat = ngps + ngeo;
                        satdata((ngps+1):end,:) = [];
                        satdata(ngps + (1:ngeo),:) = NaN(ngeo,size(satdata,2));
                        satdata(ngps + (1:ngeo),COL_SAT_PRN) = ...
                                         prns(ngps + (1:ngeo));
                    end
                end
                satdata(:,COL_SAT_UDREI) = MOPS_UDREI_NM;
            else
                warning('MT1 PRN mask has not been received')    
            end

            %check IGP mask and initalize igpdata
            if sum(ionodata(gdx).mt18_num_bands)
                idx = find(ionodata(gdx).mt18_num_bands > 0);
                IODI = ionodata(gdx).mt18_iodi(idx (1));
                num_bands = ionodata(gdx).mt18_num_bands(idx (1));
                % make sure all MT18s have the same IODI, the same number of
                % messages and have not timed out
                if all(ionodata(gdx).mt18_iodi(idx) == IODI) && ...
                     all(ionodata(gdx).mt18_num_bands(idx) == num_bands) && ...
                     length(idx) == num_bands && all(ionodata(gdx).mt18_time(idx) >= ...
                     tstart - MOPS_MT18_PATIMEOUT)
                   bandnum = [];
                    for i = 1:length(idx)
                        kdx = 1:201; 
                        igps = kdx(ionodata(gdx).mt18_mask(idx(i),:)>0)';
                        bandnum = [bandnum; [(idx(i)-1)*ones(size(igps)) igps ...
                                             (1:length(igps))']];
                    end
                    igp_mask = mt18bandnum2ll(bandnum);
                    %find the inverse IGP mask
                    inv_igp_mask=find_inv_IGPmask(igp_mask);
                    igpdata(:,[COL_IGP_BAND COL_IGP_ID]) = bandnum(:,1:2);
                    igpdata(:,COL_IGP_LL) = igp_mask;
                    igpdata(:,COL_IGP_GIVEI) = MOPS_GIVEI_NM;
                    igpdata(:,COL_IGP_DELAY) = 0;
                    %find mapping between decoded MT26 data and igpdata matrix
                    mt26_to_igpdata = sub2ind(size(ionodata(gdx).mt26_givei), ...
                                         bandnum(:,1) + 1, bandnum(:,3));
                else
                    warning('MT18 iono mask is not complete')
                end
            else
                warning('MT18 iono mask has not been received')
            end
        end
    end
    %check the PRNS match the channels
    svdata = L1_decode_geocorr(tstart - 1, svdata, mt10);
    for gdx = 1:n_channels
        if svdata(gdx).geo_prn ~= sbas.prns(gdx)
            error('Mismatched prns - expected %d and found %d\n', ...
                    sbas.prns(gdx), svdata(gdx).geo_prn);
        end
    end
end
% initialize usr matrices
% see documentation for format of USRDATA,IGPDATA & USR2SATDATA
[usrdata,usrlatgrid,usrlongrid] = init_usrdata(usrfile,usrlatstep,usrlonstep);
usr2satdata = init_usr2satdata(usrdata,satdata);
truth_data = [];
usrtrpfun = 'af_trpmops';

vpl = NaN(size(usrdata,1),ntstep);
hpl = vpl;

los_in_bnd=ismember(usr2satdata(:,COL_U2S_UID), find(usrdata(:,COL_USR_INBND)));
givei = NaN(size(igpdata,1),ntstep);
udrei = NaN(size(satdata,1),ntstep);
betai=  NaN(size(igpdata,1),ntstep);
chi2ratioi=  NaN(size(igpdata,1),ntstep);

udre_hist=zeros(HIST_UDRE_NBINS+1,1);
give_hist=zeros(HIST_GIVE_NBINS+1,1);
udrei_hist=zeros(HIST_UDREI_NBINS,1);
givei_hist=zeros(HIST_GIVEI_NBINS,1);
nm_igp_hist=zeros(36,72);
sat_xyz=[];

if TRUTH_FLAG
   truth_matrix=load_truth(wrsdata, satdata);
   tcurr = tstart +truth_matrix(1,1);
else
    tcurr = tstart;
end
%profile on;

itstep = 1;

while tcurr<=tend

    % get current satellite positions
    satdata = init_satdata(geodata, alm_param, satdata, tcurr);
    
    if TRUTH_FLAG
        idx=find(truth_matrix(:,1) == tcurr - tstart);
        truth_data=truth_matrix(idx,:);
        if isempty(idx)
            fprintf('Time: %d / %d done\n',itstep,ntstep);
            tcurr = tcurr+tstep;
            itstep = itstep+1;
            continue
        end
    end
    
    % run in simulation mode if no recorded SBAS messages
    if isempty(SBAS_MESSAGE_FILE)
        % WMS processing (UDRE & GIVE)
        [satdata,igpdata,wrs2satdata]=wmsprocess(alm_param, satdata, wrsdata,...
            igpdata, wrs2satdata, gpsudrefun, geoudrefun, givefun, wrstrpfun,...
            wrsgpscnmpfun, wrsgeocnmpfun, outputs, tcurr, tstart, tstep,...
            wrs2sat_trise, inv_igp_mask, truth_data, dual_freq);
        
        %store the beta values
        betai(:,itstep) = igpdata(:,COL_IGP_BETA);

        %store the chi2ratio values
        chi2ratioi(:,itstep) = igpdata(:,COL_IGP_CHI2RATIO);

        %create a histogram of GIVEI values meeting minimum monitoring criteria
        hist_idx = find(igpdata(:,COL_IGP_MINMON));
        givei_hist = givei_hist+svm_hist(igpdata(hist_idx,COL_IGP_GIVEI),HIST_GIVEI_EDGES);
        givei_hist(MOPS_GIVEI_NM) = givei_hist(MOPS_GIVEI_NM) + ...
                                sum(isnan(igpdata(hist_idx,COL_IGP_GIVEI))); 
                            
        %create a histogram of UDREI values meeting minimum monitoring criteria                            
        hist_idx = find(satdata(:,COL_SAT_MINMON));
        udrei_hist = udrei_hist+svm_hist(satdata(hist_idx,COL_SAT_UDREI),HIST_UDREI_EDGES);
        udrei_hist(MOPS_UDREI_NM) = udrei_hist(MOPS_UDREI_NM) + ...
                                sum(isnan(satdata(hist_idx,COL_SAT_UDREI)));
    else
        % loop over the geo channels and read in the previously unread 
         %  messages up to the current time
        for gdx = 1:n_channels
            while sbas_msg_time{gdx}(smtidx(gdx)) <= tcurr
                msg = reshape(dec2bin(sbas_msgs{gdx}(smtidx(gdx),:),8)', 1,256);
                [svdata(gdx), ionodata(gdx), mt10(gdx), ~] = ...
                    L1_decode_messages(sbas_msg_time{gdx}(smtidx(gdx)), ...
                              msg, svdata(gdx), ionodata(gdx), mt10(gdx));
                smtidx(gdx) = smtidx(gdx) + 1;
            end
        end
        %check the message data for timeouts and compute corrections and degradations
        % check across all geos to obtain MT 9 positions
        svdata = L1_decode_geocorr(tcurr, svdata, mt10);
        for gdx = 1:n_channels
            if svdata(gdx).geo_prn ~= sbas.prns(gdx)
                error('Mismatched prns - expected %d and found %d\n', ...
                        sbas.prns(gdx), svdata(gdx).geo_prn);
            end
        end
    
        % only check other data on the prime channel used for corrections
        svdata(gprime)  = L1_decode_satcorr(tcurr, svdata(gprime), mt10(gprime));
        ionodata(gprime) = L1_decode_ionocorr(tcurr, ionodata(gprime), mt10(gprime));
        
        %transfer data to MAAST matrices
        satdata(:, COL_SAT_UDREI) = svdata(gprime).udrei(1:nsat);
        satdata(:, COL_SAT_DEGRAD) = svdata(gprime).degradation(1:nsat);
        rss_udre = mt10(gprime).rss_udre;
        if isempty(svdata(gprime).mt27_polygon)        
            satdata(:, COL_SAT_COV) = svdata(gprime).mt28_dCov(1:nsat,:);
            satdata(:, COL_SAT_SCALEF) = 2.^(svdata(gprime).mt28_sc_exp(1:nsat,:) - 5);
        else
            MT27 = svdata(gprime).mt27_polygon;
        end
        satdata(ngps + (1:ngeo), COL_SAT_XYZ) = svdata(gprime).geo_xyzb(1:ngeo,1:3);
        igpdata(:, COL_IGP_GIVEI) = ionodata(gprime).givei(mt26_to_igpdata);
        igpdata(:, COL_IGP_DEGRAD) = ionodata(gprime).eps_iono(mt26_to_igpdata);
        rss_iono = mt10(gprime).rss_iono;
        igpdata(:, COL_IGP_DELAY) = ionodata(gprime).mt26_Iv(mt26_to_igpdata);
    end
    
    %store the GIVE indices
    givei(:,itstep) = igpdata(:,COL_IGP_GIVEI);
    
    %store the UDRE indices
    udrei(:,itstep) = satdata(:,COL_SAT_UDREI);

    sat_xyz = [sat_xyz; satdata(:,COL_SAT_XYZ)];

    % USER processing
    [vhpl, usr2satdata] = usrprocess(satdata, usrdata, igpdata, ...
                               inv_igp_mask, usr2satdata, usrtrpfun, ...
                               usrcnmpfun, tcurr, pa_mode, dual_freq, ...
                               rss_udre, rss_iono);
    vpl(:,itstep) = vhpl(:,1);
    hpl(:,itstep) = vhpl(:,2);

    sig_flt = usr2satdata(:, COL_U2S_SIGFLT);
	hist_idx=find(los_in_bnd & ...
	              (-usr2satdata(:,COL_U2S_GENUB(3)) >= MOPS_SIN_USRMASK));
	udre_hist(1:HIST_UDRE_NBINS) = udre_hist(1:HIST_UDRE_NBINS) + ...
                                   svm_hist(3.29*sig_flt(hist_idx),...
	                                        HIST_UDRE_EDGES);
	udre_hist(HIST_UDRE_NBINS+1) = udre_hist(HIST_UDRE_NBINS+1) + ...
                                sum(isnan(sig_flt(hist_idx)) | ...
                                    sig_flt(hist_idx) == MOPS_NOT_MONITORED);
    sig2_uive = usr2satdata(:, COL_U2S_SIG2UIRE)./usr2satdata(:, COL_U2S_OB2PP);
	give_hist(1:HIST_GIVE_NBINS) = give_hist(1:HIST_GIVE_NBINS) + ...
                                   svm_hist(3.29*sqrt(sig2_uive(hist_idx)),...
	                                        HIST_GIVE_EDGES);
    is_nm_igp = isnan(sig2_uive(hist_idx)) | ...
                                    sig2_uive(hist_idx) == MOPS_NOT_MONITORED;
    N_nm_igp=sum(is_nm_igp);
	give_hist(HIST_GIVE_NBINS+1) = give_hist(HIST_GIVE_NBINS+1) + N_nm_igp;

    % create a histogram of IGP regions with Not Monitored UIVEs
% if 0
%     nm_igp_idx = find(is_nm_igp);
%     %two temporary lines to count all ipps
%     mask_idx = floor(usr2satdata(hist_idx, COL_U2S_IPPLL)/5);
%     N_nm_igp=length(hist_idx);
% %    mask_idx = floor(usr2satdata(hist_idx(nm_igp_idx), COL_U2S_IPPLL)/5);
%     mask_idx(:,2)=mod(mask_idx(:,2),72)+1;
% 
%     % adjust the latitude indicies to run from 1 to N
%     mask_idx(:,1)=mask_idx(:,1) + 19;
% 
%     for ii = 1:N_nm_igp
%       nm_igp_hist(mask_idx(ii,1),mask_idx(ii,2)) = ...
%                                nm_igp_hist(mask_idx(ii,1),mask_idx(ii,2)) + 1;
%     end
% end
    % update time
    if tstep==0
        break;
    else
        fprintf('Time: %d / %d done\n',itstep,ntstep);
        tcurr = tcurr+tstep;
        itstep = itstep+1;
    end
end

%profile off;
%figure;
%profile plot;
%profile viewer;
%profile off;
if (TRUTH_FLAG)
    fprintf('%d Chi2 Trips\n', TRIP_COUNT);
end

%remove added prns that have no corresponding positions
if ~isempty(added_prns)
    [~, idx] = ismember(added_prns, satdata(:,COL_SAT_PRN));
    satdata(idx,:) = [];
    udrei(idx,:) = [];
    sat_xyz(isnan(sat_xyz(:,1)),:) = [];
end

save 'outputs' satdata usrdata wrsdata igpdata inv_igp_mask sat_xyz udrei ...
               givei vpl hpl usrlatgrid usrlongrid udre_hist give_hist ...
		       udrei_hist givei_hist nm_igp_hist betai chi2ratioi;
% OUTPUT processing
outputprocess(satdata,usrdata,wrsdata,igpdata,inv_igp_mask,sat_xyz,udrei,...
              givei,vpl,hpl,usrlatgrid,usrlongrid,outputs,percent,vhal,pa_mode,...
			  udre_hist,give_hist,udrei_hist,givei_hist);




