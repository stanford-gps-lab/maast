classdef TestMT51 < matlab.unittest.TestCase

    methods (Test)

        function test_encode_and_decode(testcase)
            germane_key_level = 2;
            germane_key_hash = [uint8(3); uint8(5)];
            germane_key_expiration = uint32(123456789);
            authenticating_key_hash = [uint8(7); uint8(11)];
            payload_type = uint8(3);
            payload_page = uint8(13);
            payload = uint8(1:16)';

            mt51 = MT51( ...
                        germane_key_level, ...
                        germane_key_hash, ...
                        germane_key_expiration, ...
                        authenticating_key_hash, ...
                        payload_type, ...
                        payload_page, ...
                        payload).encode();

            mt51_out = MT51.decode(mt51);

            testcase.verifyEqual(mt51_out.germane_key_level, germane_key_level);
            testcase.verifyEqual(mt51_out.germane_key_hash, germane_key_hash);
            testcase.verifyEqual(mt51_out.germane_key_expiration, germane_key_expiration);
            testcase.verifyEqual(mt51_out.authenticating_key_hash, authenticating_key_hash);
            testcase.verifyEqual(mt51_out.payload_type, payload_type);
            testcase.verifyEqual(mt51_out.payload_page, payload_page);
            testcase.verifyEqual(mt51_out.payload, payload);
        end

        function test_not_mt51_exception(testcase)
            germane_key_level = 2;
            germane_key_hash = [uint8(3); uint8(5)];
            germane_key_expiration = uint32(123456789);
            authenticating_key_hash = [uint8(7); uint8(11)];
            payload_type = uint8(3);
            payload_page = uint8(13);
            payload = uint8(1:16)';

            mt51 = MT51( ...
                        germane_key_level, ...
                        germane_key_hash, ...
                        germane_key_expiration, ...
                        authenticating_key_hash, ...
                        payload_type, ...
                        payload_page, ...
                        payload).encode();

            mt51(9) = ~mt51(9);

            testcase.verifyError(@() MT51.decode(mt51), 'MT51:BadMessageType');
        end

    end
end
