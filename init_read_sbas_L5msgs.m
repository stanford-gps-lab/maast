function [sbas_msgs, sbas_msg_time, smtidx, gprime, svdata, ionodata, mt10, ...
             satdata, alm_param, igpdata, inv_igp_mask, mt26_to_igpdata] = ...
                          init_read_sbas_L5msgs(tstart, satdata, alm_param)
%*************************************************************************
%*     Copyright c 2021 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% INIT_READ_SBAS_L5MSGS: Initializes reading in of the L5 SBAS Messages.
%       Opens the file containing the 250 bit SBAS messages from different
%       GEOs and finds the ones corresponding to the GEO PRNs in SATDATA.
%       It reads in the five minutes before the start time in order to
%       ensure it has a full set of satellite corrections, these
%       are put into the SVDATA matrix for later use.
%
%   [sbas_msgs, sbas_msg_time, smtidx, gprime, svdata, satdata, alm_param] = ...
%                         init_read_sbas_L5msgs(tstart, satdata, alm_param)
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
%   satdata         - Updated satellite matrix to match the PRN mask 
%   alm_param       - Almanac parameters matrix to match the PRN mask

%Created by Todd Walter January 4, 2021

global COL_SAT_PRN COL_SAT_XYZ COL_SAT_UDREI
global L5MOPS_MT31_PATIMEOUT L5MOPS_DO_NOT_USE_SBAS
global SBAS_MESSAGE_FILE SBAS_PRIMARY_SOURCE

ngps = size(alm_param,1);
nsat = size(satdata, 1);
ngeo = nsat - ngps;
geoprns = satdata((ngps+1):end, COL_SAT_PRN);


ionodata = [];
mt10 = [];
igpdata = [];
inv_igp_mask = [];
mt26_to_igpdata = [];

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

%set geo positions to NaN as they will later be taken from MTs 39/40 or 47
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
    svdata(gdx) = init_L5svdata();

    %initialize decoded message data with prior five minutes of SBAS messages
    idx = find(sbas_msg_time{gdx} < tstart & ...
                sbas_msg_time{gdx} >= (tstart - 300));
    if ~isempty(idx)
        for i = 1:length(idx)
            msg = reshape(dec2bin(sbas_msgs{gdx}(idx(i),:),8)', 1,256);
            svdata(gdx) = L5_decode_messages(sbas_msg_time{gdx}(idx(i)), ...
                msg, svdata(gdx));
        end
    end
    smtidx(gdx) = idx(end) + 1;

    % Only need to match satdata from primary source
    if gdx == gprime
        % check PRN mask and initialize  svdata
        if svdata(gdx).mt31_time >= tstart - L5MOPS_MT31_PATIMEOUT
            
            prns = svdata(gdx).prns;
            %check that the gps mask matches the gps almanac
            while svdata(gdx).mt31_ngps ~= ngps || ...
                    ~isequal(prns(1:ngps), satdata(1:ngps,COL_SAT_PRN))
                if svdata(gdx).mt31_ngps > ngps 
                    [missing_prns, idx] = setdiff(prns(1:svdata(gdx).mt31_ngps), ...
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
                        [missing_prns, idx] = setdiff(prns(1:svdata(gdx).mt31_ngps), ...
                                             satdata(1:ngps,COL_SAT_PRN));
                    end
                else
                    % delete uneeded row(s) in satdata and almparam
                    [~, idx] = setdiff(satdata(1:ngps,COL_SAT_PRN), ...
                                             prns(1:svdata(gdx).mt31_ngps));
                    satdata(idx,:) = [];
                    alm_param(idx,:) = []; 
                    ngps = ngps - length(idx);
                    nsat = nsat - length(idx);
                end
            end
            satdata(:,COL_SAT_UDREI) = L5MOPS_DO_NOT_USE_SBAS;
        else
            warning('MT31 PRN mask has not been received')    
        end
    end
end
%check the PRNS match the channels
svdata = L5_decode_geocorr(tstart - 1, svdata);
for gdx = 1:n_channels
    if svdata(gdx).geo_prn ~= sbas.prns(gdx)
        warning('Mismatched prns - expected %d and found %d\n', ...
                sbas.prns(gdx), svdata(gdx).geo_prn);
    end
end