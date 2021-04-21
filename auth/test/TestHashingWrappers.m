classdef TestHashingWrappers < matlab.unittest.TestCase
    % TESTHASHINGWRAPPERS Tests for HashingWrappers

    methods (Test)

        function test_sha256(testCase)
            input = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            correct_output = uint8(sscanf('a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e', '%2x'));
            test_output = HashingWrappers.sha_256(input);
            testCase.assertEqual(correct_output, test_output);
        end

        function test_truncated_sha256(testCase)
            input = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            correct_output = uint8(sscanf('a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e', '%2x'));
            test_output = HashingWrappers.truncated_sha_256(input, 9);
            testCase.assertEqual(correct_output(1:9), test_output);
        end

        function test_HMAC(testCase)
            input = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            key = matlab.net.base64decode(matlab.net.base64encode("ls"));
            correct_output = uint8(sscanf('9e2b27474665d773b5009acab27a27a9167248cd71b9a783fc00660b487cbe6c', '%2x'));
            test_output = HashingWrappers.hmac_sha_256(input, key);
            testCase.assertEqual(correct_output, test_output);
        end

        function test_truncated_HMAC(testCase)
            input = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            key = matlab.net.base64decode(matlab.net.base64encode("ls"));
            correct_output = uint8(sscanf('9e2b27474665d773b5009acab27a27a9167248cd71b9a783fc00660b487cbe6c', '%2x'));
            test_output = HashingWrappers.truncated_hmac_sha_256(input, key, 2);
            testCase.assertEqual(correct_output(1:2), test_output);
        end

    end
end
