classdef TestSBASKey < matlab.unittest.TestCase
    % TESTKEY Summary of this class goes here
    %   Detailed explanation goes here

    methods (Test)

        function test_constructor(testcase)

            dummy_hash_1 = uint8([14, 201]);
            dummy_hash_2 = uint8([35, 195]);
            time = uint32(1500000);

            for i = 1:3
                SBASKey(i, uint8([14, 201]), time, dummy_hash_2);
            end
            testcase.verifyError(@() SBASKey(0, dummy_hash_1, time, dummy_hash_2), 'SBASKey:InvalidKeyLevel');

            good_key = uint8(1:64);
            bad_key = uint8(1:50);
            good_sig = uint8(1:64);
            bad_signature = uint8(1:50);
            for i = 1:3
                testcase.verifyError(@() SBASKey(i, dummy_hash_1, time, dummy_hash_2, bad_key), ...
                                     'SBASKey:BadConstructorArguments');
                testcase.verifyError(@() SBASKey(i, dummy_hash_1, time, dummy_hash_2, bad_key, good_sig), ...
                                     'SBASKey:BadConstructorArguments');
                testcase.verifyError(@() SBASKey(i, dummy_hash_1, time, dummy_hash_2, good_key, bad_signature), ...
                                     'SBASKey:BadConstructorArguments');
            end

            SBASKey(1, dummy_hash_1, time, dummy_hash_2, good_key);

            SBASKey(2, dummy_hash_1, time, dummy_hash_2, good_key);
            SBASKey(2, dummy_hash_1, time, dummy_hash_2, good_key, good_sig);

            SBASKey(3, dummy_hash_1, time, dummy_hash_2, good_key(1:16));
            SBASKey(3, dummy_hash_1, time, dummy_hash_2, good_key(1:16), good_sig);

            testcase.verifyError(@() SBASKey(i, dummy_hash_1, time, dummy_hash_2, good_key, good_sig, good_key), ...
                                 'MATLAB:TooManyInputs');
            testcase.verifyError(@() SBASKey(i, dummy_hash_1, time), 'MATLAB:minrhs');
        end

        function test_equal_method(testcase)

            level = 2;
            hash = uint8([18, 125]);
            time = uint32(494967290);
            key = uint8(1:64);
            signature = uint8(2:65);

            key1 = SBASKey(level, hash, time, hash + uint8(5), key, signature);
            testcase.verifyTrue(key1 == SBASKey(level, hash, time, hash + uint8(5), key, signature));
            testcase.verifyFalse(key1 == SBASKey(level, hash, time, hash + uint8(5), key));
            testcase.verifyFalse(key1 == SBASKey(level, hash, time, hash + uint8(5)));
            testcase.verifyFalse(key1 == SBASKey(level + uint8(1), hash, time, hash + uint8(5), key(1:16), signature));
            testcase.verifyFalse(key1 == SBASKey(level, hash + uint8(1), time, hash + uint8(5), key, signature));
            testcase.verifyFalse(key1 == SBASKey(level, hash, time + uint32(1), hash + uint8(5), key, signature));
            testcase.verifyFalse(key1 == SBASKey(level, hash, time, hash + uint8(6), key, signature));
            testcase.verifyFalse(key1 == SBASKey(level, hash, time, hash + uint8(5), key + uint8(1), signature));
            testcase.verifyFalse(key1 == SBASKey(level, hash, time, hash + uint8(5), key, signature + uint8(1)));

        end

        function test_signing_data(testcase)
            level = uint8(2);
            hash = uint8([18, 125]);
            time = uint32(44967295);
            key = uint8(1:64);
            signature = uint8(2:65);

            key1 = SBASKey(level, hash, time, hash + uint8(5), key, signature);

            testcase.verifyEqual(key1.signing_data(), [ ...
                                                       logical(de2bi(level, 2)), ...
                                                       reshape(logical(de2bi(hash, 8)), 1, []), ...
                                                       logical(de2bi(time, 32)), ...
                                                       reshape(logical(de2bi(hash + uint8(5), 8)), 1, []), ...
                                                       reshape(logical(de2bi(key, 8)), 1, []) ...
                                                      ]');
        end

    end
end
