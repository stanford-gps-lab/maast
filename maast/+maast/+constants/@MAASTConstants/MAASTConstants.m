classdef MAASTConstants < matlab.mixin.Copyable
    % MAASTConstants     a container for constants specific to MAAST.
    %    Grab a MAASTConstants object by using var =
    %    maast.constants.MAASTConstants.
    
    properties
        % L1Frequency - [Hz] L1 center frequency
        L1Frequency = 1575.42e6;
        
        % L2Frequency - [Hz] L2 center frequency
        L2Frequency = 1227.60e6;
        
        % IonoAlt - [m] Altitude of the ionospheric grid points
        IonoAlt = 350000;
        
        % IonoRadius - [m] Radius of the Ionosphere
        IonoRadius
    end
    
    % Constructor
    methods
        function obj = MAASTConstants()
            % Import earth constants
            earthConstants = sgt.constants.EarthConstants;
            
            % Calculate Ionoradius
            obj.IonoRadius = obj.IonoAlt + earthConstants.R;
        end
    end
end