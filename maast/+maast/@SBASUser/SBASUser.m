classdef SBASUser < sgt.User
    % SBASUser  a container for SBAS users, a subclass of sgt.User.
    %
    %   maast.SBASUser(user) creates an SBAS user by adopting the
    %   properties from an already created user (sgt.User). The SBAS user
    %   has methods associated with it required for use in SBAS
    %   calculations.
    %
    %   See Also: sgt.User, sgt.UserGrid, maast.SBASUserGrid
    
    % Constructor
    methods
        function obj = SBASUser(posLLH, varargin)
            
            % Handle different number of arguments
            args = {};
            if (nargin == 1)
                args = {posLLH};
            elseif (nargin > 1)
                args = [{posLLH}, varargin(:)'];
            end
            
            % Use superclass constructor
            obj = obj@sgt.User(args{:});
            
        end
    end
    
    % Static methods here
    methods (Static)
        obj = fromsgtUser(sgtUser);
    end
end
