classdef TestAuthenticatorECDSA < matlab.unittest.TestCase
    % TESTAUTHENTICATORECDSA Tests for AuthenticatorECDSA

    methods (Test)

        function test_authenticator_ECDSA(testCase)
            message = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            obj = AuthenticatorECDSA();
            sig = sign(obj, message);

            testCase.assertTrue(verify(obj, message, sig));
        end

        function test_authenticator_ECDSA2(testCase)
            message = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            obj = AuthenticatorECDSA();
            sig = sign(obj, message);

            testCase.assertTrue(~verify(obj, message - 1, sig));
        end

        function test_modified_signiture(testCase)
            message = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            obj = AuthenticatorECDSA();
            sig = sign(obj, message);
            sig = sig - 1;

            testCase.verifyError(@()verify(obj, message - 1, sig), ...
                                 'MATLAB:Java:GenericException');
        end

        function test_sign_multiple_messages(testCase)
            m1 = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            m2 = matlab.net.base64decode(matlab.net.base64encode("Hey"));
            m3 = matlab.net.base64decode(matlab.net.base64encode("matlab"));
            m4 = matlab.net.base64decode(matlab.net.base64encode("maast"));
            m5 = matlab.net.base64decode(matlab.net.base64encode("tesla"));

            ae = AuthenticatorECDSA();

            sig1 = sign(ae, m1);
            sig2 = sign(ae, m2);
            sig3 = sign(ae, m3);
            sig4 = sign(ae, m4);
            sig5 = sign(ae, m5);

            testCase.assertTrue(verify(ae, m1, sig1));
            testCase.assertTrue(verify(ae, m2, sig2));
            testCase.assertTrue(verify(ae, m3, sig3));
            testCase.assertTrue(verify(ae, m4, sig4));
            testCase.assertTrue(verify(ae, m5, sig5));

            testCase.assertTrue(~verify(ae, m1, sig2));
            testCase.assertTrue(~verify(ae, m2, sig4));
        end

        function wrong_authenticator_test(testCase)
            m1 = matlab.net.base64decode(matlab.net.base64encode("Hello World"));

            ae = AuthenticatorECDSA();
            ae2 = AuthenticatorECDSA();

            sig1 = sign(ae, m1);
            testCase.assertTrue(verify(ae, m1, sig1));
            testCase.assertTrue(~verify(ae2, m1, sig1));
        end

        function test_error_throw_on_constructor(testCase)
            dummy_public_key = uint8([ ...
                                      48, 89, 48, 19, 6, 7, 42, 134, 72, 206, 61, 2, 1, 6, 8, 42, 134, 72, 206, 61, ...
                                      3, 1, 7, 3, 66, 0, 4, 136, 214, 67, 3, 91, 194, 56, 41, 192, 85, 67, 155, 129, ...
                                      14, 79, 4, 216, 197, 18, 56, 149, 205, 36, 249, 98, 4, 62, 160, 6, 82, 223, ...
                                      37, 45, 238, 7, 204, 181, 57, 249, 229, 140, 19, 158, 189, 71, 230, 50, 209, ...
                                      99, 192, 185, 47, 54, 74, 138, 50, 56, 50,  49, 193, 26, 215, 58, 24]);
            testCase.verifyError(@()AuthenticatorECDSA(dummy_public_key, 1), ...
                                 'Authenticator:BadConstructorArguments');
        end

        function thows_error_on_salt(testCase)
            testCase.verifyError(@()AuthenticatorECDSA.salt("hello"), ...
                                 'AuthenticatorECDSA:NotImplementedError');
        end

        function test_constructing_public_key_from_der(testCase)
            ae1 = AuthenticatorECDSA();
            ae2 = AuthenticatorECDSA(ae1.get_public_key_der());
            testCase.verifyEqual(ae1.get_public_key_der(), ae2.get_public_key_der());

            message = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            signature = ae1.sign(message);
            testCase.verifyError(@() ae2.sign(message), 'AuthenticatorECDSA:NoPrivateKey');
            testCase.verifyTrue(ae1.verify(message, signature));
            testCase.verifyTrue(ae2.verify(message, signature));
        end

        function test_constructing_public_key_from_DERMethods(testCase)
            ae1 = AuthenticatorECDSA();
            pk = DERMethods.DER2PK(ae1.get_public_key_der(), 'ECDSA256');
            der = DERMethods.PK2DER(pk, 'ECDSA256');
            ae2 = AuthenticatorECDSA(der);
            testCase.verifyEqual(ae1.get_public_key_der(), ae2.get_public_key_der());

            message = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            signature = ae1.sign(message);

            signature = DERMethods.SIG2DER(DERMethods.DER2SIG(signature, 'ECDSA256'), 'ECDSA256');

            testCase.verifyError(@() ae2.sign(message), 'AuthenticatorECDSA:NoPrivateKey');
            testCase.verifyTrue(ae1.verify(message, signature));
            testCase.verifyTrue(ae2.verify(message, signature));
        end

    end
end
