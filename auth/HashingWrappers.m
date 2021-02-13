classdef HashingWrappers
    %HASHINGWRAPPERS Contains static hashing methods pertinant to SBAS
    %authentication.
    
    methods(Static)
        function output = sha_256(input)
            import javax.crypto.*;
            import java.security.MessageDigest;  
            mDigest = MessageDigest.getInstance("SHA-256");
            output = typecast(mDigest.digest(input), 'uint8');
        end
        function output = hmac_sha_256(input)
            error("HashingWrappers:NotImplementedError","Not Implemented Yet");
        end
    end
end
