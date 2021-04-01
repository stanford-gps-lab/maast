classdef HashingWrappers
    % HASHINGWRAPPERS Contains static hashing methods pertinant to SBAS
    % authentication.

    methods (Static)

        function output = sha_256(input)
            import javax.crypto.*
            import java.security.MessageDigest
            mDigest = MessageDigest.getInstance("SHA-256");
            output = typecast(mDigest.digest(input), 'uint8');
        end

        function output = hmac_sha_256(input, key)
            import javax.crypto.Mac
            import javax.crypto.spec.SecretKeySpec
            m_a_c = Mac.getInstance("HmacSHA256");
            secretKeySpec = SecretKeySpec(key, "HmacSHA256");
            m_a_c.init(secretKeySpec);
            output = typecast(m_a_c.doFinal(input), 'uint8');
        end

    end
end
