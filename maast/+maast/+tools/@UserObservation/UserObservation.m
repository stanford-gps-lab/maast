classdef UserObservation < handle
% UserObservation   an container for an observation for a user.
%   An observation ties a User and Satellites together at a specific time
%   and provides data on the relationship between those two group.
%   Allows for later querying of satellites in view, etc.
%
%   obs = maast.tools.UserObservation(user, satPos) creates an observation
%   for a given user and an array of satellite positions (satPos).  satPos
%   must be a SxT matrix of SatellitePosition objects.  The resulting obs
%   array will be a 1xT array of UserObservation objects for each time
%   step.
%
%   TODO: define all the properties here
%
% See Also: maasr.tools.User, maast.tools.SatellitePosition

    % immutable properties
    properties (SetAccess = immutable)
        % User - the user for this observation
        User
        
        % SatellitePositions - array of the satellite positions for this
        % observations
        SatellitePositions
    end
    
    % properties computed based on constructor data
    % NOTE: while these are dependent properties, only limiting it to
    % private set access as these should be calculated when User or
    % SatellitePositions change (right now they can't but haven't decided
    % on the final implementation yet)
    properties (SetAccess = private)
        % LOSecef - the ECEF line of sight vectors
        %   this is a Sx3 matrix containing the LOS unit vector in the ECEF
        %   frame to each of the S satellites as rows
        LOSecef
        
        % LOSenu - the ENU line of sight vectors
        %   this is a Sx3 matrix containing the LOS unit vector in the ENU
        %   frame to each of the S satellites as rows
        LOSenu
        
        % SatellitesInViewMask - mask for which satellites are in view
        %   a logical array of length S indicating which satellite
        %   positions contain a satellite that it is view of the user
        SatellitesInViewMask
        
        % ElevationAngles - the elevation angles to the satellites in view
        % as a column vector of length Sinview
        ElevationAngles
        
        % AzimuthAngles - the azimuth angles to the satellites in view as a
        % column vector of length Sinview
        AzimuthAngles
        
        % NumSatellitesInView - the number of satellites in view
        NumSatellitesInView
        
        % RangeMeasurement - the range measurement to each of the
        % satellites in view as a column vector of length Sinview
        RangeMeasurement
    end
    

    methods

        function obj = UserObservation(user, satPos)

            % handle the empty constructor for vector creation
            if nargin == 0
                return;
            end

            % NOTE: satPos is an SxT matrix which will return a 1xT array
            % of observations
            [~, T] = size(satPos);
            
            
            obj(T) = maast.tools.UserObservation();
            for i = 1:T
                % set the properties
                obj(i).User = user;
                obj(i).SatellitePositions = satPos(:,i);
                
                % run the math to populate all of the properties that are a
                % function of the user and the satellite positions
                obj(i).calculateObservationData();
            end
        end
        
    end

    methods
        % TODO: any methods go here
        [varargout] = getDOPS(obj)
        ipp = getIPP(obj)
    end
    
    methods (Access = protected)
        calculateObservationData(obj)
    end



end