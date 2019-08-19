classdef SBASUserObservation < sgt.UserObservation
    % SBASUserObservation   a container for an observation from an SBAS
    % user.
    %
    %   maast.SBASUserObservation(sbasUser, satellitePosition) creates an
    %   SBAS User Observation. maast.SBASUserObservation is a subclass of
    %   sgt.UserObservation and contains additional properties and methods
    %   needed for maast calculations. sbasUser must be of type
    %   maast.SBASUser.
    %
    %   See Also: sgt.UserObservation,
    %   maast.SBASUserObservation.createSBASUserObservation,
    %   maast.SBASUser, maast.SBASUser.fromsgtUser
    
    % Copyright 2019 Stanford University GPS Laboratory
    %   This file is part of MAAST which is released under the MIT License.
    %   See `LICENSE.txt` for full license details. Questions and comments
    %   should be directed to the project at:
    %   https://github.com/stanford-gps-lab/maast
    
    % Public Properties
    properties (SetAccess = public)
        % VPL - Vertical Protection Level
        VPL
        
        % HPL - Horizontal Protection Level
        HPL
    end
    
    methods
        function obj = SBASUserObservation(sbasUser, satellitePosition)
            % Handle different number of arguments
            args = {};
            if (nargin == 1)
                args = {sbasUser};
            elseif (nargin == 2)
                args = {sbasUser, satellitePosition};
            end
            
            % Use superclass constructor
            obj = obj@sgt.UserObservation(args{:});
            
        end
    end
    
    % Static Methods
    methods (Static)
        obj = fromsgtUserObservation(userObservation);
    end
    
end