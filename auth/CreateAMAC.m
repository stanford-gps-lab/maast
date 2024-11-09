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
            time_bits_4_8 = dec2bin(time_bits_128(end - 3:end), 8);
            time_bits = time_bits_4_8(:)';
            prn = dec2bin(prn, 9);

            global dual_freq %#ok
            if dual_freq
                L = dec2bin(1176450, 23);
                mt50_str = "MT50Key";
            else
                L = dec2bin(1575420, 23);
                mt50_str = "MT20Key";
            end

            mt50_str = char(mt50_str);
            mt_bits = dec2bin(mt50_str, 8);
            mt_bits = mt_bits';

            hashpoint_bits = dec2bin(hashpoint, 8);
            hashpoint_bits = hashpoint_bits';

            key_prior = [mt_bits, hashpoint_bits];
            key_prior = uint8(bin2dec(reshape(key_prior, 8, [])'));

            key = HashingWrappers.hmac_sha_256(key_prior, DataConversions.logicalToUint8([time_bits, prn, L] - '0'));

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
