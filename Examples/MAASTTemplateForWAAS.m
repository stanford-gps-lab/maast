% This script is a template for how to use maast toolbox to execute a WAAS
% availability simulation.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast
clear; close all; clc;

%% Set Parameters
posLLH = [37.427127, -122.173243, 17];  % [deg deg m] Stanford GPS Lab location
% polyFile = 'usrconus.dat';
% gridStep = 10;
almanac = 'current.alm';    % Yuma File
time = 0:300:86400;     % [s]

%% Build SBAS User Grid
user = maast.SBASUser(posLLH);

%% Build Satellite Constellation
satellite = sgt.Satellite.fromYuma(almanac);

%% Calculate Satellite Positions
satellitePosition = satellite.getPosition(time);

%% Calculate User Observations
userObservation = maast.SBASUserObservation(user, satellitePosition);








