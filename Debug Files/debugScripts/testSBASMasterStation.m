function testSBASMasterStation()
fprintf('Testing maast.SBASMasterStation: ')

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

testResults = [];
%% Define Test Parameters
numUsers = 100;
referenceStationGrid = maast.SBASReferenceStationGrid.createUserGrid('NumUsers', numUsers);
referenceStation = referenceStationGrid.Users(1);
satellite = sgt.Satellite.fromYuma('current.alm');
time = 0;
time2 = 0:100:1000;
satellitePosition = satellite.getPosition(time);
satellitePosition2 = satellite.getPosition(time2);
sbasReferenceObservation = maast.SBASReferenceObservation(referenceStation, satellitePosition);
sbasReferenceObservation2 = maast.SBASReferenceObservation(referenceStation, satellitePosition2);

homedir = pwd;
customUDREI = [homedir, '\CustomFunctions\customUDREI.m'];
customMT28 = [homedir, '\CustomFunctions\customMT28.m'];

%% Test 1 - Constructor - Single reference station observation
try
    test1 = maast.SBASMasterStation(sbasReferenceObservation);
catch
    testResults(1) = 1;
end

%% Test 2 - Constructor - Multiple reference station observations
try
    test2 = maast.SBASMasterStation(sbasReferenceObservation2);
catch
    testResults(2) = 1;
end

%% Test 3 - Constructor - varargin: CustomUDREI
try
    test3 = maast.SBASMasterStation(sbasReferenceObservation, 'CustomUDREI', customUDREI);
    
    if (test3.UDREI ~= -1*ones(test3.NumSats, test3.NumRefObs))
        testResults(3) = 1;
    end
catch
    testResults(3) = 1;
end

%% Test 4 - Constructor - varargin: CustomMT28
try
    test4 = maast.SBASMasterStation(sbasReferenceObservation, 'CustomMT28', customMT28);
    
    if (test4.MT28{1} ~= -1*ones(4))
        testResults(4) = 1;
    end
catch
    testResults(4) = 1;
end

%% Display test results
if any(testResults)
    fprintf('---Failed---\n')
    testResults = find(testResults);
    for i = 1:length(testResults)
        fprintf(['test', num2str(testResults(i)), ' failed\n'])
    end
else
    fprintf('Passed\n')
end
end