function testSBASUserGrid()
fprintf('Testing maast.SBASUserGrid: ')

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

%% Test 1 - Constructor - single SBASUserGrid
try
    test1 = maast.SBASUserGrid(posLLH);
    
    if (~isa(test1, 'maast.SBASUserGrid')) && (~isa(test1.Users, 'maast.SBASUser'))
        testResults(1) = 1;
    end
catch
    testResults(1) = 1;
end

%% Test 2 - Constructor - varargin: GridName
try
    test2 = maast.SBASUserGrid(posLLH, 'GridName', gridName);
    
    if (~strcmp(test2.GridName, gridName))
        testResults(2) = 1;
    end
catch
    testResults(2) = 1;
end

%% Test 3 - Constructor - varargin: PolygonFile
try
    test3 = maast.SBASUserGrid(posLLH, 'PolygonFile', polygonFile);
catch
    testResults(3) = 1;
end

%% Test 4 - SBASUserGrid.fromsgtUserGrid - single sgt.UserGrid
try
    test4 = maast.SBASUserGrid.fromsgtUserGrid(sgtUserGrid);
    
    if (~isa(test4, 'maast.SBASUserGrid')) && (~isa(test4.Users, 'maast.SBASUser'))
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