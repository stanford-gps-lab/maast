classdef SBASReferenceStation < sgt.User
    % SBASReferenceStation  a container for an SBAS reference station.
    %
    %   maast.SBASReferenceStation(posLLH, varargin) creates an object of
    %   type maast.SBASReferenceStation located at positions denoted in
    %   posLLH [deg deg m].
    %
    %   varargin:
    %   -----
    %
    %   See Also: sgt.User, sgt.UserGrid.createUserGrid,
    %   maast.SBASUserGrid.createUserGrid
    
    % Constructor
    methods
        function obj = SBASReferenceStation(posLLH, varargin)
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
    
    % Static Methods
    methods (Static)
        obj = fromsgtUser(sgtUser);
    end
end