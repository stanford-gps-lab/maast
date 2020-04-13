function igpdata = L1_decode_ionocorr(time, igpdata, mt10)
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

global MOPS_GIVEI_NM
global MOPS_MT10_PATIMEOUT MOPS_MT18_PATIMEOUT MOPS_MT26_PATIMEOUT


%need to have MT10 degradation information
if mt10.time >= (time - MOPS_MT10_PATIMEOUT)
    igpdata.givei  = igpdata.mt26_givei;
    igpdata.eps_iono = zeros(size(igpdata.mt26_givei));
    
    %find the times since the most recent messages
    dt18 = time - igpdata.mt18_time;    
    dt26 = time - igpdata.mt26_time;    
    
    %find the iono degradation
    igpdata.eps_iono = mt10.ciono_step*floor(dt26/mt10.iiono) + ...
                        mt10.ciono_ramp*dt26;
                    
    %set the GIVEs to NM for any IGP with a timed out correction component
    % or whose iodis do not match
    idx = dt18 > MOPS_MT18_PATIMEOUT  | dt26 > MOPS_MT26_PATIMEOUT | ...
            igpdata.mt26_iodi ~= igpdata.mt18_iodi;
     if any(idx)
         igpdata.givei(idx)  = MOPS_GIVEI_NM;
         igpdata.eps_iono(idx) = NaN;
     end
else    
    %IGP data cannot be used for PA
    igpdata.givei    = repmat(MOPS_GIVEI_NM, size(igpdata.mt26_givei));
    igpdata.eps_iono = NaN(size(igpdata.mt26_givei));
end
