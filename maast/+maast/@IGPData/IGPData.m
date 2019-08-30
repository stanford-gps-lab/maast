classdef IGPData < matlab.mixin.Copyable
    % IGPData    a container for information pertaining to the ionospheric
    %    grid points (IGP).
    %
    %    maast.IGPData(igpFile) creates an IGPData object from an igpFile.
    
    % Copyright 2019 Stanford University GPS Laboratory
    %   This file is part of MAAST which is released under the MIT License.
    %   See `LICENSE.txt` for full license details. Questions and comments
    %   should be directed to the project at:
    %   https://github.com/stanford-gps-lab/maast
    
    % Public Properties
    properties
        % Band - Ionospheric Grid Point band.
        Band
        
        % ID - ID of the ionospheric grid points.
        ID
        
        % LL - Latitude and Longitude of the IGP.
        LL
        
        % Workset
        Workset
        
        % Ehat - East unit vector for each IGP
        Ehat
        
        % Nhat - North unit vector for each IGP
        Nhat
        
        % MagLat - Magnetic Latitude for each IGP
        MagLat
        
        % CornerDen
        CornerDen
    end
    
    % Constructor
    methods
        function obj = IGPData(igpFile)
            %  Handle empty constructor
            if (nargin < 1)
                return;
            end
            
            % Use old maast function for now. Will update in the future.
            obj.init_igpdata(igpFile)            
        end
    end
    
    % Private method using old maast code
    methods (Access = private)
        initIGPData(obj, igpFile)
    end
end