classdef User < handle
% User 	a model for a user at a specific location.
%   A user is a container for a fixed location from which observations or
%   frame transformations can take place.
%   TODO: more detailed description as needed.
%
%   user = maast.tools.User(posllh) creates user(s) at the (lat, lon, alt)
%   positions specified in posllh.  posllh should be an Nx3 matrix for the
%   creation of N users with each row containing the (lat, lon, alt) of the
%   user in [deg, deg, m].
%
% Examples:
%   TODO: add examples
%

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details.
%   Questions and comments should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

	properties
        % ID - the ID of the user
        ID

        % PositionLLH - LLH position of the user on the world
        %   latitude and longitude are defined in degrees
        PositionLLH
        
        % Position - ECEF position of the user on the world in [m]
		Position

        % ECEF2ENU - the rotation matrix from ECEF to ENU for this user
		ECEF2ENU

        % ElevationMask - elevation mask for which to consider satellites
        % in view in [rad]
        ElevationMask = 5 * pi/180
        
        % InBound - true if the user is within a specified polygon
        %   if the user was created with a polygon bound, this will be
        %   flagged true if the user is within the bound and false
        %   otherwise.  If no polygon bound was provided InBound will
        %   default to false
        InBound = false
	end

	methods

		function obj = User(posllh, varargin)
            
            % if no arguments, default to all zero
            if nargin == 0
                obj.PositionLLH = zeros(3,1);
                obj.Position = zeros(3,1);
                obj.ECEF2ENU = zeros(3,3);
                return;
            end

            parser = inputParser;
            parser.addParameter('ID', []);
            parser.addParameter('Polygon', []);
            parser.addParameter('ElevationMask', 5*pi/180);
            parser.parse(varargin{:});
            res = parser.Results;
            
            % NOTES: posllh right now has to be a matrix with N rows (for N
            % sites) where each row contains [lat lon alt] in [deg, deg, m]
            % for each of the sites.

            % get the number of sites
            [Nsites, ~] = size(posllh);
            obj(Nsites) = maast.tools.User();

            latRad = posllh(:,1)*pi/180;
            lonRad = posllh(:,2)*pi/180;

            % bulk convert the LLH positions to ECEF positions
%             posECEF = maast.constants.EarthConstants.R*[
% 			    cos(latRad).*cos(lonRad), ...
% 			    cos(latRad).*sin(lonRad), ...
% 			    sin(latRad)];
            posECEF = maast.tools.llh2ecef(posllh);

            % default to a sequential id set if no ID information passed
            ids = res.ID;
            if isempty(ids)
                ids = 1:Nsites;
            end
            
            % check which points are within the polygon
            inBnds = false(Nsites,1);
            if ~isempty(res.Polygon)
                poly = res.Polygon;
                polycheck = inpolygon(posllh(:,2), posllh(:,1), poly(:,2), poly(:,1));
                inBnds = (polycheck > 0);  % inpolygon returns 0.5 in some versions of MATLAB
            end
            
            % expand the elevation mask if only a single value
            elMask = res.ElevationMask;
            if length(elMask) == 1
                elMask = elMask * ones(Nsites, 1);
            end
            
            % create the user object for each site
            for i = 1:Nsites
                % directly just save the LLH and the ECEF positions to the
                % user object
                obj(i).ID = ids(i);
                obj(i).PositionLLH = posllh(i,:)';
                obj(i).Position = posECEF(i,:)';
                obj(i).InBound = inBnds(i);
                obj(i).ElevationMask = elMask(i);

                % precompute the matrix for the rotation from ECEF to ENU
                lat = latRad(i);
                lon = lonRad(i);
                obj(i).ECEF2ENU = [
                    -sin(lon)         ,  cos(lon)         , 0;
                    -sin(lat)*cos(lon), -sin(lat)*sin(lon), cos(lat);
                     cos(lat)*cos(lon),  cos(lat)*sin(lon), sin(lat)];
            end
           
        end

    end

    methods
        % TODO: make a helepr function for getting the user observations
%         obs = getUserObservations(obj)
        plot(obj)
    end

	methods (Static)
        % TODO: want constructors to make different grid types
%         objs = createUserGrid(numSites)
        usrs = createFromLLHFile(llhfile, polyfile)
        usrs = createUserGrid(polyfile, latstep, lonstep)
	end


end