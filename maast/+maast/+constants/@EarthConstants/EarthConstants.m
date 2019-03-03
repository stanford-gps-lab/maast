classdef EarthConstants
%*************************************************************************
%*     Copyright c 2019 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This file is part of MAAST which is releaded under the MIT        *
%*      License.  See `LICENSE.TXT` for full license details.            *
%*                                                                       *
%*     Questions and comments should be directed to:                     *
%*     https://github.com/stanford-gps-lab/maast                         *
%*************************************************************************
% EarthConstants 	a set of constant values related to the Earth.
%
%   References: 	Parkinson, et. al., GPS Theory and Applications, V. 1,
%		AIAA, 1996.


	properties (Constant)

        % mu - Earth's gravitational parameter ([m^3/s^2])
        %   mu = G*M_earth
        mu = 3.986005e14;
        
        % omega - Earth's angular velocity ([rad/s])
        omega = 7292115.1467e-11;
        
        % R - Earth's semimajor axis ([m])
		R = 6378137;
        
        % B - Earth's semiminor axis ([m])
        B = 6356752.314;
        
        % f - Earth's flattening constant
        f = 1.0/298.257223563;
		
        % TODO: add other constants as needed
        
        % SiderealDay - length of a sidereal day ([s])
        SiderealDay = 2*pi / maast.constants.EarthConstants.omega;
        
        % Rgeo - radius of a geostationary orbit ([m])
        Rgeo = 42241095.8;
        
        % Hgeo - height of a geostationary orbit ([m])
        Hgeo = maast.constants.EarthConstants.Rgeo - maast.constants.EarthConstants.R;
        
        % Hiono - altitude of the ionosphere ([m])
        Hiono = 350000;
        
        % Riono - approximate radius of the ionosphere ([m])
        Riono = maast.constants.EarthConstants.R + maast.constants.EarthConstants.Hiono;
        
        % IonoGamma - ionospheric constant for L1/L2
        Iono = (maast.constants.SignalConstants.L1/maast.constants.SignalConstants.L2)^2;
	end



end