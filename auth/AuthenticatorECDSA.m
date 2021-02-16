classdef AuthenticatorECDSA < Authenticator
    %AUTHENTICATORECDSA Summary of this class goes here
    %   Detailed explanation goes here
    properties(Access = private)
     private_key
     public_key
     keyGen
     sig
    end
    methods
        function obj = AuthenticatorECDSA()
            %AUTHENTICATORECDSA Construct an instance of this class
            %   Detailed explanation goes here
            import java.security.*;
            obj.keyGen = KeyPairGenerator.getInstance("EC");
            obj.keyGen.initialize(256, SecureRandom());
            
            pair = obj.keyGen.generateKeyPair();
            obj.private_key = pair.getPrivate();
            obj.public_key = pair.getPublic();
            
            obj.sig = Signature.getInstance("SHA256withECDSA");
            obj.sig.initSign(obj.private_key);
        end
    end
    
    methods % Authenticator implementation
        function signature = sign(obj, message)
            messageByte = matlab.net.base64decode(matlab.net.base64encode(message));
            obj.sig.update(messageByte);
            signature = obj.sig.sign();
        end
        function verified = verify(obj, message, sig)
            import java.security.*;
            signature = Signature.getInstance("SHA256withECDSA");
            signature.initVerify(obj.public_key);
            
            signature.update(uint8(message));
            verified = signature.verify(sig);
        end
    end
    
    methods(Static, Access = public) % Authenticator implementation
        function s = salt(signature)
            error("AuthenticatorECDSA:NotImplementedError","Not Implemented Yet");
        end
    end
end

