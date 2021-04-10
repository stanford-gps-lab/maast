classdef TestDERMethods < matlab.unittest.TestCase

    properties (Constant, Access = protected)
        good_key_der = uint8([48; 89; 48; 19; 6; 7; 42; 134; 72; 206; 61; 2; 1; 6; 8; 42; 134; 72; 206; 61; 3; 1; 7; ...
                              3; 66; 0; 4; 128; 0; 177; 124; 253; 72; 247; 137; 198; 6; 149; 248; 27; 129; 58; 1; ...
                              47; 29; 54; 96; 51; 46; 173; 201; 159; 230; 70; 117; 5; 68; 61; 153; 240; 80; 232; 79; ...
                              78; 200; 228; 111; 48; 14; 99; 86; 2; 2; 109; 185; 83; 20; 188; 213; 219; 137; 204; ...
                              44; 70; 136; 224; 134; 214; 10; 124; 252])
        good_sig_der = uint8([48; 69; 2; 32; 24; 158; 6; 165; 29; 111; 115; 215; 61; 107; 22; 191; 230; 119; 76; 2; ...
                              29; 24; 101; 236; 222; 55; 183; 224; 255; 180; 72; 83; 170; 187; 22; 39; 2; 33; 0; ...
                              188; 64; 53; 162; 136; 9; 168; 19; 19; 203; 58; 0; 186; 137; 110; 74; 21; 182; 141; ...
                              22; 86; 196; 217; 153; 107; 188; 13; 228; 227; 164; 25; 198])
    end

    methods (Test)

        function test_PK_DER(testcase)

            % ECDSA256
            key_der = TestDERMethods.good_key_der;
            key_pk = DERMethods.DER2PK(key_der, "ECDSA256");
            key_der_out = DERMethods.PK2DER(key_pk, "ECDSA256");
            testcase.verifyEqual(key_der_out, key_der);
        end

        function test_SIG_DER(testcase)

            % ECDSA256
            sig_der = TestDERMethods.good_sig_der;
            sig_pk = DERMethods.DER2SIG(sig_der, "ECDSA256");
            sig_der_out = DERMethods.SIG2DER(sig_pk, "ECDSA256");
            testcase.verifyEqual(sig_der_out, sig_der);
        end

        function test_exceptions_DER2PK(testcase)

            % ECDSA256
            good_key = TestDERMethods.good_key_der;
            good_key_2 = good_key;
            good_key_2(35) = good_key_2(35) + 1;
            bad_key_1 = good_key;
            bad_key_1(1) = bad_key_1(1) + 1;
            bad_key_2 = good_key;
            bad_key_2(2) = bad_key_2(2) + 1;
            bad_key_3 = good_key;
            bad_key_3(10) = bad_key_3(10) + 1;
            DERMethods.DER2PK(good_key, "ECDSA256");
            DERMethods.DER2PK(good_key_2, "ECDSA256");
            testcase.verifyError(@()DERMethods.DER2PK(bad_key_1, "ECDSA256"), 'DERMethods:DER2PK:BadHeader');
            testcase.verifyError(@()DERMethods.DER2PK(bad_key_2, "ECDSA256"), 'DERMethods:DER2PK:BadHeader');
            testcase.verifyError(@()DERMethods.DER2PK(bad_key_3, "ECDSA256"), 'DERMethods:DER2PK:BadHeader');
            testcase.verifyError(@()DERMethods.DER2PK(good_key, "ECDSA112"), 'DERMethods:DER2PK:BadKeyType');

        end

        function test_exceptions_PK2DER(testcase)

            % ECDSA256
            good_public_key = uint8(1:64)';
            DERMethods.PK2DER(good_public_key, "ECDSA256");
            testcase.verifyError(@()DERMethods.PK2DER(good_public_key, "ECDSA112"), ...
                                 'DERMethods:PK2DER:BadKeyType');
            testcase.verifyError(@()DERMethods.PK2DER(good_public_key(1:5), "ECDSA256"), ...
                                 'DERMethods:PK2DER:BadPublicKey');
        end

        function test_exceptions_DER2SIG(testcase)

            % ECDSA256
            good_sig = TestDERMethods.good_sig_der;
            good_sig_2 = good_sig;
            good_sig_2([8, 27, 60]) = good_sig_2([8, 27, 60]) + 1;
            bad_sigs = repmat(good_sig, [1, 6]);
            change_indeces = [1, 3, 4, 37, 38];
            for i = 1:5
                bad_sigs(change_indeces(i), i) = bad_sigs(change_indeces(i), i) + 1;
            end
            DERMethods.DER2SIG(good_sig, "ECDSA256");
            DERMethods.DER2SIG(good_sig_2, "ECDSA256");
            testcase.verifyError(@()DERMethods.DER2SIG(good_sig, "ECDSA112"), ...
                                 'DERMethods:DER2SIG:BadKeyType');
            for i = 1:5
                testcase.verifyError(@()DERMethods.DER2SIG(bad_sigs(:, i), "ECDSA256"), ...
                                     'DERMethods:DER2SIG:BadSignature');
            end

        end

        function test_exceptions_SIG2DER(testcase)

            % ECDSA256
            good_public_sig = uint8(1:64)';
            DERMethods.PK2DER(good_public_sig, "ECDSA256");
            testcase.verifyError(@()DERMethods.SIG2DER(good_public_sig, "ECDSA112"), ...
                                 'DERMethods:SIG2DER:BadKeyType');
            testcase.verifyError(@()DERMethods.SIG2DER(good_public_sig(1:5), "ECDSA256"), ...
                                 'DERMethods:SIG2DER:BadPublicKey');
        end

        function test_not_full_bit_number_pk(testcase)

            % ECDSA256
            good_public_pk = uint8([129, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2PK(DERMethods.PK2DER(good_public_pk, "ECDSA256"), "ECDSA256"), ...
                                 good_public_pk);
            good_public_pk = uint8([127, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2PK(DERMethods.PK2DER(good_public_pk, "ECDSA256"), "ECDSA256"), ...
                                 good_public_pk);
            good_public_pk = uint8([63, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2PK(DERMethods.PK2DER(good_public_pk, "ECDSA256"), "ECDSA256"), ...
                                 good_public_pk);
            good_public_pk = uint8([31, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2PK(DERMethods.PK2DER(good_public_pk, "ECDSA256"), "ECDSA256"), ...
                                 good_public_pk);
            good_public_pk = uint8([15, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2PK(DERMethods.PK2DER(good_public_pk, "ECDSA256"), "ECDSA256"), ...
                                 good_public_pk);
            good_public_pk = uint8([7, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2PK(DERMethods.PK2DER(good_public_pk, "ECDSA256"), "ECDSA256"), ...
                                 good_public_pk);
            good_public_pk = uint8([3, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2PK(DERMethods.PK2DER(good_public_pk, "ECDSA256"), "ECDSA256"), ...
                                 good_public_pk);
            good_public_pk = uint8([1, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2PK(DERMethods.PK2DER(good_public_pk, "ECDSA256"), "ECDSA256"), ...
                                 good_public_pk);
            good_public_pk = uint8([0, 63, 1:62])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2PK(DERMethods.PK2DER(good_public_pk, "ECDSA256"), "ECDSA256"), ...
                                 good_public_pk);
        end

        function test_not_full_bit_number_sig(testcase)

            % ECDSA256
            good_public_sig = uint8([129, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2SIG(DERMethods.SIG2DER(good_public_sig, "ECDSA256"), "ECDSA256"), ...
                                 good_public_sig);
            good_public_sig = uint8([127, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2SIG(DERMethods.SIG2DER(good_public_sig, "ECDSA256"), "ECDSA256"), ...
                                 good_public_sig);
            good_public_sig = uint8([63, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2SIG(DERMethods.SIG2DER(good_public_sig, "ECDSA256"), "ECDSA256"), ...
                                 good_public_sig);
            good_public_sig = uint8([31, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2SIG(DERMethods.SIG2DER(good_public_sig, "ECDSA256"), "ECDSA256"), ...
                                 good_public_sig);
            good_public_sig = uint8([15, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2SIG(DERMethods.SIG2DER(good_public_sig, "ECDSA256"), "ECDSA256"), ...
                                 good_public_sig);
            good_public_sig = uint8([7, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2SIG(DERMethods.SIG2DER(good_public_sig, "ECDSA256"), "ECDSA256"), ...
                                 good_public_sig);
            good_public_sig = uint8([3, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2SIG(DERMethods.SIG2DER(good_public_sig, "ECDSA256"), "ECDSA256"), ...
                                 good_public_sig);

            good_public_sig = uint8([1, 1:63])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2SIG(DERMethods.SIG2DER(good_public_sig, "ECDSA256"), "ECDSA256"), ...
                                 good_public_sig);
            testcase.verifyEqual(length(DERMethods.SIG2DER(good_public_sig, "ECDSA256")), 70);

            good_public_sig = uint8([0, 63, 1:62])';
            testcase.verifyEqual( ...
                                 DERMethods.DER2SIG(DERMethods.SIG2DER(good_public_sig, "ECDSA256"), "ECDSA256"), ...
                                 good_public_sig);
            testcase.verifyEqual(length(DERMethods.SIG2DER(good_public_sig, "ECDSA256")), 69);
        end

    end
end
