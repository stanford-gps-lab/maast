classdef AuthenticatorECDSA < Authenticator
    %AUTHENTICATORECDSA Summary of this class goes here
    %   Detailed explanation goes here
    properties(Access = private)
     sig
    end
    
    methods
        function obj = AuthenticatorECDSA(varargin)
            %AUTHENTICATORECDSA Construct an instance of this class
            %   Initializes the public, private keys, and signiture for
            %later use 
            import java.security.*;
            obj = obj@Authenticator(varargin{:});
            
            
            
            obj.sig = Signature.getInstance("SHA256withECDSA");
            obj.sig.initSign(obj.private_key);
        end
        
        function obj = AuthenticatorPublicECDSA(publicKeyByte)
            import java.security.*;
            
            kf = KeyFactory.getInstance("EC");
            obj.public_key = kf.generatePublic(X509EncodedKeySpec(publicKeyByte));
            key_spec = PKCS8EncodedKeySpec(decoded);

            obj.private_key = kf.generatePrivate(key_spec);
            
            obj.sig = Signature.getInstance("SHA256withECDSA");
            obj.sig.initSign(obj.private_key);   
        end
    end
    
    methods % Authenticator implementation
        function signature = sign(obj, message)
            %SIGN Takes in a ECDSA object and message as a uint8 array to be signed. 
            %computes the signature based on the objet and message and
            %outputs it.
            obj.sig.update(message);
            signature = obj.sig.sign();
        end
        
        function verified = verify(obj, message, sig)
            import java.security.*;
            signature = Signature.getInstance("SHA256withECDSA");
            signature.initVerify(obj.public_key);
            
            signature.update(message);
            verified = signature.verify(sig);
        end
    end
    
    methods(Static, Access = public) % Authenticator implementation
        function s = salt(signature) %#ok Function throws error
            error("AuthenticatorECDSA:NotImplementedError","Not Implemented Yet");
        end
    end
    
    methods(Access = protected, Static)
        function [private_key, public_key] = derive_random_key()
            import java.security.*;
            keyGen = KeyPairGenerator.getInstance("EC");
            keyGen.initialize(256, SecureRandom());
            
            pair = keyGen.generateKeyPair();
            private_key = pair.getPrivate();
            public_key = pair.getPublic();
        end
    end
end

