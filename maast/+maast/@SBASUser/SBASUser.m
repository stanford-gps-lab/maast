classdef SBASUser < sgt.User
    % SBASUser  a container for SBAS users, a subclass of sgt.User.
    %
    %   maast.SBASUser(posLLH, varargin) creates an SBAS user at position
    %   posLLH. If posLLH is an Nx3 matrix, then N SBASUser objects will be
    %   created where each column in posLLH represents [lat lon alt] in
    %   [deg deg m]. maast.SBASUser is a subclass of sgt.User and so has
    %   access to all public and protected methods defined for sgt.User.
    %
    %   varargin:
    %   -----
    %   ID - the ID of the user
    %   -----
    %   PolygonFile - specifies the name of a polyfile that bounds a
    %   geographic region. See sgt.tools.generatePolygon
    %   -----
    %   ElevationMask - Elevation mask of users [rad]. Default 5 degrees.
    %
    %   See Also: sgt.User, sgt.UserGrid, maast.SBASUserGrid
    
    % Copyright 2019 Stanford University GPS Laboratory
    %   This file is part of MAAST which is released under the MIT License.
    %   See `LICENSE.txt` for full license details. Questions and comments
    %   should be directed to the project at:
    %   https://github.com/stanford-gps-lab/maast
    
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
