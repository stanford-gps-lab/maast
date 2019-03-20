classdef SatellitePosition < handle
% SatellitePosition     a container for the position of a satellite at a
% given time in both LLH and ECEF coordinates.
%
%   p = maast.tools.SatellitePosition(satellite, time, posType, pos)
%   creates a SatellitePosition from a satellite (satellite) at a given
%   time (time). The position type is specified by posType (either 'llh' or
%   'ecef') with the position given by pos.  The constructor will
%   automatically compute the other position type so that the resulting
%   SatellitePosition contains both types of positions.  For a single
%   satellite, time and pos, the result is a single SatellitePosition.  If
%   satellite is an array of S satellite and time is a scalar, position
%   must be an Sx3 matrix of the position of each S satellites at the given
%   time and the output will be a Sx1 array.  For a single satellite and T
%   times, the pos array must be a 3xT array and the output will be a 1xT
%   array.  For S satellites and T times, the pos input must be an Sx3xT
%   matrix and the output will be an SxT matrix.
%
% Examples:
%   TODO: add some examples
%
% See Also: maast.tools.Satellite
    
    
    % the elements that define a position
    % these properties are private as they are only valid if all are
    % calculated together and that is only guaranteed if all done in the
    % constructor or in an internal function
    properties (SetAccess = private)
        % Satellite - the satellite this position refers to
        %   Note that Satellite are objects, so this can be thought of as a
        %   "pointer" to the satellite object
        Satellite
        
        % t - the time at which this position was calculated
        t
        
        % LLH - the lat/lon/height position of the sat at the given time
        LLH
        
        % ECEF - the ECEF position of the sat at the given time
        ECEF
    end
    
    methods
        
        function obj = SatellitePosition(satellite, time, posType, pos)
            % allow for an empty constructor for list generation
            if nargin == 0
                return;
            end
            
            % get the number of inputs
            S = length(satellite);
            T = length(time);
            
            % get the dimensions of the position matrix
            [r, c, d] = size(pos);
            
            % check to make sure the dimensions are correct
            badCondition1 = (S == 1 && T ~= 1) && (r ~= 3 || c ~= T);
            badCondition2 = (T == 1) && (r ~= S || c ~= 3);
            badCondition3 = (T > 1 && S > 1) && (r ~= S || c ~= 3 || d ~= T);
            if badCondition1 || badCondition2 || badCondition3
                error('position matrix badly formatted');
            end
            
            % put the data into an Sx3xT matrix to make the conversions
            % easier later
            pos3D = zeros(S, 3, T);
            pos3D(1:S, 1:3, 1:T) = pos;
            
            % need to convert the data from one frame to the other
            switch lower(posType)
                case 'llh'
                    posLLH = pos3D;
                    
                    % do some permutation and reshaping to be able to
                    % compute everything at once and then undo those
                    % permutations and reshaping to get the proper sized
                    % matrix
                    posLLHperm = permute(posLLH, [1 3 2]);
                    posLLHall = reshape(posLLHperm, S*T, 3);
                    posECEFall = maast.tools.llh2ecef(posLLHall);
                    posECEFperm = reshape(posECEFall, S, T, 3);
                    posECEF = permute(posECEFperm, [1 3 2]);

                case 'ecef'
                    posECEF = pos3D;
                    
                    % do some permutation and reshaping to be able to
                    % compute everything at once and then undo those
                    % permutations and reshaping to get the proper sized
                    % matrix
                    posECEFperm = permute(posECEF, [1 3 2]);
                    posECEFall = reshape(posECEFperm, S*T, 3);
                    posLLHall = maast.tools.ecef2llh(posECEFall);
                    posLLHperm = reshape(posLLHall, S, T, 3);
                    posLLH = permute(posLLHperm, [1 3 2]);
                    
                otherwise
                    error('invalid position type');
            end
            
            % create the output as an SxT matrix
            obj(S,T) = maast.tools.SatellitePosition();
            for s = 1:S
                for t = 1:T
                    obj(s,t).Satellite = satellite(s);
                    obj(s,t).t = time(t);
                    obj(s,t).LLH = posLLH(s,:,t)';
                    obj(s,t).ECEF = posECEF(s,:,t)';
                end
            end
            
        end
        
        
    end
    
    
    
end