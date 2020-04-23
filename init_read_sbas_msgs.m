function [sbas_msgs, sbas_msg_time, smtidx, gprime, svdata, ionodata, mt10, ...
      satdata, alm_param, igpdata, inv_igp_mask, mt26_to_igpdata] = ...
                          init_read_sbas_msgs(tstart, satdata, alm_param)
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
% INIT_READ_SBAS_MSGS: Initializes reading in of the SBAS Messages.
%       Opens the file containing the 250 bit SBAS messages from different
%       GEOs and finds the ones corresponding to the GEO PRNs in SATDATA.
%       It reads in the ten minutes before the start time in order to
%       ensure it has a full set of satellite and iono corrections, these
%       are put into the SVDATA, IONODATA, and MT10 matrices for later use.
%
%   [sbas, smtidx, svdata, ionodata, mt10, satdata, alm_param, ...
%           igpdata, igp_mask, inv_igp_mask, mt26_to_igpdata] = ...
%                          init_read_sbas_msgs(tstart, satdata, alm_param)
% Inputs:
%   tstart    -   The starting time of the run
%   satdata   -   The matrix containing the initial satellite data
%   alm_param -   The almanac parameters for the GPS satellites
%
% Outputs:
%   sbas_msgs       - Matrix containing the 250 bit messages
%   sbas_msg_time   -  Matrix containing the times of the first message bit
%   smtidx          - Indices pointing to the current message and time
%   gprime          - Index of message stream from which to draw corrections
%   svdata          - Structure containing the decoded satellite data
%   ionodata        - Structure containing the decoded iono grid data
%   mt10            - Structure containing the decoded Message Type 10 data
%   satdata         - Updated satellite matrix to match the PRN mask 
%   alm_param       - Almanac parameters matrix to match the PRN mask
%   igpdata         - Matrix contianing the current iono grid data
%   igp_mask        - Matrix containing the IGP mask
%   inv_igp_mask    - Matrix to determine which IGPs to use for interpolation
%   mt26_to_igpdata - Mapping from ionodata MT26s to igpdata

%Created by Todd Walter April 20, 2020

global COL_SAT_PRN COL_SAT_XYZ COL_SAT_UDREI
global COL_IGP_BAND COL_IGP_ID COL_IGP_LL COL_IGP_GIVEI COL_IGP_DELAY
global MOPS_UDREI_NM MOPS_GIVEI_NM MOPS_MT1_PATIMEOUT MOPS_MT18_PATIMEOUT  
global SBAS_MESSAGE_FILE SBAS_PRIMARY_SOURCE

ngps = size(alm_param,1);
nsat = size(satdata, 1);
ngeo = nsat - ngps;
geoprns = satdata((ngps+1):end, COL_SAT_PRN);

load(SBAS_MESSAGE_FILE, 'sbas', 'sbas_msgs', 'sbas_msg_time');

% Find the corresponding geo message channels
[idx, gdx] = ismember(geoprns, sbas.prns);
n_channels = sum(idx);
if n_channels < 1
    error(['No matching SBAS messages found in ' SBAS_MESSAGE_FILE]);
elseif n_channels < ngeo
    disp(['Message streams only found for PRNs ' num2str(geoprns(idx)')]);
    gdx = gdx(idx);
    % remove missing geos from satdata   
    [~, jdx] = setdiff(satdata(ngps+(1:ngeo),COL_SAT_PRN), geoprns(idx));
    satdata(ngps+jdx,:) = [];
    ngeo = length(gdx);
    nsat = ngps + ngeo;
end    
% Remove uneeded geo data channels
sbas_msgs = sbas_msgs(gdx);
sbas_msg_time = sbas_msg_time(gdx);
sbas.prns = sbas.prns(gdx);

%set geo positions to NaN as they will later be taken from MT 9
satdata((ngps+1):end, COL_SAT_XYZ) = NaN;

% Make sure the primary source is included
[idx, gprime] = ismember(SBAS_PRIMARY_SOURCE, sbas.prns);
if sum(idx) < 1
    fprintf('Primary source PRN %d not located, using PRN %d instead\n', ...
              SBAS_PRIMARY_SOURCE, sbas.prns(1));
    gprime = 1;
end

% Loop over all geo SBAS message channels (backwards to preallocate)
for gdx = n_channels:-1:1
    %init decoding data
    svdata(gdx) = init_svdata();
    ionodata(gdx) = init_igp_msg_data();
    mt10(gdx) = init_mt10data();

    %initialize decoded message data with prior ten minutes of SBAS messages
    idx = find(sbas_msg_time{gdx} < tstart & ...
                sbas_msg_time{gdx} >= (tstart - 600));
    if ~isempty(idx)
        for i = 1:length(idx)
            msg = reshape(dec2bin(sbas_msgs{gdx}(idx(i),:),8)', 1,256);
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
            
            prns = svdata(gdx).prns;
            %check that the gps mask matches the gps almanac
            while svdata(gdx).mt1_ngps ~= ngps || ...
                    ~isequal(prns(1:ngps), satdata(1:ngps,COL_SAT_PRN))
                if svdata(gdx).mt1_ngps > ngps 
                    [missing_prns, idx] = setdiff(prns(1:svdata(gdx).mt1_ngps), ...
                                             satdata(1:ngps,COL_SAT_PRN));
                    while ~isempty(missing_prns)
                        %creates a repeated row that is always set to NM
                        satdata(idx(1):(end+1),:) = satdata((idx(1)-1):end,:);
                        satdata(idx(1),COL_SAT_PRN) = missing_prns(1);
                        satdata(idx(1),(COL_SAT_PRN+1):end) = NaN;
                        alm_param(idx(1):(end+1),:) = alm_param((idx(1)-1):end,:);
                        alm_param(idx(1),1) = missing_prns(1); 
                        alm_param(idx(1),2:end) = NaN; 
                        ngps = ngps + 1;
                        nsat = nsat + 1;
                        [missing_prns, idx] = setdiff(prns(1:svdata(gdx).mt1_ngps), ...
                                             satdata(1:ngps,COL_SAT_PRN));
                    end
                else
                    % delete uneeded row(s) in satdata and almparam
                    [~, idx] = setdiff(satdata(1:ngps,COL_SAT_PRN), ...
                                             prns(1:svdata(gdx).mt1_ngps));
                    satdata(idx,:) = [];
                    alm_param(idx,:) = []; 
                    ngps = ngps - length(idx);
                    nsat = nsat - length(idx);
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
        warning('Mismatched prns - expected %d and found %d\n', ...
                sbas.prns(gdx), svdata(gdx).geo_prn);
    end
end