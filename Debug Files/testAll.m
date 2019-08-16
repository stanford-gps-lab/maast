% Test all
clear; close all; clc;

%% Get test file names to be run

testDir = [pwd, '\debugScripts'];
testList = dir(fullfile(testDir, '*.m'));

% Record command prompt
if (exist('testResults.test', 'file') == 2)
    delete testResults.test
end

diary testResults.test

%% Test sgt
for i = 1:length(testList)
    run(fullfile(testDir, testList(i).name));
end

fprintf('\nLicenses in Use:\n')
license('inuse') %  This helps in development to ensure that on MATLAB is being used.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Check to see that only the 'matlab' license is used %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diary off


