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
    
    % Copyright 2019 Stanford University GPS Laboratory
    %   This file is part of MAAST which is released under the MIT License.
    %   See `LICENSE.txt` for full license details. Questions and comments
    %   should be directed to the project at:
    %   https://github.com/stanford-gps-lab/maast
    
    % Constructor
    methods
        function obj = SBASReferenceObservation(sbasReferenceStation, satellitePosition, varargin)
            % Handle different number of arguments
            args = {};
            if (nargin == 1)
                args = {sbasReferenceStation};
            elseif (nargin > 1)
                args = [{sbasReferenceStation, satellitePosition}, varargin{:}'];
            end
            
            % Use superclass constructor
            obj = obj@maast.SBASUserObservation(args{:});
        end
    end
    
    % Static Methods
    methods
        obj = fromSBASUserObservation(sbasUserObservation);
    end
    
    % Protected Methods
    methods (Access = protected)
       cnmpVariance(obj); 
    end
end