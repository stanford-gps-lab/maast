function testSBASUserObservation()
fprintf('Testing maast.SBASUserObservation: ')

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

testResults = [];
%% Define Test Parameters
sbasUserGrid = maast.SBASUserGrid.createSBASUserGrid('NumUsers', 100);
sbasUser = sbasUserGrid.Users(1);
satellite = sgt.Satellite.fromYuma('current.alm');
time = 0;
satellitePosition = satellite.getPosition(time);

%% Test 1 - Constructor - Basic
try
    test1 = maast.SBASUserObservation(sbasUser, satellitePosition);
    if (~isa(test1.User, 'maast.SBASUser'))
       testResults(1) = 1; 
    end
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