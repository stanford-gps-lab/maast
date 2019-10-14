classdef MAASTConstants < matlab.mixin.Copyable
    % MAASTConstants     a container for constants specific to MAAST.
    %    Grab a MAASTConstants object by using var =
    %    maast.constants.MAASTConstants.
    
    % Copyright 2019 Stanford University GPS Laboratory
    %   This file is part of MAAST which is released under the MIT License.
    %   See `LICENSE.txt` for full license details. Questions and comments
    %   should be directed to the project at:
    %   https://github.com/stanford-gps-lab/maast
    
    % Constant Properties
    properties (Constant)
        % L1Frequency - [Hz] L1 center frequency
        L1Frequency = 1575.42e6;
        
        % L2Frequency - [Hz] L2 center frequency
        L2Frequency = 1227.60e6;
        
        % IonoAlt - [m] Altitude of the ionospheric grid points
        IonoAlt = 350000;
    end
    
    % Properties set in constructor
    properties
        % IonoRadius - [m] Radius of the Ionosphere
        IonoRadius
    end
    
    % Constructor
    methods
        function obj = MAASTConstants()
            % Calculate Ionoradius
            obj.IonoRadius = obj.IonoAlt + sgt.constants.EarthConstants.R;
        end
    end
end