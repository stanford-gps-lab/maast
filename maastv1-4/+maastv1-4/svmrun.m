function svmrun(gpsudrefun, geoudrefun, givefun, usrcnmpfun,...
                wrsgpscnmpfun, wrsgeocnmpfun,...
                wrsfile, usrfile, igpfile, svfile, geodata, tstart, tend, ...
				tstep, usrlatstep, usrlonstep, outputs, percent, vhal, ...
                pa_mode, dual_freq);
%*************************************************************************
%*     Copyright c 2007 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% SVMRUN    Run the SVM simulation.
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

global CONST_H_IONO;
global COL_SAT_UDREI COL_SAT_PRN COL_SAT_XYZ COL_SAT_MINMON ...
        COL_USR_UID COL_IGP_LL COL_IGP_DELAY...
        COL_U2S_UID COL_U2S_PRN COL_U2S_MAX COL_U2S_TTRACK0 COL_U2S_GENUB...
        COL_U2S_IPPLL COL_IGP_GIVEI COL_IGP_MINMON COL_IGP_BETA...
        COL_IGP_CHI2RATIO
global  COL_USR_XYZ COL_USR_LL COL_USR_LLH COL_USR_EHAT ...
        COL_USR_NHAT COL_USR_UHAT COL_USR_INBND COL_USR_MAX
global HIST_UDRE_NBINS HIST_GIVE_NBINS HIST_UDRE_EDGES HIST_GIVE_EDGES
global HIST_UDREI_NBINS HIST_GIVEI_NBINS HIST_UDREI_EDGES HIST_GIVEI_EDGES
global MOPS_SIN_USRMASK MOPS_SIN_WRSMASK MOPS_NOT_MONITORED
global MOPS_UDREI_NM MOPS_GIVEI_NM MOPS_UDREI_MAX MOPS_GIVEI_MAX
global CNMP_TL3
global GRAPH_MOVIE_FIGNO TRUTH_FLAG RTR_FLAG

global TRIP_COUNT
TRIP_COUNT = 0;

fprintf('initializing run\n');
alm_param = read_yuma(svfile);


% initialize sat, wrs, usr, igp matrices (structures)
% see documentation for format of SATDATA,WRSDATA,USRDATA,IGPDATA,
%   WRS2SATDATA, USR2SATDATA
satdata=[];
satdata = init_satdata(geodata, alm_param, satdata, 0);
ngps = size(alm_param,1);
ngeo = size(geodata,1);
nsat=ngps+ngeo;
[usrdata,usrlatgrid,usrlongrid] = init_usrdata(usrfile,usrlatstep,usrlonstep);
wrsdata = init_wrsdata(wrsfile);
nwrs=size(wrsdata,1);
[igpdata, inv_igp_mask] = init_igpdata(igpfile);
wrs2satdata = init_usr2satdata(wrsdata,satdata);
usr2satdata = init_usr2satdata(usrdata,satdata);
truth_data = [];

wrstrpfun = 'af_trpmops';
usrtrpfun = 'af_trpmops';
if ~isempty(which('init_trop_osp'))
    init_trop_osp();
    wrstrpfun = 'af_trpadd';
end

if tstep>0,
    tend = tend - 1; % e.g. 86400 becomes 86399
    ntstep = floor((tend-tstart)/tstep)+1;
else
    ntstep = 1;
end
vpl = repmat(NaN,size(usrdata,1),ntstep);
hpl = vpl;
ncrit = vpl;

los_in_bnd=ismember(usr2satdata(:,COL_U2S_UID), find(usrdata(:,COL_USR_INBND)));
givei = repmat(NaN,size(igpdata,1),ntstep);
udrei = repmat(NaN,size(satdata,1),ntstep);
betai=  repmat(NaN,size(igpdata,1),ntstep);
chi2ratioi=  repmat(NaN,size(igpdata,1),ntstep);


udre_hist=zeros(HIST_UDRE_NBINS+1,1);
give_hist=zeros(HIST_GIVE_NBINS+1,1);
udrei_hist=zeros(HIST_UDREI_NBINS,1);
givei_hist=zeros(HIST_GIVEI_NBINS,1);
nm_igp_hist=zeros(36,72);
sat_xyz=[];

% find all los rise times for cnmp calculation, 
% start from tstart-CNMP_TL3 (below this, cnmp is at floor value)
if isempty(CNMP_TL3)
    CNMP_TL3 = 12000;
end
wrs2sat_trise = find_trise(tstart-CNMP_TL3,tend,MOPS_SIN_WRSMASK,alm_param,...
            wrsdata(:,COL_USR_XYZ),wrsdata(:,COL_USR_EHAT),...
            wrsdata(:,COL_USR_NHAT),wrsdata(:,COL_USR_UHAT));
%add blank rows for geos
nrise=size(wrs2sat_trise,2);
wrs2sat_trise = reshape(wrs2sat_trise, ngps, nwrs, nrise);
wrs2sat_trise(ngps+1:ngps+ngeo,:,:)=zeros(ngeo, nwrs, nrise);
wrs2sat_trise = reshape(wrs2sat_trise, nsat*nwrs, nrise);

