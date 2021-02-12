classdef Authenticator < handle
    %AUTHENTICATOR Contains all methods and properties pertina
    
    properties(Access=private)
        public_key;
        private_key;
    end
    
    methods(Abstract, Access=public)
        signature = sign(obj, message)
        verified = verify(obj, message, signature)
    end
    
    methods(Static, Abstract, Access=public)
        s = salt(signature)
    end
end

