classdef Authenticator < handle
    % AUTHENTICATOR Contains all methods and properties pertina

    properties (Access = protected)
        public_key
        private_key
    end

    methods (Access = public)

        function obj = Authenticator(varargin)
            % Constructs an instance of class
            % if no args: Authenticator derives a random private and public key pair
            % if 1 arg: Authenticator only has a public key and can only verify signatures

            switch nargin
                case 0
                    [private_key, public_key] = obj.derive_random_key();
                    obj.public_key = public_key;
                    obj.private_key = private_key;
                case 1
                    obj.public_key = varargin{1};
                otherwise
                    error('Authenticator:BadConstructorArguments', ...
                          'Authenticator Constructor must have 0 arguments');
            end
        end

    end
    methods (Abstract, Access = public)
        signature = sign(obj, message)
        verified = verify(obj, message, signature)
        public_key_byte = get_public_key_der(obj)
    end

    methods (Static, Abstract, Access = public)
        s = salt(signature)
    end

    methods (Static, Abstract, Access = protected)
        [private_key, public_key] = derive_random_key()
    end
end
