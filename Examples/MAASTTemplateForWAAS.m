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
waasReferenceStationPos = 'wrs_foc.dat';
polyFile = 'usrconus.dat';
gridStep = 20;
almanac = 'current.alm';    % Yuma File
time = 0:300:600;     % [s]
igpFile = 'igpjoint_R8_9.dat';

% Geostationary satellite parameters
geoPRN = [137; 138];
geoLongitude = [-107.0; -133.0];
geoAF0 = zeros(2,1);
geoAF1 = zeros(2,1);
geoConstellation = 'WAAS';

% Dependent parameters
timeLength = length(time);

%% Build WAAS reference station Grid
fprintf('Building WAAS reference station grid: ')
wrsGrid = maast.SBASReferenceStationGrid.createReferenceStationGrid('LLHFile', waasReferenceStationPos);
numReferenceStations = length(wrsGrid.Users);
fprintf([num2str(numReferenceStations), ' WAAS reference stations\n'])

%% Build SBAS User Grid
fprintf('Building WAAS user grid: ')
waasUserGrid = maast.SBASUserGrid.createUserGrid('PolygonFile', polyFile, 'GridStep', gridStep);
numSBASUsers = length(waasUserGrid.Users);
fprintf([num2str(numSBASUsers), ' WAAS users\n'])

%% Build Satellite Constellation
fprintf('Building satellite constellation: ')
satellite = sgt.Satellite.fromYuma(almanac);
fprintf([num2str(length(satellite)), ' satellites\n'])

%% Specify GEO Satellite Orbits
waasSatellite = sgt.Satellite.fromGEO(geoPRN, geoLongitude, geoAF0, geoAF1, geoConstellation);

%% Calculate Satellite Positions over time
fprintf('Calculating satellite positions over time...\n')
gpsSatellitePosition = satellite.getPosition(time);
waasSatellitePosition = waasSatellite.getPosition(time, 'ecef', true);
satellitePosition = [gpsSatellitePosition; waasSatellitePosition];

%% Calculate WAAS Reference Station Observations
fprintf('Calculating WAAS reference station observations...\n')
wrsObservation(numReferenceStations, timeLength) = maast.SBASReferenceObservation;  % Preallocate
for i = 1:numReferenceStations
    wrsObservation(i,:) = maast.SBASReferenceObservation(wrsGrid.Users(i), satellitePosition);
end

%% Collect WAAS Observations at Master Station
fprintf('Combining reference station observations...\n')
waasMasterStation = maast.SBASMasterStation(wrsObservation, igpFile);

%% Calculate WAAS User Observations
fprintf('Calculating WAAS user observations...\n')
waasUserObservation(numSBASUsers, timeLength) = maast.SBASUserObservation;  % Preallocate
for i = 1:numSBASUsers
    waasUserObservation(i,:) = maast.SBASUserObservation(waasUserGrid.Users(i), satellitePosition, waasMasterStation, igpFile);
end









