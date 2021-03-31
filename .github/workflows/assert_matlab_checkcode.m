function assert_matlab_checkcode(filepath)
% executes matlab checkcode on all m files in filepath, prints any errors to screen, and then asserts no errors.

matlab_files_to_check = dir(fullfile(filepath,'/**/*.m'));

fprintf('\n========== Executing Matlab checkcode ==========\n');

failure_flag = false;

% iterate among files
for i = 1:length(matlab_files_to_check)
    
    fullpath = fullfile(matlab_files_to_check(i).folder,matlab_files_to_check(i).name);
    error_messages = checkcode(fullpath, '-id','-string');
    
    % report on errors
    fprintf('--> %s\n', fullpath);
    if ~isempty(error_messages)
        fprintf(error_messages);
        failure_flag = true;
    else
        fprintf('No issues found.\n');
    end
end

fprintf('\n========== Completed Matlab checkcode ==========\n');

% if any failures, exit with nonzero code to report to build checker
if failure_flag
    exit(1);
end

end
