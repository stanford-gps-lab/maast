classdef ExampleTest < matlab.unittest.TestCase
    % EXAMPLETEST An Example Test Class

    methods (Test)

        function testAddition(testCase)
            testCase.verifyEqual(1 + 1, 2);
            testCase.verifyEqual(1 + 2, 3);
        end

        function testMultiplication(testCase)
            testCase.verifyEqual(2 * 3, 6);
        end

    end
end
