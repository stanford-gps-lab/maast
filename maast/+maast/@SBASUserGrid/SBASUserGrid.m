classdef SBASUserGrid < sgt.UserGrid
    % SBASUserGrid  a container for a grid of SBAS users.
    %
    %   maast.SBASUserGrid(posLLH, varargin) creates an SBASUserGrid object
    %   with SBAS user positions denoted in posLLH. Similar to
    %   sgt.UserGrid, posLLH must be an Nx3 matrix for N users where each
    %   column is [lat lon alt] in [deg deg m]. maast.SBASUserGrid is a
    %   subclass of sgt.UserGrid and so has access to all public and
    %   protected methods defined for sgt.UserGrid.
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
    %   See Also: sgt.UserGrid, sgt.UserGrid.createUserGrid, maast.SBASUser
    
    
    
    
    
    
end