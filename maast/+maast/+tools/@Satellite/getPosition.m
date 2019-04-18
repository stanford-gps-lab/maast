function satPos = getPosition(obj, time)
% getPosition   get the SatellitePosition of the satellite for a given time
%   compute the SatellitePosition (combined ECEF and LLH position) of the
%   satellite from the alamanac data that defines the orbit of the
%   satellite for a given time or a set of times provided.
%
%   satPos = getPosition(satellite, time) computes the SatellitePosition of
%   a satellite (or an array of satellites) at the time(s) provided.  For
%   an array of S satellites and T times, the resulting position matrix
%   will be an SxT matrix of satellite positions defined as
%   SatellitePosition.
%
% See Also: maast.SatellitePosition

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details.
%   Questions and comments should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast



% get constants needed
CONST_MU_E = maast.constants.EarthConstants.mu;
CONST_OMEGA_E = maast.constants.EarthConstants.omega;


%
% Setup
%

% make sure time is as a row vector
if ~isrow(time)
    time = time';
end

% figure out how many satellites and how much time
S = length(obj);
T = length(time);

% extract and expand satellite properties that will be needed

% TODO: this ends up being time intensive.... I wonder if there is a better
% way to do this.  Though at the end of the day this is only needed to be
% done once before the parallelizing
sqrt_a = [obj(:).SqrtA]';
axis = repmat(sqrt_a.^2, 1, T);
toa = repmat([obj(:).TOA]', 1, T);
eccen = repmat([obj(:).Eccentricity]', 1, T);
mean_anomaly = repmat([obj(:).MeanAnomaly]', 1, T);
arg_of_perigree = repmat([obj(:).ArgumentOfPerigee]', 1, T);
inclination = repmat([obj(:).Inclination]', 1, T);
rora = repmat([obj(:).RateOfRightAscension]', 1, T);
right_ascension = repmat([obj(:).RightAscension]', 1, T);

% expand the time vector
time = repmat(time, S, 1);


%
% Computation
%

n0 = sqrt(CONST_MU_E ./ axis.^3);  % dim: SxT

% Modification (for ICD-100)
Tk = time - toa;  % dim: SxT

Mk = mean_anomaly + n0.*Tk;  % dim: SxT
E0 = Mk + 100;
Ek = Mk;
i = 1;
while(abs(Ek-E0) > 1e-12 & i < 250)
  E0 = Ek;
  Ek = Mk + eccen.*sin(E0);
  i = i + 1;
end

cos_Ek = cos(Ek);
sin_Ek = sin(Ek);


% c1 = 1 - eccen .* cos_Ek;
% Ek_dot = n0./c1;

c2 = sqrt(1 - eccen.*eccen);
vk = atan2(c2.*sin_Ek, cos_Ek-eccen);
% vk_dot = Ek_dot.*c2./c1;

phik   = vk + arg_of_perigree;  % dim: SxT

uk = phik;
% uk_dot = vk_dot;

rk = axis .* (1 - eccen.*cos_Ek);  % dim: SxT
% rk_dot = axis.*eccen.*Ek_dot.*sin_Ek;

ik = inclination;  % dim: SxT

cos_uk = cos(uk);
sin_uk = sin(uk);

xxk = rk.*cos_uk;  % dim: SxT
% xxk_dot = rk_dot.*cos_uk - uk_dot.*rk.*sin_uk;

yyk = rk.*sin_uk;  % dim: SxT
% yyk_dot = rk_dot.*sin_uk + uk_dot.*rk.*cos_uk;

Omegak_dot = rora - CONST_OMEGA_E;

Omega_k = right_ascension + Omegak_dot.*Tk - CONST_OMEGA_E * mod(toa, 604800);

cosO = cos(Omega_k);
sinO = sin(Omega_k);
cosi = cos(ik);
sini = sin(ik);

% build the position matrix to output the data
% need to do this step, since now going to populate things by depth
posecef = zeros(S, 3, T);

% populate the X, Y, Z information to create the Sx3xT matrix needed for
% the SatellitePosition constructor
posecef(:,1,:) = xxk.*cosO - yyk.*cosi.*sinO;
posecef(:,2,:) = xxk.*sinO + yyk.*cosi.*cosO;
posecef(:,3,:) = yyk.*sini;

% create the satellite position matrix
% NOTE: need to squeeze the posecef matrix to remove any singleton
% dimensions since that's how the constructor for SatellitePosition is
% built
satPos = pppanal.SatellitePosition(obj, time(1,:), 'ecef', squeeze(posecef));


% original code for creating the position vector:
%sv_xyz = [xxk.*cosO - yyk.*cosi.*sinO, xxk.*sinO + yyk.*cosi.*cosO, yyk.*sini];

% TODO: at the moment don't need any velocity information
%sv_xyz_dot=[xxk_dot.*cosO - Omegak_dot.*xxk.*sinO-...
%            yyk_dot.*cosi.*sinO - Omegak_dot.*yyk.*cosi.*cosO, ...
%            xxk_dot.*sinO + Omegak_dot.*xxk.*cosO+...
%            yyk_dot.*cosi.*cosO - Omegak_dot.*yyk.*cosi.*sinO, ...
%            yyk_dot.*sini];