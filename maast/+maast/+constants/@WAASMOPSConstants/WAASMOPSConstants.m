classdef WAASMOPSConstants < matlab.mixin.Copyable
    % WAASMOPSConstants     a container for constants specified in the WAAS
    % MOPS
    %
    % This code was directly copied from the original maast file
    % 'init_cnmp_mops.m'. Context for these values will be added in the
    % future.
    
    properties
        %CNMPA0 - [m]
        CNMPA0 = 0.13;
        
        % CNMPA1 - [m]
        CNMPA1 = 0.53;
        
        % CNMPTheta0 - [rad]
        CNMPTheta0 = 10*pi/180;
        
        % CNMPB0 - [m]
        CNMPB0 = 0.04;
        
        % CNMPB1 - [m]
        CNMPB1 = 0.02;
        
        % CNMPPhi0 - [rad]
        CNMPPhi0 = 5*pi/180;
        
        % CNMPPhi1 - [rad]
        CNMPPhi1 = 85*pi/180;
        
        % NotInMask - flag to indicate not in current mask
        NotInMask = -12;
        
        % NotMonitored - flag to indicate sat or igp is not monitored
        NotMonitored = -16;
        
        % DoNotUse - flag to indicate sat or igp is not safe
        DoNotUse = -18;
        
        % UDRE - UDRE values given in WAAS MOPS
        UDRE
        
        % Sig2UDRE - Variance values for UDRE given in WAAS MOPS
        Sig2UDRE
    end
    
    % Constructor
    methods
        function obj = WAASMOPSConstants()
            % UDRE
            obj.UDRE = [0.75 1.00 1.25 1.75 2.25 3.0 3.75 4.5 5.25 6.0 7.5 ...
                15.0 50.0 150.0 obj.NotMonitored obj.DoNotUse];
            
            % Sig2UDRE
            obj.Sig2UDRE = [0.0520 0.0924 0.1444 0.2830 0.4678 0.8315 1.2992 ...
                      1.8709 2.5465 3.3260 5.1968 20.787 230.9661 ...
                      2078.695 obj.NotMonitored obj.DoNotUse];
        end
    end
    
end