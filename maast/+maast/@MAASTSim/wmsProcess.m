function wmsProcess(obj)
% wmsProcess    run the processing for the WAAS Master Station for the
% current time

% get the current time from the current simulation index
i = obj.Index;
t = obj.Tvec(i);

% TODO: do the rest of the processing


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CODE BELOW IS A COPY FROM THE ORIGINAL MAAST CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Inputs:
%   userObs -> the observation data for all users at this time step (Ux1)
%   time -> the current simulation tim
%   tstart -> the sim start time (TODO: want to remove this)
%   trise -> precomputed set of rise times for all the satellites
%   *fn -> function handles for specific purposes

% Outputs:
%   TODO: figure out what elements of the satdata, igpdata and wrs2satdata
%   are used later on
                            
% NOTE: going to ignore all the inputs for now and list what I need here
%   - userObs - need obs for all users to all satellites at a give time
%   (Ux1) array


% NOTE: also want to remove all the globals
% TODO: need a set of MOPS related constants

global MOPS_SIN_WRSMASK CONST_H_IONO
global COL_SAT_PRN COL_SAT_XYZ COL_USR_XYZ COL_USR_LL ...
        COL_USR_EHAT COL_USR_NHAT COL_USR_UHAT  COL_IGP_LL ...
        COL_IGP_GIVEI COL_IGP_UPMGIVEI COL_U2S_PRN COL_U2S_GXYZB ...
        COL_U2S_LOSENU COL_U2S_GENUB COL_U2S_EL COL_U2S_AZ COL_U2S_SIG2TRP ...
        COL_U2S_SIG2L1MP COL_U2S_SIG2L2MP COL_U2S_IPPLL COL_U2S_IPPXYZ ...
        COL_U2S_TTRACK0 COL_U2S_IVPP COL_U2S_INITNAN 
global CNMP_TL3
global MOPS_MIN_GPSPRN MOPS_MAX_GPSPRN MOPS_MIN_GLOPRN MOPS_MAX_GLOPRN 
global MOPS_MIN_GALPRN MOPS_MAX_GALPRN MOPS_MIN_GEOPRN MOPS_MAX_GEOPRN
global MOPS_MIN_BDUPRN MOPS_MAX_BDUPRN
global TRUTH_FLAG CONST_R_E CONST_R_IONO;

% get size information
nsat = size(satdata,1);
nwrs = size(wrsdata,1);

% find index of constellation and GEOs in the satdata matrix

% TODO: figure out why this is the case
% - is processing done on a per constellation basis?

sgps=find(satdata(:,COL_SAT_PRN) >= MOPS_MIN_GPSPRN & ...
          satdata(:,COL_SAT_PRN) <= MOPS_MAX_GPSPRN);
sglo=find(satdata(:,COL_SAT_PRN) >= MOPS_MIN_GLOPRN & ...
          satdata(:,COL_SAT_PRN) <= MOPS_MAX_GLOPRN);
sgal=find(satdata(:,COL_SAT_PRN) >= MOPS_MIN_GALPRN & ...
          satdata(:,COL_SAT_PRN) <= MOPS_MAX_GALPRN);
sbdu=find(satdata(:,COL_SAT_PRN) >= MOPS_MIN_BDUPRN & ...
          satdata(:,COL_SAT_PRN) <= MOPS_MAX_BDUPRN);
sgnss =[sgps; sglo; sgal; sbdu];  % combine the index locations of all the GNSS satellites

sgeo=find(satdata(:,COL_SAT_PRN) >= MOPS_MIN_GEOPRN & ...
          satdata(:,COL_SAT_PRN) <= MOPS_MAX_GEOPRN);
% only one vector of GEO satellites

% initialize some values to NaN
wrs2satdata(:,COL_U2S_INITNAN) = NaN;


% NOTE: for now ignorning the "TRUTH_FLAG"
%   TODO: determine what the truth flag is designed to do and how the
%   processing is different

