classdef SBASMasterStation < matlab.mixin.Copyable
    % SBASMasterStation     a container for an SBASMasterStation object.
    %
    %   maast.SBASMasterStation(sbasReferenceObservation) creates an 
    %   SBASMasterStation object which digests the information coming in 
    %   from the SBAS Reference Stations and outputs information required
    %   by SBAS Users.
    
    % Public properties
    properties
        %UDRE - User Differential Range Error for each satellite at each
        %time. Is an SxT matrix for S satellites and T times.
        UDRE
    end
    
    % Constructor
    methods
        function obj = SBASMasterStation(sbasReferenceObservation) 
            
        end
    end
    
    
    
    
end