classdef AuthenticatorECDSA < Authenticator
    %AUTHENTICATORECDSA Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = AuthenticatorECDSA()
            %AUTHENTICATORECDSA Construct an instance of this class
            %   Detailed explanation goes here
        end
    end
    
    methods % Authenticator implementation
        function signature = sign(obj, message)
            error("AuthenticatorECDSA:NotImplementedError","Not Implemented Yet");
        end
        function verified = verify(obj, message, signature)
            error("AuthenticatorECDSA:NotImplementedError","Not Implemented Yet");
        end
    end
    
    methods(Static, Access = public) % Authenticator implementation
        function s = salt(signature)
            error("AuthenticatorECDSA:NotImplementedError","Not Implemented Yet");
        end
    end
end

