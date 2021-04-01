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
            testCase.verifyError(@()AuthenticatorECDSA('hi', 1), ...
                                 'Authenticator:BadConstructorArguments');
        end

        function thows_error_on_salt(testCase)
            testCase.verifyError(@()AuthenticatorECDSA.salt("hello"), ...
                                 'AuthenticatorECDSA:NotImplementedError');
        end

    end
end
