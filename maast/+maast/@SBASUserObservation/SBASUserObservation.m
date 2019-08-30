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
    properties (Access = public)
        % Sig2Tropo - [m^2] Variance of the line of sight range due to
        % troposphere
        Sig2Tropo
        
        % Sig2CNMP - [m^2] Variance of the line of sight range due to code
        % noise and multipath
        Sig2CNMP
        
        % VPL - Vertical Protection Level
        VPL
        
        % HPL - Horizontal Protection Level
        HPL
    end
    
    methods
        function obj = SBASUserObservation(sbasUser, satellitePosition, varargin)
            % Handle different number of arguments
            args = {};
            if (nargin == 1)
                args = {sbasUser};
            elseif (nargin >= 2)
                args = {sbasUser, satellitePosition};
            end
            
            % Use superclass constructor
            obj = obj@sgt.UserObservation(args{:});
            
            % Get varargin inputs
            if nargin > 2
                res = parsemaastSBASUserObservationInput(varargin{:});
                
                % Add custom functions to path
                if (isfield(res, 'CustomTropoVariance') == 1) && (~isempty(res.CustomTropoVariance))
                   % Add function to path and trim name
                   indDir = find(res.CustomTropoVariance == '\', 1, 'last');
                   customTropoVariance = res.CustomTropoVariance(indDir+1:end-2);
                   addpath(res.CustomTropoVariance(1:indDir))     
                end
                if (isfield(res, 'CustomCNMPVariance') == 1) && (~isempty(res.CustomCNMPVariance))
                   % Add function to path and trim name
                   indDir = find(res.CustomCNMPVariance == '\', 1, 'last');
                   customCNMPVariance = res.CustomCNMPVariance(indDir+1:end-2);
                   addpath(res.CustomCNMPVariance(1:indDir))     
                end
            end
            
            % Number of obj
            numObj = length(obj);
            
            for i = 1:numObj
                % Calculate tropo variance
                if (exist('res', 'var') == 1) && (isfield(res, 'CustomTropoVariance') == 1) && (~isempty(res.CustomTropoVariance))
                    feval(customTropoVariance, obj);
                else
                    obj(i).tropoVariance;   % Use built in tropo variance
                end
                
                % Calculate CNMP variance
                if (exist('res', 'var') == 1) && (isfield(res, 'CustomCNMPVariance') == 1) && (~isempty(res.CustomCNMPVariance))
                    feval(customCNMPVariance, obj);
                else
                    obj(i).cnmpVariance;    % Use built in cnmp variance
                end
                
                % Calculate SBAS V/HPL
                obj(i).getSBASVPL;
                obj(i).getSBASHPL;
            end
        end
    end
    
    % Static Methods
    methods (Static)
        obj = fromsgtUserObservation(userObservation);
    end
    
    % Protected Methods
    methods (Access = protected)
        tropoVariance(obj);
        cnmpVariance(obj);
        getSBASVPL(obj);
        getSBASHPL(obj);
    end
end

function res = parsemaastSBASUserObservationInput(varargin)
% Initialize parser
parser = inputParser;

% CustomTropoVariance Function
validCustomTropoVarianceFn = @(x) (exist(x, 'file')==2);
parser.addParameter('CustomTropoVariance', [], validCustomTropoVarianceFn)

% CustomCNMPVariance Function
validCustomCNMPVarianceFn = @(x) (exist(x, 'file')==2);
parser.addParameter('CustomCNMPVariance', [], validCustomCNMPVarianceFn)

% Run parser and set results
parser.parse(varargin{:})
res = parser.Results;
end




