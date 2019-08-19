classdef SBASUserObservation < sgt.UserObservation
    % SBASUserObservation   a container for an observation from an SBAS
    % user.
    %
    %   maast.SBASUserObservation(sbasUser, satellitePosition) creates an
    %   SBAS User Observation. maast.SBASUserObservation is a subclass of
    %   sgt.UserObservation and contains additional properties and methods
    %   needed for maast calculations.
    %
    %   See Also: sgt.UserObservation,
    %   maast.SBASUserObservation.createSBASUserObservation, maast.SBASUser
    
    % Copyright 2019 Stanford University GPS Laboratory
    %   This file is part of MAAST which is released under the MIT License.
    %   See `LICENSE.txt` for full license details. Questions and comments
    %   should be directed to the project at:
    %   https://github.com/stanford-gps-lab/maast
    
    methods
        function obj = SBASUserObservation(sbasUser, satellitePosition)
            
            % Handle different number of arguments
            args = {};
            if (nargin == 2)
                args = {sbasUser, satellitePosition}; 
            end
            
            % Use superclass constructor
            obj = obj@sgt.UserObservation(args{:});
            
            if (~isa(sbasUser, 'maast.SBASUser'))
               error('Input user must be of type maast.SBASUser')
            end
        end
    end
    
    
    
    
    
    
    
end