function [trise] = findTRise(t, satellites, users)

% compute the rise time for all the satellites for all the users given the
% time vector in t
%
% NOTE: unfortunately I'm struggling to find a way to put this into the obs
% since the time vector, t, is different for this function than it is for
% the simulation
%
% TODO: need to decide on an output format here that works best...

% get some dimensions
S = length(satellites);
U = length(users);
T = length(t);

% get the position of the satellites at each of the time steps
satPoses = satellites.getPosition(t);


maxnrise = 3;   % maximum number of rise times per los
                % updates if a los with more rise times is found.
trise = NaN(U, S, maxnrise);  % TODO: decide on the proper dimension here


% loop by user
for u = 1:U
    % get the specific user
    user = users(u);
    sinMask = sin(user.ElevationMask);
    
    for s = 1:S
        % get the position of satellite s for all time
        satPos = [satPoses(s,:).ECEF];

        % compute the sin of the elevation angle of all the satellites at
        % all times
        losecef = satPos - repmat(user.Position, 1, T);
        r = vecnorm(losecef);
        losecef = losecef ./ repmat(r, 3, 1);
        losenu = user.ECEF2ENU * losecef;
        sinElevation = losenu(3,:);
        
        % find the rise indices
        
        iRise = find(sinElevation(2:end) >= sinMask & ...
                     sinElevation(1:end-1) < sinMask) + 1;

        if length(iRise) > maxnrise
            % TODO: need to grow the matrix here, though need to do it in a
            % weird dimension with the way that trise is currently defined
            maxnrise = length(iRise);
        end

        % loop through the rise indices and compute the associated rise
        % time
        for j = 1:length(iRise)
            i = iRise(j);

            % NOTE (from original coding):           
            % Using quadratic interpolation on sin_el, tests using almmops
            % and almyuma45 yielded 0 sec rounded error from actual rise
            % time more than 96% of the time, with a max error of 1 sec at
            % 1 sec resolution.  Using quad interp on the elevation rather
            % than the sin(elev) yields 0 error 98% of the time.
            if i == 2             % at start
                tr = quadfit(sinMask, [t(i-1), t(i), t(i+1)], ...
                            [sinElevation(i-1), sinElevation(i), sinElevation(i+1)]);

            elseif i == length(t) % at end
                tr = quadfit(sinMask, [t(i-2), t(i-1), t(i)], ...
                            [sinElevation(i-2), sinElevation(i-1), sinElevation(i)]);
            elseif abs(sinElevation(i-1) - sinMask) < abs(sinElevation(i) - sinMask)
                tr = quadfit(sinMask, [t(i-2), t(i-1), t(i)], ...
                            [sinElevation(i-2), sinElevation(i-1), sinElevation(i)]);
            else
                tr = quadfit(sinMask, [t(i-1), t(i), t(i+1)], ...
                            [sinElevation(i-1), sinElevation(i), sinElevation(i+1)]);
            end
            
            % use first integer second after rise as rise time
            trise(u, s, j) = ceil(tr);
        end
        
    end
end
