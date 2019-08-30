% This script is a template for how to use maast toolbox to execute a WAAS
% availability simulation.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast
clear; close all; clc;

%% Set Parameters
fprintf('Setting up run...\n')
% posLLH = [37.427127, -122.173243, 17];  % [deg deg m] Stanford GPS Lab location
waasReferenceStationPos = 'wrs_foc.dat';
polyFile = 'usrconus.dat';
gridStep = 2;
almanac = 'current.alm';    % Yuma File
time = 0:300:86400;     % [s]

% Dependent parameters
timeLength = length(time);

%% Build WAAS reference station Grid
fprintf('Building WAAS reference station grid: ')
wrsGrid = maast.SBASReferenceStationGrid.createReferenceStationGrid('LLHFile', waasReferenceStationPos);
numReferenceStations = length(wrsGrid.Users);
fprintf([num2str(numReferenceStations), ' WAAS reference stations\n'])

%% Build SBAS User Grid
fprintf('Building WAAS user grid: ')
sbasUserGrid = maast.SBASUserGrid.createUserGrid('PolygonFile', polyFile, 'GridStep', gridStep);
numSBASUsers = length(sbasUserGrid.Users);
fprintf([num2str(numSBASUsers), ' WAAS users\n'])

%% Build Satellite Constellation
fprintf('Building satellite constellation: ')
satellite = sgt.Satellite.fromYuma(almanac);
fprintf([num2str(length(satellite)), ' satellites\n'])

%% Calculate Satellite Positions over time
fprintf('Calculating satellite positions over time...\n')
satellitePosition = satellite.getPosition(time);

%% Calculate WAAS reference station observations
fprintf('Calculating WAAS reference station observations...\n')
wrsObservation(numReferenceStations, timeLength) = maast.SBASReferenceObservation;  % Preallocate
for i = 1:numReferenceStations
    wrsObservation(i,:) = maast.SBASReferenceObservation(wrsGrid.Users(i), satellitePosition);
end
%% Calculate SBAS User Observations
fprintf('Calculating WAAS user observations...\n')
sbasUserObservation(numSBASUsers, timeLength) = maast.SBASUserObservation;  % Preallocate
for i = 1:numSBASUsers
    sbasUserObservation(i,:) = maast.SBASUserObservation(sbasUserGrid.Users(i), satellitePosition);
end









