classdef Satellite < matlab.mixin.Copyable
% Satellite     an almanac based representation of a satellite in orbit.
%   TODO: more detailed description as needed
%
%   s = maast.tools.Satellite(prn, e, toa, inc, rora, sqrta, raan, w,
%   m0, af0, af1) create a satellite, or a list of satellites
%   from the specified almanac parameters.  Each parameter can
%   either be a scalar or a column vector of length N for
%   creating a list of N satellites.  If creating an array of
%   satellites, all the inputs must be column vectors of the
%   same length.
%
%   TODO: add documentation for the static constructors for creating a
%   satellite from the alm matrix or from a yuma file
%
%   See Also: maast.tools.Satellite.fromAlmMatrix,
%   maast.tools.Satellite.fromYuma

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details.
%   Questions and comments should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

    % the almanac properties -> can only be set in the constructor
    % TODO: decide if want these to actually be immutable or just
    % private...
    % TODO: add more description to the parameters as needed
    properties(SetAccess = immutable)
        % PRN - the satellite PRN code
        PRN
        
        % Eccentricity - the eccentricity
        Eccentricity
        
        % TOA - time of applicability for these parameters in [sec]
        TOA
        
        % Inclination - inclination of the orbit in [rad]
        Inclination
        
        % RateOfRightAscension - the rate of right ascension (Omega dot) in
        % [rad/sec]
        RateOfRightAscension
        
        % SqrtA - square root of the semi-major axis (a) in [m^(1/2)]
        SqrtA
        
        % RightAscension - right ascension at the time of applicability
        % (Omega_0) in [rad]
        RightAscension
        
        % ArgumentOfPerigee - argume of perigee (omega) in [rad]
        ArgumentOfPerigee
        
        % MeanAnomaly - the mean anomaly (M) in [rad]
        MeanAnomaly
        
        % AF0 - clock bias [sec]
        AF0
        
        % AF1 - clock drift [sec/sec]
        AF1
    end

    % the derived properties
    properties (Dependent, SetAccess = private)
        % Period - the orbital period of the satellite in [sec]
        Period
        
        % the mean motion of the satellite in [1/sec]
        n
        % TODO: define any additional dependent properties for a satellite
        % here
    end

    methods

        function obj = Satellite(prn, e, toa, inc, rora, sqrta, raan, w, m0, af0, af1)
            
            % need to allow for an empty constructor for list creation
            if nargin == 0
                obj.PRN = NaN;
                return;
            end
            
            % make sure there are enough inputs
            if nargin < 11
                error('not enough input parameters');
            end

            % TODO: need to do much more formal checking on the inputs,
            % right now assuming that everything is properly entered...
            % (bad assumption)
            Nsats = length(prn);

            % create a list of satellites given the number of satellites
            obj(Nsats) = maast.tools.Satellite();

            % convert each row of information to satellite data
            for i = 1:Nsats
                obj(i).PRN = prn(i);
                obj(i).Eccentricity = e(i);
                obj(i).TOA = toa(i);
                obj(i).Inclination = inc(i);
                obj(i).RateOfRightAscension = rora(i);
                obj(i).SqrtA = sqrta(i);
                obj(i).RightAscension = raan(i);
                obj(i).ArgumentOfPerigee = w(i);
                obj(i).MeanAnomaly = m0(i);
                obj(i).AF0 = af0(i);
                obj(i).AF1 = af1(i);
            end
        end

        % define the dependent property 
        
        function period = get.Period(obj)
            % TODO: implement this
            period = NaN;
        end

        function n = get.n(obj)
            % TODO: implement this
            n = NaN;
        end

    end

    % non-static method signatures
    methods
        % NOTE: this only computes the position, not the velocity which is
        % also needed
        pos = getPosition(obj, t)
        % TODO: add a plotting function
        % TODO: add a function to get position in different frames (e.g.
        % LLA or ECI)
    end

    % static methods
    methods (Static)
        s = fromAlmMatrix(alm)
        s = fromYuma(filename)
    end

end