classdef TestHashingWrappers < matlab.unittest.TestCase
    %TESTHASHINGWRAPPERS Tests for HashingWrappers
    
    methods(Test)       
        function test_hello_world(testCase)
            input = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            correct_output = uint8(sscanf('a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e','%2x'));
            test_output = HashingWrappers.sha_256(input);
            testCase.assertEqual(correct_output, test_output);
        end
        
        function test_HMAC(testCase)
            input = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            key = matlab.net.base64decode(matlab.net.base64encode("ls"));
            correct_output = uint8(sscanf('9e2b27474665d773b5009acab27a27a9167248cd71b9a783fc00660b487cbe6c', '%2x'));
            test_output = HashingWrappers.hmac_sha_256(input, key);
            testCase.assertEqual(correct_output, test_output);
        end
        
        function test_authenticator_ECDSA(testCase)
            message = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            obj = AuthenticatorECDSA();
            sig = sign(obj, message);
            
            testCase.assertTrue(verify(obj, message,sig));
        end
        
        function test_authenticator_ECDSA2(testCase)
            message = matlab.net.base64decode(matlab.net.base64encode("Hello World"));
            obj = AuthenticatorECDSA();
            sig = sign(obj, message);
            
            testCase.assertTrue(~verify(obj, message - 1,sig));
        end
        
        
        function test_authenticator_ECDSA3(testCase)
            import java.security.*;
            keyGen = KeyPairGenerator.getInstance("EC");
            keyGen.initialize(256, SecureRandom());
            
            pair = keyGen.generateKeyPair();
            private_key = pair.getPrivate().getEncoded();
            public_key_correct = pair.getPublic();
            
            ae = AuthenticatorECDSA(private_key, 1);
            testCase.verifyEqual(ae.public_key, public_key_correct);
          
        end
        
       
    end
end

