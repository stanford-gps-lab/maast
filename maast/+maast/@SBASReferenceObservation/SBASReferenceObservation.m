classdef SBASReferenceObservation < sgt.UserObservation
    % SBASReferenceObservation  a container for an SBAS reference station
    % observation.
    %
    %   maast.SBASReferenceObservation(sbasReferenceStation,
    %   satellitePosition) creates an SBAS reference station observation
    %   using a maast.SBASReferenceStation object and sgt.SatellitePosition
    %   object.
    %
    %   See Also: sgt.UserObservation, maast.SBASReferenceStation,
    %   sgt.SatellitePosition
    
    % Copyright 2019 Stanford University GPS Laboratory
    %   This file is part of MAAST which is released under the MIT License.
    %   See `LICENSE.txt` for full license details. Questions and comments
    %   should be directed to the project at:
    %   https://github.com/stanford-gps-lab/maast
    
    % Public properties
    properties
        % Sig2CNMP - [m^2] Variance of the line of sight range error due to code
        % noise and multipath
        Sig2CNMP
        
        % Sig2Tropo - [m^2] Variance of the line of sight range error due to
        % troposphere
        Sig2Tropo
    end
    
    % Constructor
    methods
        function obj = SBASReferenceObservation(sbasReferenceStation, satellitePosition, varargin)
            % Handle different number of arguments
            args = {};
            if (nargin == 1)
                args = {sbasReferenceStation};
            elseif (nargin >= 2)
                args = {sbasReferenceStation, satellitePosition};
            end
            
            % Use superclass constructor
            obj = obj@sgt.UserObservation(args{:});
            
            % Handle empty constructor
            if (isempty(obj(1).UserLL))
                return;
            end
            
            % Get varargin inputs
            if (nargin > 2)
                res = parsemaastSBASReferenceObservationInput(varargin{:});
                
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
            
            % Calculate tropo variance
            if (exist('res', 'var') == 1) && (isfield(res, 'CustomTropoVariance') == 1) && (~isempty(res.CustomTropoVariance))
                feval(customTropoVariance, obj);
            else
                obj.tropoVariance;   % Use built in tropo variance
            end
            
            % Calculate CNMP variance
            if (exist('res', 'var') == 1) && (isfield(res, 'CustomCNMPVariance') == 1) && (~isempty(res.CustomCNMPVariance))
                feval(customCNMPVariance, obj);
            else
                obj.cnmpVariance;    % Use built in cnmp variance
            end
        end
    end
    
    % Static Methods
    methods (Static)
        obj = fromSBASUserObservation(sbasUserObservation);
    end
    
    % Protected Methods
    methods (Access = protected)
        cnmpVariance(obj);
    end
end

function res = parsemaastSBASReferenceObservationInput(varargin)
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