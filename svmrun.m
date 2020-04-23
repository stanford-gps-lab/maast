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
global COL_SAT_UDREI COL_SAT_DEGRAD COL_SAT_XYZ COL_SAT_MINMON
global COL_IGP_GIVEI COL_IGP_MINMON COL_IGP_BETA COL_IGP_DEGRAD COL_IGP_CHI2RATIO
global  COL_USR_XYZ COL_USR_EHAT COL_USR_NHAT COL_USR_UHAT COL_USR_INBND 
global COL_U2S_SIGFLT COL_U2S_SIG2UIRE COL_U2S_OB2PP COL_U2S_UID  COL_U2S_GENUB
global HIST_UDRE_NBINS HIST_GIVE_NBINS HIST_UDRE_EDGES HIST_GIVE_EDGES
global HIST_UDREI_NBINS HIST_GIVEI_NBINS HIST_UDREI_EDGES HIST_GIVEI_EDGES
global MOPS_SIN_USRMASK MOPS_SIN_WRSMASK MOPS_NOT_MONITORED
global MOPS_UDREI_NM MOPS_GIVEI_NM
global CNMP_TL3

global SBAS_MESSAGE_FILE

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
satdata = init_satdata(geodata, alm_param, satdata, tstart);
ngps = size(alm_param,1);
ngeo = size(geodata,1);
nsat = ngps + ngeo;
wrsdata = init_wrsdata(wrsfile);
nwrs=size(wrsdata,1);
  
%Run using either recorded SBAS 250 bit messages or simulate the SBAS
%processing  to create UDREs/DFREs and GIVEIs
if isempty(SBAS_MESSAGE_FILE)
    % SIMULATED DATA INITIALIZATION:
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
    % REPLAY RECORDED DATA INITIALIZATION:
    % read in the MOPS messages that correspond to the almanac day
    % file that can be generated with get_sbas_broadcast_from_rinex.m
    % make sure that the times correspond and include data from 10 minutes 
    % before the start time so that the msg data can be initialized
    [sbas_msgs, sbas_msg_time, smtidx, gprime, svdata, ionodata, mt10, ...
          satdata, alm_param, igpdata, inv_igp_mask, mt26_to_igpdata] = ...
                           init_read_sbas_msgs(tstart, satdata, alm_param);
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
        [smtidx, svdata, ionodata, mt10, satdata, igpdata] = ...
             read_in_sbas_messages(tcurr, sbas_msgs, sbas_msg_time, ...
                    smtidx, gprime, svdata, ionodata, mt10, satdata, ...
                    igpdata, mt26_to_igpdata);
        rss_udre = mt10(gprime).rss_udre;
        rss_iono = mt10(gprime).rss_iono;
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

save 'outputs' satdata usrdata wrsdata igpdata inv_igp_mask sat_xyz udrei ...
               givei vpl hpl usrlatgrid usrlongrid udre_hist give_hist ...
		       udrei_hist givei_hist nm_igp_hist betai chi2ratioi;
% OUTPUT processing
outputprocess(satdata,usrdata,wrsdata,igpdata,inv_igp_mask,sat_xyz,udrei,...
              givei,vpl,hpl,usrlatgrid,usrlongrid,outputs,percent,vhal,pa_mode,...
			  udre_hist,give_hist,udrei_hist,givei_hist);




