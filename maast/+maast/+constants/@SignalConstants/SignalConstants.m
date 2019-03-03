classdef SignalConstants
% SignalConstants   a set of constant values related to GNSS signals.
%
%   References: 	Parkinson, et. al., GPS Theory and Applications, V. 1,
%		AIAA, 1996.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details.
%   Questions and comments should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast     
    
    properties (Constant)
        % C - speed of line ([m/s])
        C = 299792458.0;
        
        % L1 - L1 frequency ([Hz])
        L1 = 1575.42e6;
        
        % L2 - L2 frequency ([Hz])
        L2 = 1227.60e6;
        
        % L5 - L5 frequency ([Hz])
        L5 = 1176.45e6;
        
        % TODO: this is a little obnoxious to do it this way...
        
        % L1lambda - L1 wavelength ([m])
        L1lambda = maast.constants.SignalConstants.C / maast.constants.SignalConstants.L1;
        
        % L2lambda - L2 wavelength ([m])
        L2lambda = maast.constants.SignalConstants.C / maast.constants.SignalConstants.L2;
        
        % L5lambda - L5 wavelength ([m])
        L5lambda = maast.constants.SignalConstants.C / maast.constants.SignalConstants.L5;
        
        % TODO: not sure what this parameter is
        Ktec = maast.constants.SignalConstants.L1^2*maast.constants.SignalConstants.L2^2 ...
            / (maast.constants.SignalConstants.L1^2 + maast.constants.SignalConstants.L2^2) ...
            / 40.3;
    end
    
end