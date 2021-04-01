classdef Authenticator < handle
    % AUTHENTICATOR Contains all methods and properties pertina

    properties (Access = protected)
        public_key
        private_key
    end

    methods (Access = public)

        function obj = Authenticator(varargin)
            switch nargin
                case 0
                    [private_key, public_key] = obj.derive_random_key();
                    obj.public_key = public_key;
                    obj.private_key = private_key;
                otherwise
                    error('Authenticator:BadConstructorArguments', ...
                          'Authenticator Constructor must have 0 arguments');
            end
        end

    end
    methods (Abstract, Access = public)
        signature = sign(obj, message)
        verified = verify(obj, message, signature)
    end

    methods (Static, Abstract, Access = public)
        s = salt(signature)
    end

    methods (Static, Abstract, Access = protected)
        [private_key, public_key] = derive_random_key()
    end
end