% if TRUTH_FLAG
%   abv_mask=sub2ind([nsat nwrs], truth_data(:,3), truth_data(:,2));
%   wrs2satdata(abv_mask,COL_U2S_EL) = truth_data(:,7);
%   wrs2satdata(abv_mask,COL_U2S_AZ) = truth_data(:,6);
%   wrs2satdata(abv_mask,COL_U2S_GENUB) = ...
%                    [-cos(wrs2satdata(abv_mask,COL_U2S_EL)).*...
%                     sin(wrs2satdata(abv_mask,COL_U2S_AZ)) ...
%                     -cos(wrs2satdata(abv_mask,COL_U2S_EL)).*...
%                     cos(wrs2satdata(abv_mask,COL_U2S_AZ)) ...
%                     -sin(wrs2satdata(abv_mask,COL_U2S_EL)) ones(size(abv_mask))];
%   wrs2satdata(abv_mask,COL_U2S_GXYZB) = ...
%       find_los_enub(wrs2satdata(:,COL_U2S_GENUB),...
%                   [wrsdata(:,COL_USR_EHAT(1)) wrsdata(:,COL_USR_NHAT(1)) ...
%                    wrsdata(:,COL_USR_UHAT(1))], ...
%                   [wrsdata(:,COL_USR_EHAT(2)) wrsdata(:,COL_USR_NHAT(2)) ...
%                    wrsdata(:,COL_USR_UHAT(2))], ...
%                   [wrsdata(:,COL_USR_EHAT(3)) wrsdata(:,COL_USR_NHAT(3)) ...
%                    wrsdata(:,COL_USR_UHAT(3))], abv_mask);
%   wrs2satdata(abv_mask,COL_U2S_IPPLL) = find_ll_ipp(wrsdata(:,COL_USR_LL),...
%                                   wrs2satdata(:,COL_U2S_EL),...
%                                   wrs2satdata(:,COL_U2S_AZ), abv_mask);
%   wrs2satdata(abv_mask,COL_U2S_IPPXYZ) = ...
%           llh2xyz([wrs2satdata(abv_mask,COL_U2S_IPPLL),...
%                   repmat(CONST_H_IONO,length(abv_mask),1)]);
%   obliquity2 = 1./(sqrt(1-(CONST_R_E * cos( truth_data(:,7) ) / (CONST_R_IONO)).^2));
%   wrs2satdata(abv_mask,COL_U2S_IVPP) = truth_data(:,8) ./ obliquity2;
% else
    
    % code of interest
    
    %
    % find the IPP first in LLH and then covert those to XYZ
    %   does this through first finding the LOS, then finding the
    %   satellites in view and computing the IPP for the observation
    %
    %   NOTE: for the conversion from LLH to XYZ, it takes the LL from the
    %   IPP and the H from the iono constant
    %
    
    % NOTE: userObs already contains all the LOS data that was computed
    % here up until now
    
    % get the IPP for all the users
    % TODO: need to get this function working for an entire set of
    % observations, not just a single observation
    ipp = userObs.getIPP();  % this should only compute the IPP of the satellites in view
    
    ippECEF = maast.tools.llh2ecef(ipp);  % need to convert to ECEF -> NOTE: may be used in another function, TBD
    
    % NOTE: abv_mask is a list of indices of entries in the wrs2satdata
    % matrix (rows of the matrix) and therefore specific indices of
    % satellites/user LOS pairs

% end  % end of the if truth case

% get the elevation angles
%   TODO: figure out how to combine this data for all the satellites and
%   users
%   this is all being process at a single time step, so let el be a UxS
%   matrix for U users and S satellites
%   NOTE: should satellites that are not in view be NaN or what???
%   NOTE: how should I handle combining all the data for all the users
%
%   TODO: for multi-threading would want to split by users and then
%   sequentially by time, which would result in this being a 1xSv for one
%   user and Sv satellites in view
el = userObs.ElevationAngles;


