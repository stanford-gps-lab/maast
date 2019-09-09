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
    end
    
end