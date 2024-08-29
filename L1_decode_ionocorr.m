function igpdata = L1_decode_ionocorr(time, igpdata, mt10, auth_pass)
%*************************************************************************
%*     Copyright c 2024 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%
% L1_DECODE_IONOCORR determined which decoded 250 bit SBAS ionospheric grid 
%  correction data is ready to use and determines the confidence bounds
%
% igpdata = L1_decode_ionocorr(time, igpdata, mt10)
%
% Inputs:
%   time    -   time when corrections should be applied
%   igpdata -   structure with iono grid correction data decoded from the messages
%   mt10    -   structure with degradation parameters from MT10
%
%Outputs:
%   igpdata  - structure with interpreted iono grid correction data and all
%                   appropriate timeouts checked
%    .givei - most recent non timed out GIVEI
%    .degradation - sum of the fast correction (fc), range rate correction (rrc), 
%                and long term correction (ltc) degradation variances
%
%See also: INIT_IGPDATA INIT_MT10DATA L1_DECODE_MESSAGES L1_DECODEMT0
%          L1_DECODEMT18 L1_DECODEMT26 


%Created March 30, 2020 by Todd Walter
%Modified August 22, 2024 by Todd Walter

global MOPS_GIVEI_NM
global MOPS_MT10_PATIMEOUT MOPS_MT18_PATIMEOUT MOPS_MT26_PATIMEOUT

max_bands = size(igpdata.givei,1);
max_igps = size(igpdata.givei,2);
n_msgs = size(igpdata.mt26,2);
valid_mask = false;

igpdata.givei    = repmat(MOPS_GIVEI_NM, size(igpdata.givei));
igpdata.eps_iono = NaN(size(igpdata.eps_iono));

% find the active IODI
mdx26 = find(~isnan([igpdata.mt26.iodi]) & ...
                ([igpdata.mt26.time] >= (time - MOPS_MT26_PATIMEOUT)) & ...
                 auth_pass([igpdata.mt26.msg_idx])');
if any(mdx26)
    tmp = [igpdata.mt26.time];
    [~, i] = max([tmp(mdx26)]);
    tmp = [igpdata.mt26.iodi];
    tmp = tmp(mdx26);
    iodi = tmp(i);
else
    iodi = -1;
end

%Must have all valid MT 18 messages in order to have valid corrections
mdx18 = ([igpdata.mt18.time] >= (time - MOPS_MT18_PATIMEOUT)) & ...
          ([igpdata.mt18.iodi] == iodi)  & ...
          auth_pass([igpdata.mt18.msg_idx])';

%find the most recent valid message in each band
idx = reshape(mdx18,max_bands,n_msgs);
for i = 1:(n_msgs-1)
    idx(idx(:,i),(i+1):n_msgs) = false;
end
mdx18 = reshape(idx,max_bands*n_msgs,1);

if any(mdx18)
    num_bands = unique([igpdata.mt18(mdx18).num_bands]);
    if length(num_bands) > 1
        warning('Mismatched Iono Mask Messages')
    elseif sum(mdx18) == num_bands
        valid_mask = true;
        % Check to see if this mask has been initialized
        % if not, initialize it
        if igpdata.iodi ~= iodi
            bandids = find(any(idx,2));
            bandigpnum = [];
            for jdx = 1:num_bands
                bdx = bandids(jdx);
                mdx = find(idx(bandids(jdx),:));
                tmp =[];
                tmp(:,2) = find(igpdata.mt18(bdx,mdx).mask)';
                tmp(:,1) = bdx - 1;
                tmp(:,3) = 1:size(tmp,1);
                bandigpnum = [bandigpnum; tmp];
            end
            [igpdata.igp_mat,igpdata.inv_igp_mask] = init_igpdata([], bandigpnum);

            %find mapping between decoded MT26 data and igpdata matrix
            igpdata.mt26_to_igpdata = sub2ind([10 201], ...
                                 bandigpnum(:,1) + 1, bandigpnum(:,3));
            igpdata.iodi = iodi;
        end
    end
end

%need to have MT10 degradation information
mdx10 = find(([mt10.time] >= (time - MOPS_MT10_PATIMEOUT)) & ...
          auth_pass([mt10.msg_idx])');

%find the most recent valid MT26 messages
mdx26 = ([igpdata.mt26.time] >= (time - MOPS_MT26_PATIMEOUT)) & ...
    [igpdata.mt26.iodi] == iodi & auth_pass([igpdata.mt26.msg_idx])';

if any(mdx26) && valid_mask && ~isempty(mdx10)
    %find the first valid message for each IGP
    idx = reshape(mdx26,max_igps*max_bands,n_msgs);
    for i = 1:(n_msgs-1)
        idx(idx(:,i),(i+1):n_msgs) = false;
    end
    mdx26 = reshape(idx,max_igps*max_bands*n_msgs,1);
    idx = any(idx,2);

    % Transfer message contents for each Band
    for bdx = 1:max_bands
        igp_idx = (bdx-1)*max_igps + (1:max_igps);
        m26_idx = false(size(mdx26));
        for i = 1:n_msgs
            m26_idx(max_igps*(bdx-1) + (i-1)*max_igps*max_bands + (1:(max_igps))) = true;
        end
        m26_idx = m26_idx & mdx26;

        if any(idx(igp_idx))

            igpdata.v_delay(bdx,idx(igp_idx))  = [igpdata.mt26(m26_idx).Iv];
            igpdata.givei(bdx,idx(igp_idx))  = [igpdata.mt26(m26_idx).givei];
            
            %find the times since the most recent messages
            dt26 = time - [igpdata.mt26(m26_idx).time];    
            
            %find the iono degradation
            igpdata.eps_iono(bdx,idx(igp_idx)) = mt10(mdx10).ciono_step*floor(dt26/mt10(mdx10).iiono) + ...
                                        mt10(mdx10).ciono_ramp*dt26;
        end
    end
else    
    %IGP data cannot be used for PA
    igpdata.givei    = repmat(MOPS_GIVEI_NM, size(igpdata.givei));
    igpdata.eps_iono = NaN(size(igpdata.eps_iono));
end
