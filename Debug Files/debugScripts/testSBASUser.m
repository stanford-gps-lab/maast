function testSBASUser()
fprintf('Testing maast.SBASUser: ')

testResults = [];
%% Define Test Parameters
posLLH = [1 2 3];

%% Test 1 - Constructor - single SBAS User
try
   test1 = maast.SBASUser(posLLH); 
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