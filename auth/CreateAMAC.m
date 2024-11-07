classdef CreateAMAC

    properties

    end

    methods (Static, Access = public)

        function output = hmac_function(x, y, z)
            output = HashingWrappers.truncated_hmac_sha_256(x, y, z);
        end

        function output = time_conversion(x)
            output = DataConversions.int_to_uint8_16_array(x);
        end

        function amac = aggregate(amac_size, time, hashpoint, prn, hmacs)
            bytes = ceil(amac_size / 8);

            % Invalid Inputs
            if ~isequal(size(hmacs), [bytes, 5])
                error('CreateAMAC:invalidInput', 'Exactly 5 Hmacs required for aggregation');
            elseif mod(amac_size, 4) ~= 0
                error('CreateAMAC:invalidInput', 'Amac size must be a multiple of four');
            end

            % Create aMAC key
            time_bits_128 = CreateAMAC.time_conversion(time);
            prn = uint8(prn);

            global dual_freq %#ok
            if dual_freq
                L = uint8([17, 243, 130]); % 1176450 in bytes big endian
                mt50_str = "MT50Key";
            else
                L = uint8([24, 09, 252]); % 1575420 in bytes big endian
                mt50_str = "MT20Key";
            end

            mt50_str = uint8(char(mt50_str));

            key = HashingWrappers.hmac_sha_256(hashpoint, [mt50_str, time_bits_128', prn, L]);

            % Create concatinated hmacs
            concatenated_hmacs = zeros(20, 1);

            for i = 1:length(hmacs)
                concatenated_hmacs(i:i + bytes - 1, 1) = hmacs(:, i);
            end

            % Make the first four bits zero - for consistency
            switch amac_size
                case 32
                    % Create aMAC
                    amac = CreateAMAC.hmac_function(key, concatenated_hmacs, 4);
                case 36
                    amac = CreateAMAC.hmac_function(key, concatenated_hmacs, 5);
                    amac_bits = DataConversions.de2bi(amac, 8);
                    amac_bits = amac_bits';
                    amac = uint8(DataConversions.bi2de(reshape([zeros(1, 4), amac_bits(5:40)], 8, 5)'));
                case 28
                    amac = CreateAMAC.hmac_function(key, concatenated_hmacs, 4);
                    amac_bits = DataConversions.de2bi(amac, 8);
                    amac_bits = amac_bits';
                    amac = uint8(DataConversions.bi2de(reshape([zeros(1, 4), amac_bits(5:32)], 8, 4)'));
                otherwise
                    error('CreateAMAC:incomplete', 'This amac size has not been implemented');
            end

        end

    end
end
