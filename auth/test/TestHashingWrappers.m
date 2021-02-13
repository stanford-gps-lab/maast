classdef TestHashingWrappers < matlab.unittest.TestCase
    %TESTHASHINGWRAPPERS Tests for HashingWrappers
    
    methods(Test)       
        function test_hello_world(testCase)
            input = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            correct_output = uint8(sscanf('a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e','%2x'));
            test_output = HashingWrappers.sha_256(input);
            testCase.assertEqual(correct_output, test_output);
        end
    end
end