%
% compute sig^2_tropo
%   this is only a function of the elevation data (call to a tropo
%   algorithm - fn - that accepts the elevation and returns sig^2_tropo)
%

%
% tropo
%
sig2_tropo = tropofn(el);

%
% compute CNMP, UDRE, and GIVE values
%   NOTE: once again this looks at the TTRACK0 parameter
%

% Calculate cnmp, udre and give
%
% TODO: this constant should be set somewhere else...
% TODO: figure out where this is set and how it is set
if isempty(CNMP_TL3)
    CNMP_TL3 = 12000;
end

%
% before can compute things, need to get the TTRACK0 times for all of the
% satellite in view
%

% NOTE: I think I should make this into a function for UserObservations???
% ttrack0 = userObs.getTTrack0(time, trise, early);  % pass in the current
% time, the precomputed rise time sets and the "default" to assume if it
% has been in view for a while
%
% TODO: trise should maybe be somehow implemented into User / Satellite or
% UserObservations class
%
% right now as designed userObs is the only thing with time knowledge

% assume ttrack0 exists at this point and has the proper dimensions
% I think it needs to be UxS -> it's a rise time for all the LOSs for all
% the users at this time step
ttrack0 = [];


% for i=1:length(abv_mask)
%     % NOTE: trise is an S*MaxNrise matrix of the rise time of every satellite
%     % for every user
%     % it seems that a satellite can rise more than once for a given user,
%     % so the columns of the matrix are each of the different rise times (I
%     % think NaN if the satellite doesn't rise the max number of times)
%     idx=find(trise(abv_mask(i),:)<=time);  % find the column index for this in view LOS that is earlier than this time
%     if ~isempty(idx)
%         % set TTRACK0 to be the max of the possible rise times (closest in
%         % time to where we are now?)
%         wrs2satdata(abv_mask(i),COL_U2S_TTRACK0)=max(trise(abv_mask(i),idx));
%     else    % los is has been visible since tstart-CNMP_TL3
%         
%         % there is no rise time data, which seems to assume that the
%         % satellite has been visible since tstart-CNMP_TL3 -> not sure what
%         % CNMP_TL3 is..
%         %
%         % NOTE: it seems that this function requires knowledge of the
%         % simulation time bounds, which is not really ideal....
%         wrs2satdata(abv_mask(i),COL_U2S_TTRACK0)=tstart-CNMP_TL3;
%     end
% end

% NOTE: ttrack seems to be how much time has ellapsed since rise and now
% (with the addition of 1...) -> NEED TO FIGURE OUT THE UNIT OF THE TIME
% VECTOR
ttrack = time - ttrack0 + 1;  % TODO: dimensions should be UxS

% get the index for the different constellations in the wrs2satdata matrix
% TODO: may want to split things up by constellation and allow the
% processing of multiple constellations at the same time
wgps=find(wrs2satdata(:,COL_U2S_PRN) >= MOPS_MIN_GPSPRN & ...
          wrs2satdata(:,COL_U2S_PRN) <= MOPS_MAX_GPSPRN);
wglo=find(wrs2satdata(:,COL_U2S_PRN) >= MOPS_MIN_GLOPRN & ...
          wrs2satdata(:,COL_U2S_PRN) <= MOPS_MAX_GLOPRN);
wgal=find(wrs2satdata(:,COL_U2S_PRN) >= MOPS_MIN_GALPRN & ...
          wrs2satdata(:,COL_U2S_PRN) <= MOPS_MAX_GALPRN);
wbdu=find(wrs2satdata(:,COL_U2S_PRN) >= MOPS_MIN_BDUPRN & ...
          wrs2satdata(:,COL_U2S_PRN) <= MOPS_MAX_BDUPRN);
wgnss =sort([wgps; wglo; wgal; wbdu]);  % combine all the indices in a sorted way (?)

wgeo=find(wrs2satdata(:,COL_U2S_PRN) >= MOPS_MIN_GEOPRN & ...
          wrs2satdata(:,COL_U2S_PRN) <= MOPS_MAX_GEOPRN);

% once again the GEO indices are off by themselves

%
% cnmp
%   split into 2 steps, one for GNSS and one for GEOs
%   for each type, only compute CNMP if an algorithm has been passed to it
%
%   algorithm for CNMP is structured to have inputs of ttrack and elevation
%   and an output of sig^2_l1mp
%
%   NOTE: it seems that the sig^2_l2mp is set to be the same thing as the
%   L1MP value -> not sure if in the future the goal is to have multiple
%   different elements here or what

% compute CNMP for the GNSS constellations if requested
% TODO: maybe this algorithm can be part of the constellation class since
% it seems like a constellation dependent function...
% really not sure
%
% TODO: maybe have 2 inputs, userObs to GNSS and userObs to GEO
% TODO: if split userObs, need to see at what level of interest there is in
% each of the constellations (always processed together, or always analyzed
% separately)
sig2gnss_l1mp = NaN(U, S);  % NaN UxSgnss matrix
sig2gnss_l2mp = NaN(U, S);  % NaN UxSgnss matrix
if ~isempty(gpscnmpfn)
    sig2gnss_l1mp = gpscnmpfn(ttrack, el);  % TODO: should only pass the ttrack and el to the GNSS satellites
    sig2gnss_l2mp = sig2gnss_l1mp;  % straight copy it
end

% compute CNMP for the GEO constellations if requested
sig2geo_l1mp = NaN(U, S);  % NaN UxSgeo matrix
sig2geo_l2mp = NaN(U, S);  % NaN UxSgeo matrix
if ~isempty(gpscnmpfn)
    sig2geo_l1mp = geocnmpfn(ttrack, el);  % TODO: should only pass the ttrack and el to the GNSS satellites
    sig2geo_l2mp = sig2geo_l1mp;  % straight copy it
end



% udre
%    seems to be a function of some of the sat data, the WRS location and
%    the data from WRS to the sat
%
%   NOTE: seems to be only processed for the GNSS satellites
satdata(sgnss,:) = feval(gpsudrefun, satdata(sgnss,:), wrsdata, ...
                        wrs2satdata(wgnss,:), 1);
%
% give
%   seems to be a difference between in a dual frequency mode and not with
%   dual_freq being an input parameter into the function (setting
%   parameter in the future?)
%
%   function is again complicated taking in the current time, IGP data, WRS
%   data, sat and observation data to the GNSS satellites only and
%   truth_data
%
% TODO: what is truth_data???
%
%   the data for the GEOs are compused with a totally different function???
%   seems to interpolate data and such

if(~dual_freq)
    igpdata = feval(givefun, time, igpdata, wrsdata, satdata(sgnss,:), ...
                    wrs2satdata(wgnss,:), truth_data);

    %interpolate the SP and UPM GIVEIs to the GEO LOSs
    wrs2satdata(wgeo,COL_U2S_IVPP)=grid2uive(wrs2satdata(wgeo,COL_U2S_IPPLL), ...
                                                igpdata(:,COL_IGP_LL), ...
                                                inv_igp_mask, ...
                                                igpdata(:,COL_IGP_GIVEI));        
    wrs2satdata(wgeo,COL_U2S_SIG2L2MP)=grid2uive(wrs2satdata(wgeo,COL_U2S_IPPLL), ...
                                                igpdata(:,COL_IGP_LL), ...
                                                inv_igp_mask, ...
                                                igpdata(:,COL_IGP_UPMGIVEI));
end


% compute UDRE for the GEOs using a different UDRE function that takes in
% an additional `dual_freq` parameter over the GNSS UDRE function
satdata(sgeo,:) = feval(geoudrefun, satdata(sgeo,:), wrsdata, ...
                        wrs2satdata(wgeo,:), 1, dual_freq);