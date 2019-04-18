function trise = getTRise(obj)

% compute the rise time for all the satellites for this given observation
%
% NOTE: first step is to get this working on a single observation (single
% user, single point in time, with S satellites and Sv satellites in view)
%
% TODO: make this work on a list of user observations (for a single user)
% and then make this work on even more dimensionality

% NOTE: for now U should be 1, if it isn't this script will fail
U = length(obj);
S = length(obj.SatellitePositions);

% get the time vector -> this is based on the times of the satellite
% positions
t = [obj.SatellitePositions.t];
T = length(t);  % the number of time steps


maxnrise = 2;   % maximum number of rise times per los
                % updates if a los with more rise times is found.
trise = NaN(); repmat(NaN,nlos,maxnrise);
% trise_exact = repmat(NaN,nlos,maxnrise);

for isat=1:nsat
    [prn,satxyz,satvel]=alm2satposvel(t,alm_param(isat,:));   
    gxyzb = find_los_xyzb(usr_xyz,satxyz);
    genub = find_los_enub(gxyzb,usr_ehat,usr_nhat,usr_uhat);

    for iusr=1:nusr
        sin_ellos = -genub((iusr-1)*nt+[1:nt],3);
        idxrise = find(sin_ellos(2:end)>=sinmask & ...
                        sin_ellos(1:end-1)<sinmask)+1;
        if length(idxrise)>maxnrise,
            trise = [trise,repmat(NaN,nlos,length(idxrise)-maxnrise)];
%            trise_exact = [trise_exact,...
%                    repmat(NaN,nlos,length(idxrise)-maxnrise)];
            maxnrise = length(idxrise);
        end

        for j=1:length(idxrise)
            i = idxrise(j);

%            % find exact time
%            t1 = [t(i-1):t(i)]';
%            [prn1,satxyz1,satvel1]=alm2satposvel(t1,alm_param(isat,:));
%            gxyzb1 = find_los_xyzb(usr_xyz(iusr,:),satxyz1);
%            genub1 = find_los_enub(gxyzb1,...
%                usr_ehat(iusr,:),usr_nhat(iusr,:),usr_uhat(iusr,:));
%            sin_el1 = -genub1(:,3);
%            idx=find(sin_el1(2:end)>=sinmask & sin_el1(1:end-1)<sinmask)+1;
%            trise_exact((iusr-1)*nsat+isat,j) = t1(idx(1));

            % Using quadratic interpolation on sin_el, tests using almmops and 
            % almyuma45 yielded 0 sec rounded error from actual rise time 
            % more than 96% of the time, with a max error of 1 sec 
            % at 1 sec resolution.  Using quad interp on the elevation rather
            % than the sin(elev) yields 0 error 98% of the time.
            if i==2             % at start
                tr = quadfit(sinmask,[t(i-1),t(i),t(i+1)],...
                            [sin_ellos(i-1),sin_ellos(i),sin_ellos(i+1)]);
            elseif i==length(t) % at end
                tr = quadfit(sinmask,[t(i-2),t(i-1),t(i)],...
                            [sin_ellos(i-2),sin_ellos(i-1),sin_ellos(i)]);
            elseif abs(sin_ellos(i-1)-sinmask)<abs(sin_ellos(i)-sinmask)
                tr = quadfit(sinmask,[t(i-2),t(i-1),t(i)],...
                            [sin_ellos(i-2),sin_ellos(i-1),sin_ellos(i)]);
            else
                tr = quadfit(sinmask,[t(i-1),t(i),t(i+1)],...
                            [sin_ellos(i-1),sin_ellos(i),sin_ellos(i+1)]);
            end
            % use first integer second after rise as rise time
            trise((iusr-1)*nsat+isat,j) = ceil(tr);
        end
    end
end

% TODO: guard against brief set or rise that might not be detected