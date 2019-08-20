classdef SBASReferenceObservation < maast.SBASUserObservation
    % SBASReferenceObservation  a container for an SBAS reference station
    % observation.
    %
    %   maast.SBASReferenceObservation(sbasReferenceStation,
    %   satellitePosition) creates an SBAS reference station observation
    %   using a maast.SBASReferenceStation object and sgt.SatellitePosition
    %   object.
    %
    %   See Also: sgt.UserObservation, maast.SBASUserObservation
    
    % Constructor
    methods
        function obj = SBASReferenceObservation(sbasReferenceStation, satellitePosition)
            % Handle different number of arguments
            args = {};
            if (nargin == 1)
                args = {sbasReferenceStation};
            elseif (nargin > 1)
                args = {sbasReferenceStation, satellitePosition};
            end
            
            % Use superclass constructor
            obj = obj@maast.SBASUserObservation(args{:});
            
        end
    end
    
    % Public Methods
    methods (Access = protected)
        sig2Tropo = tropoVariance(obj);
        sig2CNMP = cnmpVariance(obj);
    end
    
    % Static Methods
    methods
       obj = fromSBASUserObservation(sbasUserObservation); 
    end
    
end