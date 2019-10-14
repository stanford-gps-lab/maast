classdef WAASMOPSConstants < matlab.mixin.Copyable
    % WAASMOPSConstants     a container for constants specified in the WAAS
    % MOPS
    %
    % This code was directly copied from the original maast file
    % 'init_cnmp_mops.m'. Context for these values will be added in the
    % future.
    
    % Copyright 2019 Stanford University GPS Laboratory
    %   This file is part of MAAST which is released under the MIT License.
    %   See `LICENSE.txt` for full license details. Questions and comments
    %   should be directed to the project at:
    %   https://github.com/stanford-gps-lab/maast
    
    % Constant properties
    properties (Constant)
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
        
        % CCovariance - MT10 parameter for MT28
        CCovariance = 0;
        
        % MinGEOPRN - Minimum GEO PRN
        MinGEOPRN = 120;
        
        % KVPA - K value for VPL calculations
        KVPA = 5.33;
        
        % KHPA - K value for precision approach HPL calculations
        KHPA = 6.0;
        
        % KHNPA - K value for non-precision approach HPL calculations
        KHNPA = 6.18;
        
        % VALLPV200 - Vertical Alert Limit for LPV200 approaches
        VALLPV200 = 35;
        
        % HALLPV200 - Horizontal Alert Limit fo LPV200 approaches
        HALLPV200 = 40;
    end
    
    % Properties set in constructor
    properties
        % UDRE - UDRE values given in WAAS MOPS
        UDRE
        
        % Sig2UDRE - Variance values for UDRE given in WAAS MOPS
        Sig2UDRE
        
        % Sig2GIVE - Variance values for GIVE given in WAAS MOPS
        Sig2GIVE
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
            
            % Sig2GIVE
            obj.Sig2GIVE = [0.0084 0.0333 0.0749 0.1331 0.2079 0.2994 0.4075 ...
                0.5322 0.6735 0.8315 1.1974 1.8709 3.3260 20.787 ...
                187.0826 obj.NotMonitored];   %GIVE variance values
        end
    end
    
end