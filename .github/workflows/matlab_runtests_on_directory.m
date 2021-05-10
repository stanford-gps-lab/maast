function exit_code = matlab_runtests_on_directory(directory, xml_report_path, coverage_report_save_directory)
    % Executes all matlab tests in input file path and sub directories. If xml report path and coverage report save
    % directory are provided, the results of the tests and the coverage report are saved according to the input values.
    % Output value exit_code is 0 if all tests pass; otherwise, exit_code is 1.

    % import Matlab packages for testing features
    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.plugins.XMLPlugin
    import matlab.unittest.plugins.ToFile
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.CoberturaFormat

    suite = TestSuite.fromFolder(directory, 'IncludingSubfolders', true); % aggregate all tests in directory

    runner = TestRunner.withTextOutput(); % create runner with text output

    % if 3 input arguments provided, assemble xml results and coverage report
    if nargin == 3
        % xml result feature
        xmlFile = fullfile(xml_report_path);
        runner.addPlugin(XMLPlugin.producingJUnitFormat(xmlFile));

        % coverage report feature
        coverageReportFormat = CoberturaFormat(coverage_report_save_directory);
        coverageReportPlugin = CodeCoveragePlugin.forFolder( ...
                                                            directory, ...
                                                            'Producing', coverageReportFormat, ...
                                                            'IncludingSubfolders', true);
        runner.addPlugin(coverageReportPlugin);
    end

    results = runner.runInParallel(suite); % run the tests

    exit_code = any([results.Failed, results.Incomplete]);

end