if TRUTH_FLAG
   truth_matrix=load_truth(wrsdata, satdata);
   tcurr = tstart +truth_matrix(1,1);
else
    tcurr = tstart;
end
%profile on;

itstep = 1;

while tcurr<=tend,

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
    % WMS processing (UDRE & GIVE)
    [satdata,igpdata,wrs2satdata]=wmsprocess(alm_param, satdata, wrsdata,...
        igpdata, wrs2satdata, gpsudrefun, geoudrefun, givefun, wrstrpfun,...
        wrsgpscnmpfun, wrsgeocnmpfun, outputs, tcurr, tstart, tstep,...
        wrs2sat_trise, inv_igp_mask, truth_data, dual_freq);
    %if truthflag
      %h=figure(GRAPH_MOVIE_FIGNO);
      %iono_contour(igpdata(:,COL_IGP_LL), inv_igp_mask, ...
      %             igpdata(:,COL_IGP_GIVEI), igpdata(:,COL_IGP_DELAY), ...
      %             truth_data, [-130 -60 20 55]);
      %set(h,'name','DELAY MAP');
      %M(itstep)=getframe(h);
      %end
    %store the GIVE indices
    givei(:,itstep) = igpdata(:,COL_IGP_GIVEI);
    
    %store the beta values
    betai(:,itstep) = igpdata(:,COL_IGP_BETA);
    
    %store the chi2ratio values
    chi2ratioi(:,itstep) = igpdata(:,COL_IGP_CHI2RATIO);
    
    
    %create a histogram of values meeting minimum monitoring criteria
	hist_idx = find(igpdata(:,COL_IGP_MINMON));
	givei_hist = givei_hist+svm_hist(givei(hist_idx,itstep),HIST_GIVEI_EDGES);
    givei_hist(MOPS_GIVEI_NM) = givei_hist(MOPS_GIVEI_NM) + ...
                                sum(isnan(givei(hist_idx,itstep)));
    udrei(:,itstep) = satdata(:,COL_SAT_UDREI);
	hist_idx = find(satdata(:,COL_SAT_MINMON));
	udrei_hist = udrei_hist+svm_hist(udrei(hist_idx,itstep),HIST_UDREI_EDGES);
    udrei_hist(MOPS_UDREI_NM) = udrei_hist(MOPS_UDREI_NM) + ...
                                sum(isnan(udrei(hist_idx,itstep)));
    sat_xyz = [sat_xyz; satdata(:,COL_SAT_XYZ)];

    % USER processing
    [vhpl,sig2_flt,sig2_uive, usr2satdata] = usrprocess(satdata,usrdata,...
                        igpdata,inv_igp_mask,usr2satdata,usrtrpfun,...
                        usrcnmpfun,alm_param,tcurr,pa_mode,dual_freq);
    vpl(:,itstep) = vhpl(:,1);
    hpl(:,itstep) = vhpl(:,2);
%    ncritv(:,itstep) = vhpl(:,3);
%    ncrith(:,itstep) = vhpl(:,4);
	hist_idx=find(los_in_bnd & ...
	              (-usr2satdata(:,COL_U2S_GENUB(3)) >= MOPS_SIN_USRMASK));
	udre_hist(1:HIST_UDRE_NBINS) = udre_hist(1:HIST_UDRE_NBINS) + ...
                                   svm_hist(3.29*sqrt(sig2_flt(hist_idx)),...
	                                        HIST_UDRE_EDGES);
	udre_hist(HIST_UDRE_NBINS+1) = udre_hist(HIST_UDRE_NBINS+1) + ...
                                sum(isnan(sig2_flt(hist_idx)) | ...
                                    sig2_flt(hist_idx) == MOPS_NOT_MONITORED);
	give_hist(1:HIST_GIVE_NBINS) = give_hist(1:HIST_GIVE_NBINS) + ...
                                   svm_hist(3.29*sqrt(sig2_uive(hist_idx)),...
	                                        HIST_GIVE_EDGES);
    is_nm_igp = isnan(sig2_uive(hist_idx)) | ...
                                    sig2_uive(hist_idx) == MOPS_NOT_MONITORED;
    N_nm_igp=sum(is_nm_igp);
	give_hist(HIST_GIVE_NBINS+1) = give_hist(HIST_GIVE_NBINS+1) + N_nm_igp;

    % create a histogram of IGP regions with Not Monitored UIVEs
if 0
    nm_igp_idx = find(is_nm_igp);
    %two temporary lines to count all ipps
    mask_idx = floor(usr2satdata(hist_idx, COL_U2S_IPPLL)/5);
    N_nm_igp=length(hist_idx);
%    mask_idx = floor(usr2satdata(hist_idx(nm_igp_idx), COL_U2S_IPPLL)/5);
    mask_idx(:,2)=mod(mask_idx(:,2),72)+1;

    % adjust the latitude indicies to run from 1 to N
    mask_idx(:,1)=mask_idx(:,1) + 19;

    for ii = 1:N_nm_igp
      nm_igp_hist(mask_idx(ii,1),mask_idx(ii,2)) = ...
                               nm_igp_hist(mask_idx(ii,1),mask_idx(ii,2)) + 1;
    end
end
    % update time
    if tstep==0,
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




