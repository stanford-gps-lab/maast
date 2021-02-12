function execute_matlab_tests_into_xml(source_directory, save_directory)
%EXECUTE_TEST_WITH_TAP Executes all matlab tests in source directory and
%subdirectories and saves result as TAP file to save directory

import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;
import matlab.unittest.plugins.XMLPlugin;
import matlab.unittest.plugins.ToFile;

try
    suite = TestSuite.fromFolder(source_directory, ...
        'IncludingSubfolders', true);
    runner = TestRunner.withTextOutput();
    xmlFile = fullfile(save_directory);
    runner.addPlugin(XMLPlugin.producingJUnitFormat(xmlFile));
    results = runner.run(suite);
    display(results);
catch e
    disp(getReport(e,'extended'));
    exit(1);
end

exit;

end
