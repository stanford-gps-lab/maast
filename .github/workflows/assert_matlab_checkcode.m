function assert_matlab_checkcode(filepath)

matlab_files_to_check = dir(fullfile(filepath,'/**/*.m'));

fprintf('\n========== Executing Matlab checkcode ==========\n');

failure_flag = false;

for i = 1:length(matlab_files_to_check)
    fullpath = fullfile(matlab_files_to_check(i).folder,matlab_files_to_check(i).name);
    error_messages = checkcode(fullpath, '-id','-string');
    
    fprintf('--> %s\n', fullpath);
    if ~isempty(error_messages)
        fprintf(error_messages);
        failure_flag = true;
    else
        fprintf('No issues found.\n');
    end
end

fprintf('\n========== Completed Matlab checkcode ==========\n');

if failure_flag
    exit(1);
end

end
