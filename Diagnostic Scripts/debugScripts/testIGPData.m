function testIGPData()
fprintf('Testing maast.IGPData: ')

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

testResults = [];
%% Define Test Parameters
igpFile = 'igpjoint_R8_9.dat';

%% Test 1 - Constructor - load an igp file
try
    test1 = maast.IGPData(igpFile);
catch
    testResults(1) = 1;
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