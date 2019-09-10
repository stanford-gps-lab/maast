classdef SBASUserObservation < sgt.UserObservation
    % SBASUserObservation   a container for an observation from an SBAS
    % user.
    %
    %   maast.SBASUserObservation(sbasUser, satellitePosition, igpData,
    %   varargin) creates an SBAS User Observation.
    %   maast.SBASUserObservation is a subclass of sgt.UserObservation and
    %   contains additional properties and methods needed for maast
    %   calculations. sbasUser must be of type maast.SBASUser.
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
        % SatellitesMonitoredMask - Mask of the satellites that are
        % monitored for use in availability calculations
        SatellitesMonitoredMask
        
        % IPP - Ionospheric Pierce Points in [lat lon alt] [deg deg m]
        IPP
        
        % Sig2Tropo - [m^2] Variance of the line of sight range error due to
        % troposphere
        Sig2Tropo
        
        % Sig2CNMP - [m^2] Variance of the line of sight range error due to code
        % noise and multipath
        Sig2CNMP
        
        % Sig2UDRE - [m^2] Variance of the light of sight range error due
        % to differential range error
        Sig2UDRE
        
        % Sig2FLT - [m^2] Fast/Long-term variance given UDREs and MT28 info
        Sig2FLT
        
        % Sig2UIVE - [m^2] User Ionosphere Vertical Error given IPP and
        % GIVEs
        Sig2UIVE
        
        % Sig2 - [m^2] Combined variance to be used by the users in
        % calculating V/HPL
        Sig2
        
        % VPL - Vertical Protection Level
        VPL
        
        % HPL - Horizontal Protection Level
        HPL
    end
    
    % Constructor
    methods
        function obj = SBASUserObservation(sbasUser, satellitePosition, sbasMasterStation, igpFile, varargin)
            % Handle different number of arguments
            args = {};
            if (nargin == 1)
                args = {sbasUser};
            elseif (nargin > 1)
                args = {sbasUser, satellitePosition};
            end
            
            % Use superclass constructor
            obj = obj@sgt.UserObservation(args{:});
            
            % Handle empty constructor
            if (isempty(obj(1).UserLL))
                return;
            end
            
            % Get varargin inputs
            if nargin > 3
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
                if (isfield(res, 'CustomUDREVariance') == 1) && (~isempty(res.CustomUDREVariance))
                    % Add function to path and trim name
                    indDir = find(res.CustomUDREVariance == '\', 1, 'last');
                    customUDREVariance = res.CustomUDREVariance(indDir+1:end-2);
                    addpath(res.CustomUDREVariance(1:indDir))
                end
                if (isfield(res, 'CustomFLTVariance') == 1) && (~isempty(res.CustomFLTVariance))
                    % Add function to path and trim name
                    indDir = find(res.CustomFLTVariance == '\', 1, 'last');
                    customFLTVariance = res.CustomFLTVariance(indDir+1:end-2);
                    addpath(res.CustomFLTVariance(1:indDir))
                end
                if (isfield(res, 'CustomUIVEVariance') == 1) && (~isempty(res.CustomUIVEVariance))
                    % Add function to path and trim name
                    indDir = find(res.CustomUIVEVariance == '\', 1, 'last');
                    customUIVEVariance = res.CustomUIVEVariance(indDir+1:end-2);
                    addpath(res.CustomUIVEVariance(1:indDir))
                end
                if (isfield(res, 'CustomSig2') == 1) && (~isempty(res.CustomSig2))
                    % Add function to path and trim name
                    indDir = find(res.CustomSig2 == '\', 1, 'last');
                    customSig2 = res.CustomSig2(indDir+1:end-2);
                    addpath(res.CustomSig2(1:indDir))
                end
            end
            
            if (~isa(obj, 'maast.SBASReferenceObservation'))    % Only grab igpFile data for SBAS Users
                % Get IGP Data
                igpData = maast.IGPData(igpFile);
            end
            
            % Number of obj
            numObj = length(obj);
            
            for i = 1:numObj
                % Calculate Ionospheric pierce points
                obj(i).getIPP;
                
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
                
                if (~isa(obj, 'maast.SBASReferenceObservation'))  % Only compute these variances for sbas users
                    % Calculate UDRE variance
                    if (exist('res', 'var') == 1) && (isfield(res, 'CustomUDREVariance') == 1) && (~isempty(res.CustomUDREVariance))
                        feval(customUDREVariance, obj, sbasMasterStation.UDREI(:,i));
                    else
                        obj(i).udreVariance(sbasMasterStation.UDREI(:,i));    % Use built in udre variance
                    end
                    
                    % Calculate FLT variance
                    if (exist('res', 'var') == 1) && (isfield(res, 'CustomFLTVariance') == 1) && (~isempty(res.CustomFLTVariance))
                        feval(customFLTVariance, obj, sbasMasterStation.MT28{:,i});
                    else
                        obj(i).fltVariance(sbasMasterStation.MT28(:,i));    % Use built in flt variance
                    end
                    
                    % Calculate UIVE variance
                    if (exist('res', 'var') == 1) && (isfield(res, 'CustomUIVEVariance') == 1) && (~isempty(res.CustomUIVEVariance))
                        feval(customUIVEVariance, obj, sbasMasterStation.MT28{:,i});
                    else
                        obj(i).uiveVariance(sbasMasterStation.GIVEI(:,i), igpData);    % Use built in givei variance
                    end
                    
                    % SatellitesMonitoredMask
                    obj(i).SatellitesMonitoredMask = (obj(i).SatellitesInViewMask & (obj(i).Sig2UIVE > 0));
                    
                    % Calculate Sig2
                    if (exist('res', 'var') == 1) && (isfield(res, 'CustomSig2') == 1) && (~isempty(res.CustomSig2))
                        feval(customSig2, obj);
                    else
                        obj(i).calculateSig2;   % Use built in Sig2 method
                    end
                    
                    % Calculate SBAS VPL and HPL
                    obj(i).getSBASVHPL;
                end
            end
        end
    end
    
    % Public Methods
    methods
        getIPP(obj)
        [vir, hir] = getSBASVHIR(obj)
    end
    
    % Static Methods
    methods (Static)
        obj = fromsgtUserObservation(userObservation);
    end
    
    % Protected Methods
    methods (Access = protected)
        tropoVariance(obj);
        cnmpVariance(obj);
        udreVariance(obj, udrei);
        fltVariance(obj, mt28);
        uiveVariance(obj, givei, igpData);
        calculateSig2(obj);
        getSBASVHPL(obj);
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

% CustomUDREVariance Function
validCustomUDREVarianceFn = @(x) (exist(x, 'file')==2);
parser.addParameter('CustomUDREVariance', [], validCustomUDREVarianceFn)

% CustomFLTVariance Function
validCustomFLTVarianceFn = @(x) (exist(x, 'file')==2);
parser.addParameter('CustomFLTVariance', [], validCustomFLTVarianceFn)

% CustomUIVEVariance Function
validCustomUIVEVarianceFn = @(x) (exist(x, 'file')==2);
parser.addParameter('CustomUIVEVariance', [], validCustomUIVEVarianceFn)

% CustomSig2 Function
validCustomSig2Fn = @(x) (exist(x, 'file')==2);
parser.addParameter('CustomSig2', [], validCustomSig2Fn)

% Run parser and set results
parser.parse(varargin{:})
res = parser.Results;
end




