classdef TestMT50 < matlab.unittest.TestCase

    methods (Test)

        function test_encode_decode(testcase)
            HMAC1 = uint8([3;5]);
            HMAC2 = uint8([7;11]);
            HMAC3 = uint8([13;17]);
            HMAC4 = uint8([19;23]);
            HMAC5 = uint8([29;31]);
            hp = uint8([11;45;104;155;1;121;25;154;181;12;132;47;117;115;49;66]);

            mt50 = MT50(HMAC1, HMAC2, HMAC3, HMAC4, HMAC5, hp).encode();

            mt50_out = MT50.decode(mt50);

            testcase.verifyEqual(mt50_out.HMAC_1, HMAC1);
            testcase.verifyEqual(mt50_out.HMAC_2, HMAC2);
            testcase.verifyEqual(mt50_out.HMAC_3, HMAC3);
            testcase.verifyEqual(mt50_out.HMAC_4, HMAC4);
            testcase.verifyEqual(mt50_out.HMAC_5, HMAC5);
            testcase.verifyEqual(mt50_out.hash_point, hp);
        end
        
        function test_index_error(testCase)
            HMAC1 = uint8([3;5]);
            HMAC2 = uint8([7;11]);
            HMAC3 = uint8([13;17]);
            HMAC4 = uint8([19;23]);
            HMAC5 = uint8([29;31]);
            hp = uint8([11;45;104;155;1;121;25;154;181;12;132;47;117;115;49;66]);

            mt50 = MT50(HMAC1, HMAC2, HMAC3, HMAC4, HMAC5, hp);

            testCase.verifyError(@() mt50.get_hmac(7), 'MT50:invalidIndex');
            
        end

    end
end
