function execute_matlab_tests_into_xml(...
    source_directory, test_report_save_directory, test_coverage_report_save_directory)
%Executes all matlab tests in source directory and
%subdirectories and saves result as XML file to save directory

import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;
import matlab.unittest.plugins.XMLPlugin;
import matlab.unittest.plugins.ToFile;
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat

try
    suite = TestSuite.fromFolder(source_directory,'IncludingSubfolders',true);
    runner = TestRunner.withTextOutput();
    
    xmlFile = fullfile(test_report_save_directory);
    runner.addPlugin(XMLPlugin.producingJUnitFormat(xmlFile));
    
    coverageReportFormat = CoberturaFormat(test_coverage_report_save_directory);
    coverageReportPlugin = CodeCoveragePlugin.forFolder(...
        source_directory,'Producing',coverageReportFormat,'IncludingSubfolders',true);
    runner.addPlugin(coverageReportPlugin);
    
    results = runner.runInParallel(suite);
    display(results);
catch e
    disp(getReport(e,'extended'));
    exit(1);
end

exit;

end
