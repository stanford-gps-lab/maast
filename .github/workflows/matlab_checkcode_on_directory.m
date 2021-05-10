function exit_code = matlab_checkcode_on_directory(directory)
    % Performs Mathwork's checkcode linter on all files and sub directory files in input file path. Errors print to
    % screen. Output value exit_code is 0 if all checks pass; otherwise, exit_code is 1.

    matlab_files_to_check = dir(fullfile(directory, '/**/*.m')); % retrieve all matlab files

    fprintf('\n=============== Executing Matlab checkcode ==========\n');

    failure = false;

    % iterate among each of the files files
    for i = 1:length(matlab_files_to_check)

        fullpath = fullfile(matlab_files_to_check(i).folder, matlab_files_to_check(i).name); % assemble full path

        error_string = checkcode(fullpath, '-id', '-string'); % get errors as aggregate string delimited by '\n'
        error_messages = strsplit(error_string, '\n'); % split errors into cell array
        error_messages = error_messages(1:end - 1); % trim off last element containing only '\n'

        % report on any errors
        if ~isempty(error_messages)
            failure = true;
            fprintf('[-FAIL-------] %s\n', fullpath);
            fprintf('      > %s\n', error_messages{:});
        else
            fprintf('[-------PASS-] %s\n', fullpath);
        end
    end

    fprintf('=============== Completed Matlab checkcode ==========\n');

    if failure
        exit_code = 1;
        fprintf('[-FAIL-------] Some checkcode issues found.\n');
    else
        exit_code = 0;
        fprintf('[-------PASS-] Everything looks fine.\n');
    end
end
