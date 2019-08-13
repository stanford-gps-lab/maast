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
        function obj = SBASUser(user)
            
            % Handle the empty constructor
            if nargin < 1
                obj.PositionLLH = zeros(3,1);
                obj.PositionECEF = zeros(3,1);
                obj.ECEF2ENU = zeros(3,3);
                return;
            end
            
            % Count number of input users
            numUsers = length(user);
            
            % Assign properties from user
            for i = 1:numUsers
                obj(i).ID = user(i).ID;
                obj(i).PositionLLH = user(i).PositionLLH;
                obj(i).PositionECEF = user(i).PositionECEF;
                obj(i).InBound = user(i).InBound;
                obj(i).ElevationMask = user(i).ElevationMask;
            end
            
            
        end
    end
    
    
    
    
    
    
    
    
    
end