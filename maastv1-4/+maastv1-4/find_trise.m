function trise = find_trise(tmin,tmax,sinmask,alm_param,usr_xyz,...
                            usr_ehat,usr_nhat,usr_uhat)
%*************************************************************************
%*     Copyright c 2001 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% created 2001 Apr 27 by Wyant Chan
% major modification 2001 June 17 by Wyant Chan

nsat = size(alm_param,1);
nusr = size(usr_xyz,1);
nlos = nsat*nusr;
t = [tmin:300:tmax]';
nt = length(t);
maxnrise = 2;   % maximum number of rise times per los
                % updates if a los with more rise times is found.
trise = repmat(NaN,nlos,maxnrise);
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


