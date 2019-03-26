classdef MAASTSim < handle
% MAASTSim  class to handle the MAAST simulation
%   NOTE: this is a class wrapper that handles the core elements that
%   `maast_no_gui` and svmrun() used to do.
    
    % general sim properties
    properties
        
        % Constellations - the constellations to use in the analysis
        %   can be an array of constellations of interest
        Constellations
        
        % Users - the list of users for which to do the analysis
        Users
        
        % WRS - the list of WAAS reference stations for the analysis
        WRSs
        
        % Tstart - the start time for the simulation run
        Tstart
        
        % Tend - the end time for the simulation run
        Tend
        
        % Tstep - the time step to use for the simulation run
        Tstep
        
        % TODO: figure out how to handle the algorithms part
    end
    
    % data that is passed around and used by the different processing
    properties
        % Observations - the observation data for all users at all time
        % steps
        %   A UxT matrix containing the full observation data for all the
        %   users at all the time steps
        %   TODO: building this is time intensive.... should not be built
        %   all at once if I remember correctly...
        Observations  % TODO: need to figure out how to differentiate the outputs of the obs by constellation
        
        % SatellitePositions - sat position data for all time steps
        %   An SxT matrixing containing the satellite position information
        %   for all the satellites at all the time steps.
        %   This is precomputed in the initialization phase.
        SatellitePositions
        
        % Tvec - time vector for the simulation
        Tvec
        
        % TriseWRS - rise times for the satellites to the WRSs
        %   Computed only for the WAAS Reference Stations and is a WxR
        %   matrix where W is the number of WRSs and R is the maximum
        %   number of rise times seen by any one of the WRSs
        TriseWRS
        
        % Index - the current simulation index in the time vector
        Index = 1
    end
    
    
    methods
        
        function obj = MAASTSim()
            
            
        end
    end
    
    
    % sim handling functions
    methods
        initialize(obj);
        step(obj);
        run(obj);
        isFinished(obj);
    end
    
    % processing functions
    methods (Access = private)
        % TODO: these probably have outputs
        wmsProcess(obj);
        usrProcess(obj);
        
    end
    
    
end