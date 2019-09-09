function testSBASReferenceObservation()
fprintf('Testing maast.SBASReferenceObservation: ')

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

sbasUserGrid = maast.SBASUserGrid.createUserGrid('NumUsers', numUsers);
sbasUser = sbasUserGrid.Users(1);
sbasUserObservation = sgt.UserObservation(sbasUser, satellitePosition);
sbasUserObservation2 = sgt.UserObservation(sbasUser, satellitePosition2);

homedir = pwd;
customTropoVariance = [homedir, '\CustomFunctions\customTropoVariance.m'];
customCNMPVariance = [homedir, '\CustomFunctions\customCNMPVariance.m'];

%% Test 1 - Constructor - Single user
try
    test1 = maast.SBASReferenceObservation(referenceStation, satellitePosition);
catch
    testResults(1) = 1;
end

%% Test 2 - Constructor - Single user at multiple times
% try
    test2 = maast.SBASReferenceObservation(referenceStation, satellitePosition2);
% catch
%     testResults(2) = 1;
% end

%% Test 3 - obj.fromsgtUserObservation - Single user
try
    test3 = maast.SBASReferenceObservation.fromSBASUserObservation(sbasUserObservation);
    
    if (~isa(test3, 'maast.SBASReferenceObservation'))
        testResults(3) = 1;
    end
catch
    testResults(3) = 1;
end

%% Test 4 - obj.fromsgtUserObservation - Single user at multiple times
try
    test4 = maast.SBASReferenceObservation.fromSBASUserObservation(sbasUserObservation2);
    
    if (~isa(test4, 'maast.SBASReferenceObservation')) && (length(test4) ~= length(time2))
        testResults(4) = 1;
    end
catch
    testResults(4) = 1;
end

%% Test 5 - Constructor - use varargin to test custom tropo variance
try
   test5 = maast.SBASReferenceObservation(referenceStation, satellitePosition, 'CustomTropoVariance', customTropoVariance);
   
   if (isempty(test5.Sig2Tropo)) || (test5.Sig2Tropo ~= -1)
      testResults(5) = 1; 
   end
catch
    testResults(5) = 1;
end

%% Test 6 - Constructor - use varargin to test custom cnmp variance
try
   test6 = maast.SBASReferenceObservation(referenceStation, satellitePosition, 'CustomCNMPVariance', customCNMPVariance);
   
   if (isempty(test6.Sig2CNMP)) || (test6.Sig2CNMP ~= -1)
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