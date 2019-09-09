classdef SBASMasterStation < matlab.mixin.Copyable
    % SBASMasterStation     a container for an SBASMasterStation object.
    %
    %   maast.SBASMasterStation(sbasReferenceObservation) creates an
    %   SBASMasterStation object which digests the information coming in
    %   from the SBAS Reference Stations and outputs information to be sent
    %   to SBAS Users.
    
    % Copyright 2019 Stanford University GPS Laboratory
    %   This file is part of MAAST which is released under the MIT License.
    %   See `LICENSE.txt` for full license details. Questions and comments
    %   should be directed to the project at:
    %   https://github.com/stanford-gps-lab/maast
    
    % Public properties
    properties
        % NumSats - number of satellites observed.
        NumSats
        
        % UDRE - User Differential Range Error Indicator for each satellite at each
        %time. Is an SxT matrix for S satellites and T times.
        UDREI
        
        % MT28 - Covariance matrix created for MT28 message. Is a cell
        %matrix of size SxT for S satellites and T times where each cell is
        %a 4x4 covariance matrix.
        MT28
        
        % IGP - Ionospheric Grid Points object. See maast.IGPData.
        IGPData
        
        % GIVEI - Grid ionospheric vertical error Indicator for each
        % ionospheric grid point
        GIVEI
    end
    
    % Constructor
    methods
        function obj = SBASMasterStation(sbasReferenceObservation, igpFile, varargin)
            % Handle empty constructor
            if (nargin < 1)
                return;
            end
            
            % Number of sbasReferenceObservations
            [~, timeLength] = size(sbasReferenceObservation);
            numSats = length(sbasReferenceObservation(1).SatellitePRN); obj.NumSats = numSats;
            
            % Get varargin inputs
            if (nargin > 1)
                res = parsemaastSBASMasterStationInput(varargin{:});
                
                % Add custom functions to path
                if (isfield(res, 'CustomUDREI') == 1) && (~isempty(res.CustomUDREI))
                    % Add function to path and trim name
                    indDir = find(res.CustomUDREI == '\', 1, 'last');
                    customUDREI = res.CustomUDREI(indDir+1:end-2);
                    addpath(res.CustomUDREI(1:indDir))
                end
                if (isfield(res, 'CustomMT28') == 1) && (~isempty(res.CustomMT28))
                    % Add function to path and trim name
                    indDir = find(res.CustomMT28 == '\', 1, 'last');
                    customMT28 = res.CustomMT28(indDir+1:end-2);
                    addpath(res.CustomMT28(1:indDir))
                end
            end

            % Calculate UDRE
            if (exist('res', 'var') == 1) && (isfield(res, 'CustomUDREI') == 1) && (~isempty(res.CustomUDREI))
                feval(customUDREI, obj);
            else
                obj.UDREI = 11*ones(numSats, timeLength);  % Assume constant UDREI of 11 for GPS Satellites
            end
            % Calculate MT28
            if (exist('res', 'var') == 1) && (isfield(res, 'CustomMT28') == 1) && (~isempty(res.CustomMT28))
                feval(customMT28, obj);
            else
                mt28 = eye(4); mt28(4,4) = 0; mt28 = {mt28};
                obj.MT28 = repmat(mt28, [numSats, timeLength]);
            end
            
            % Create IGP Data
            obj.IGPData = maast.IGPData(igpFile);
        end
    end
end

function res = parsemaastSBASMasterStationInput(varargin)
% Initialize parser
parser = inputParser;

% CustomTropoVariance Function
validUDREIFn = @(x) (exist(x, 'file')==2);
parser.addParameter('CustomUDREI', [], validUDREIFn)

% CustomTropoVariance Function
validMT28Fn = @(x) (exist(x, 'file')==2);
parser.addParameter('CustomMT28', [], validMT28Fn)

% Run parser and set results
parser.parse(varargin{:})
res = parser.Results;
end