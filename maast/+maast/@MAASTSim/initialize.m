function initialize(obj)
% initialize    initialize all the elements needed for the simulation
%
%   TODO: this may not actually be needed since a lot of the data is passed
%   into the constructor...


%
% create the time vector
%
obj.Tvec = Tstart:Tstep:(Tend-1);

%
% compute all the satellite positions
%

% TODO: need to think about if I want to keep the satellite position
% information separated by constellations or not
obj.SatellitePositions = obj.Constellations.getSatellitePosition(obj.Tvec);


%
% compute the observations for all users for all times
%

% TODO: this may be a bad thing to do here, this is a computationally
% intensive step...
% NOTE: this may be better to do in the loop once at a time 
% NOTE: if parallelizing then really want to do this by user since can
% throw this into the parallelization time
obj.Observations = maast.tools.UserObservation(obj.Users, obj.SatellitePositions);


%
% compute rise times for the WRSs
%
cnmpStart = obj.Tstart - maast.constants.CNMP.TL3;

% TODO: figure out a better way to handle this information
% This seems to be an added property of a WRS Observation...
% This is a value that is specific to each WRS / Satellite combination
% (based on the LOS information)
% TODO: maybe worth making a WRSObservation class that is a sub-class of a
% UserObservation since a WRS is going to be a sub-class of a User...
obj.TriseWRS = maast.internal.findTrise(cnmpStart, obj.Tend, maskAngle, obj.WRSs);

% TODO: rise times for the GEOs should be 0??? -> it's a concept that
% doesn't actually exist for a GEO


%
% initialize output matricies
%

% TODO: figure out what the output matrices are....