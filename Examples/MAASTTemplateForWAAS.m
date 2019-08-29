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
waasReferenceStationPos = 'wrs_foc.dat';
polyFile = 'usrconus.dat';
gridStep = 2;
almanac = 'current.alm';    % Yuma File
time = 0:300:86400;     % [s]

% Dependent parameters
timeLength = length(time);

%% Build WAAS reference station Grid
wrs = maast.SBASReferenceStationGrid.createReferenceStationGrid('LLHFile', waasReferenceStationPos);

%% Build SBAS User Grid
sbasUserGrid = maast.SBASUserGrid.createUserGrid('PolygonFile', polyFile, 'GridStep', gridStep);

%% Build Satellite Constellation
satellite = sgt.Satellite.fromYuma(almanac);

%% Calculate Satellite Positions over time
satellitePosition = satellite.getPosition(time);

%% Calculate WAAS reference station observations
numReferenceStations = length(wrs.Users);
wrsObservation(numReferenceStations, timeLength) = maast.SBASReferenceObservation;
for i = 1:numReferenceStations
    i
    wrsObservation(i,:) = maast.SBASReferenceObservation(wrs.Users(i), satellitePosition);
end

%% Calculate SBAS User Observations
numSBASUsers = length(sbasUserGrid.Users);
sbasUserObservation(numSBASUsers, timeLength) = maast.SBASUserObservation;
for i = 1:numSBASUsers
    i
    sbasUserObservation(i,:) = maast.SBASUserObservation(sbasUserGrid.Users(i), satellitePosition);
end









