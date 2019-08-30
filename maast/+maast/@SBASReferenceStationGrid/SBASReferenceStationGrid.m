classdef SBASReferenceStationGrid < sgt.UserGrid
    % SBASReferenceStationGrid  a container for a grid of SBAS Reference
    %   Stations.
    %
    %   maast.SBASReferenceStationGrid(posLLH, varargin) creates an
    %   SBASReferenceStationGrid object with SBAS reference station
    %   positions denoted in posLLH. Similar to sgt.UserGrid, posLLH must
    %   be an Nx3 matrix for N users where each column is [lat lon alt] in 
    %   [deg deg m]. maast.SBASReferenceStationGrid is a subclass of
    %   sgt.UserGrid and so has access to all public and protected methods 
    %   defined for sgt.UserGrid.
    %
    %   varargin:
    %   -----
    %   'GridName' - A character string that denotes the name of the user
    %   grid.
    %   -----
    %   'PolygonFile' - A polygon file that contains a list of [lat, lon]
    %   positions that define a geographic region. This file will be
    %   converted into a polyshape object and will be saved in the property
    %   'Polygon'.
    %
    %   See Also: sgt.UserGrid, sgt.UserGrid.createUserGrid,
    %   maast.SBASReferenceStation
    
    % Copyright 2019 Stanford University GPS Laboratory
    %   This file is part of MAAST which is released under the MIT License.
    %   See `LICENSE.txt` for full license details. Questions and comments
    %   should be directed to the project at:
    %   https://github.com/stanford-gps-lab/maast
    
    methods
        function obj = SBASReferenceStationGrid(posLLH, varargin)
            
            % Handle different number of arguments
            args = {};
            if (nargin == 1)
                args = {posLLH};
            elseif (nargin > 1)
                args = [{posLLH}, varargin(:)'];
            end
            
            % Use superclass constructor
            obj = obj@sgt.UserGrid(args{:});
            
            if (~isempty(obj.Users))
                % Make Users SBAS Users
                obj.Users = maast.SBASReferenceStation.fromsgtUser(obj.Users);
            end
            
        end
    end
    
    % Static Methods
    methods (Static)
        obj = fromsgtUserGrid(sgtUserGrid);
        obj = createReferenceStationGrid(varargin);
    end    
end