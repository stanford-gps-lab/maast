function testSBASReferenceStation()
fprintf('Testing maast.SBASReferenceStation: ')

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

testResults = [];
%% Define Test Parameters
posLLH = [1 2 3];
posLLH2 = [posLLH; 4 5 6];
[numUsers2, ~] = size(posLLH2);
polygonFile = 'usrconus.dat';
elevationMask = 10*pi/180;

sgtUser = sgt.User(posLLH);
sgtUser2 = sgt.User(posLLH2);

%% Test 1 - Constructor - single SBAS reference station
try
    test1 = maast.SBASReferenceStation(posLLH);
    
    if (~isa(test1, 'maast.SBASReferenceStation'))
        testResults(1) = 1;
    end
catch
    testResults(1) = 1;
end

%% Test 2 - Constructor - multiple SBAS reference stations
try
    test2 = maast.SBASReferenceStation(posLLH2);
    
    if (~isa(test2, 'maast.SBASReferenceStation')) || (length(test2) ~= numUsers2)
        testResults(2) = 1;
    end
catch
    testResults(2) = 1;
end

%% Test 3 - Constructor - varargin: ID
try
    test3 = maast.SBASReferenceStation(posLLH, 'ID', 3);
    
    if (test3.ID ~= 3)
        testResults(3) = 1;
    end
catch
    testResults(3) = 1;
end

%% Test 4 - Constructor - varargin: PolygonFile
try
    test4 = maast.SBASReferenceStation(posLLH, 'PolygonFile', polygonFile);
catch
    testResults(4) = 1;
end

%% Test 5 - Constructor - varargin: ElevationMask
try
    test5 = maast.SBASReferenceStation(posLLH, 'ElevationMask', elevationMask);
    
    if (test5.ElevationMask ~= elevationMask)
        testResults(5) = 1;
    end
catch
    testResults(5) = 1;
end

%% Test 6 - SBASUser.fromsgtUser - single user
try
    test6 = maast.SBASReferenceStation.fromsgtUser(sgtUser);
    
    if (~isa(test6, 'maast.SBASReferenceStation'))
        testResults(6) = 1;
    end
catch
    testResults(6) = 1;
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