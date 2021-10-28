classdef AuthenticatorECDSA < handle
    % AUTHENTICATORECDSA Summary of this class goes here
    %   Detailed explanation goes here
    properties (SetAccess = protected)
        sig
        algo
        public_key
        private_key
    end

    properties (Constant, Hidden)
        valid_algorithms = ["SHA256withECDSA", "SHA384withECDSA", "SHA512withECDSA"]
    end

    methods

        function obj = AuthenticatorECDSA(varargin)
            % AUTHENTICATORECDSA Construct an instance of this class
            %   Initializes the public, private keys, and signiture for
            % later use
            import java.security.*

            switch nargin
                case 0
                    obj.algo = "SHA256withECDSA";
                    [private_key, public_key] = obj.derive_random_key(str2double(obj.algo.extractBetween(4, 6)));
                    obj.public_key = public_key;
                    obj.private_key = private_key;
                case 1
                    if isa(varargin{1}, 'string')
                        if ismember(varargin{1}, AuthenticatorECDSA.valid_algorithms)
                            obj.algo = varargin{1};
                            [private_key, public_key] = obj.derive_random_key(str2double ...
                                                                              (obj.algo.extractBetween(4, 6)));
                            obj.public_key = public_key;
                            obj.private_key = private_key;
                        else
                            error('Authenticator:invalidAlgo', 'must provide valid hashing algo');
                        end
                    else
                        obj.algo = DERMethods.check_der_type(varargin{1});
                        obj.public_key = sun.security.ec.ECPublicKeyImpl(varargin{1});
                    end
                case 2
                    obj.algo = DERMethods.check_der_type(varargin{1});
                    obj.public_key = sun.security.ec.ECPublicKeyImpl(varargin{1});

                    if obj.algo ~= varargin{2}
                        error('Authenticator:derAndAlgoMismatch', 'must provide compatable der and algo');
                    end
                otherwise
                    error('Authenticator:invalidArgs', 'must provide valid args');
            end

            if ~isempty(obj.private_key)
                obj.sig = Signature.getInstance(obj.algo);
                obj.sig.initSign(obj.private_key);
            end
        end

    end

    methods % Authenticator implementation

        function signature = sign(obj, message)
            % SIGN Takes in a ECDSA object and message as a uint8 array to be signed.
            % computes the signature based on the objet and message and
            % outputs it.

            if isempty(obj.private_key)
                error('AuthenticatorECDSA:NoPrivateKey', 'Cannot sign message without private key.');
            end

            obj.sig.update(message);
            signature = typecast(obj.sig.sign(), 'uint8');
        end

        function verified = verify(obj, message, sig)
            import java.security.*
            signature = Signature.getInstance(obj.algo);
            signature.initVerify(obj.public_key);

            signature.update(message);
            verified = signature.verify(sig);
        end

        function public_key_byte = get_public_key_der(obj)
            % gets public key in DER format
            public_key_byte = typecast(obj.public_key.encode(), 'uint8');
        end

    end

    methods (Static, Access = public) % Authenticator implementation

        function s = salt(signature) %#ok Function throws error
            error("AuthenticatorECDSA:NotImplementedError", "Not Implemented Yet");
        end

    end

    methods (Access = protected, Static)

        function [private_key, public_key] = derive_random_key(length)
            import java.security.*
            if length == 512
                length = 521;
            end
            keyGen = KeyPairGenerator.getInstance("EC");
            keyGen.initialize(length, SecureRandom());

            pair = keyGen.generateKeyPair();
            private_key = pair.getPrivate();
            public_key = pair.getPublic();
        end

    end
end
