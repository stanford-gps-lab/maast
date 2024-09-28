classdef ReceiverTESLA_5HMAC < ReceiverTESLA
    methods

        function obj = ReceiverTESLA_5HMAC(varargin)
            obj@ReceiverTESLA(varargin{:});
            obj.mac_signing_function = @(x, y)HashingWrappers.truncated_hmac_sha_256(x, y, 2);
            obj.mt50_decode = @(x, y)MT50_5HMAC.decode(x, y);
            obj.hmac_size = 2;
            obj.include_crc = true;
        end

        function verify_hmac_block(obj, MT50, hashpoint, time)
            % verifies the messages correspondingn 5 hmacs after reciving a
            % valid MT50 in the message table
            %
            %   MT50 - the MT50 object containig coresponding hmacs
            %   hashpoint - the hashpoint of the MT50 following MT50
            %   time - time that corespods with when MT50 was recived
            start = time - 5;

            for i = start:start + 4
                if ~isKey(obj.message_table, i)
                    obj.message_table(i) = MessageTableValue('');
                    continue
                end
                message = obj.message_table(i);
                time_bits_128 = obj.time_conversion(i);
                time_bits_4_8 = dec2bin(time_bits_128(end - 3:end), 8);
                time_bits = time_bits_4_8(:)';
                prn = dec2bin(obj.prn, 9);
                global dual_freq %#ok
                if dual_freq
                    L = dec2bin(1176450, 23);
                else
                    L = dec2bin(1575420, 23);
                end
                key = HashingWrappers.hmac_sha_256(hashpoint, [time_bits, prn, L] - '0');
                hm = obj.mac_signing_function(key, message.message);

                if all(MT50.get_hmac(i - start + 1) == hm)
                    message.verified = true;
                else
                    error('Receiver:invalidHmac', 'can not handle incorrect hmac');
                end

            end
        end

        function output = check_if_dummy_mt50(obj, message)
            output = false;
            if all(message.HMAC_1 == uint8(zeros(obj.hmac_size, 1))) && ...
                    all(message.HMAC_2 == uint8(zeros(obj.hmac_size, 1))) && ...
                    all(message.HMAC_3 == uint8(zeros(obj.hmac_size, 1))) && ...
                    all(message.HMAC_4 == uint8(zeros(obj.hmac_size, 1))) && ...
                    all(message.HMAC_5 == uint8(zeros(obj.hmac_size, 1)))
                output = true;
            end
        end

    end
end
