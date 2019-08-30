function testSBASReferenceStationGrid()
fprintf('Testing maast.SBASReferenceStationGrid: ')

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

testResults = [];
%% Define Test Parameters
posLLH = [1 2 3; 4 5 6];
polygonFile = 'usrconus.dat';
gridName = 'MyGrid';

sgtUserGrid = sgt.UserGrid.createUserGrid('NumUsers', 100);

numUsers = 100;

%% Test 1 - Constructor - single SBASReferenceStationGrid
try
    test1 = maast.SBASReferenceStationGrid(posLLH);
    
    if (~isa(test1, 'maast.SBASReferenceStationGrid')) || (~isa(test1.Users, 'maast.SBASReferenceStation'))
        testResults(1) = 1;
    end
catch
    testResults(1) = 1;
end

%% Test 2 - Constructor - varargin: GridName
try
    test2 = maast.SBASReferenceStationGrid(posLLH, 'GridName', gridName);
    
    if (~strcmp(test2.GridName, gridName))
        testResults(2) = 1;
    end
catch
    testResults(2) = 1;
end

%% Test 3 - Constructor - varargin: PolygonFile
try
    test3 = maast.SBASReferenceStationGrid(posLLH, 'PolygonFile', polygonFile);
catch
    testResults(3) = 1;
end

%% Test 4 - SBASUserGrid.fromsgtUserGrid - single sgt.UserGrid
try
    test4 = maast.SBASReferenceStationGrid.fromsgtUserGrid(sgtUserGrid);
    
    if (~isa(test4, 'maast.SBASReferenceStationGrid')) || (~isa(test4.Users, 'maast.SBASReferenceStation'))
        testResults(4) = 1;
    end
catch
    testResults(4) = 1;
end

%% Test 5 - obj.createSBASUserGrid - create grid of Reference Stations
try
    test5 = maast.SBASReferenceStationGrid.createReferenceStationGrid('NumUsers', numUsers);
    
    if (~isa(test5, 'maast.SBASReferenceStationGrid')) && (~isa(test5.Users, 'maast.SBASReferenceStation'))
        testResults(5) = 1;
    end
catch
    testResults(5) = 1;
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