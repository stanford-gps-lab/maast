classdef Authenticator < handle
    %AUTHENTICATOR Contains all methods and properties pertina
    
    properties(Access=protected)
        public_key;
        private_key;
    end
    
    methods (Access=public)
        function obj = Authenticator(varargin)
            switch nargin
                case 0
                    [private_key, public_key] = obj.derive_random_key();
                    obj.public_key = public_key;
                    obj.private_key = private_key;
                case 2
                    key = varargin{1};
                    is_private_key = varargin{2};
                    if is_private_key
                        obj.private_key = key;
                        obj.public_key = obj.derive_public_key(key);
                    else
                        obj.public_key = key;
                        
                    end
                    
                otherwise
                    error('Authenticator:BadConstructorArguments', ...
                    'Authenticator Constructor must have either 0 or 2 arguments')
                    
            end
            
        end
        
    end
    methods(Abstract, Access=public)
        signature = sign(obj, message)
        verified = verify(obj, message, signature)
        
    end
    
    methods(Static, Abstract, Access=public)
        s = salt(signature)
    end
    
    methods(Abstract, Access=protected)
        public_key = derive_public_key(obj, key)
        [private_key, public_key] = derive_random_key(obj)
    end
end

