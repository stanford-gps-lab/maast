% Test all
clear; close all; clc;

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

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
license('inuse') %  This helps in development to ensure that only MATLAB is being used.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Check to see that only the 'matlab' license is used %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diary off
