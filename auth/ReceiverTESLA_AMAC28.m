classdef ReceiverTESLA_AMAC28 < ReceiverTESLA
    methods

        function obj = ReceiverTESLA_AMAC28(varargin)
            obj@ReceiverTESLA(varargin{:});
            obj.mac_signing_function = @(x, y)HashingWrappers.padded_hmac_sha_256(x, y, 4);
            obj.mt50_decode = @(x, y)MT50_AMAC28.decode(x, y);
            obj.hmac_size = 4;
            obj.include_crc = false;
        end

        function verify_hmac_block(obj, MT50, hashpoint, time)
            hmacs = uint8(zeros(4, 5));
            flag = [1, 1, 1, 1, 1];
            hi = 0;
            hmac_count = 0;

            start = time - 5;

            for i = start:start + 4
                hi = hi + 1;
                % Skip missed messages
                if ~isKey(obj.message_table, i)
                    obj.message_table(i) = MessageTableValue('');
                    flag(hi) = 0;
                    continue
                end

                % Recreate HMACs
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
                hmac = obj.mac_signing_function(key, message.message);
                hmac_count = hmac_count + 1;

                hmacs(:, hi) = hmac;
            end

            if hmac_count < 3
                return
            elseif hmac_count < 5
                % Recover lost HMACS
                hmacs = DataRecovery.recover_data_28(hmacs, [MT50.get_datarec(1), MT50.get_datarec(2)], flag);
            end

            % Aggregate HMACs
            amac = CreateAMAC.aggregate(28, 0, MT50.hash_point, obj.prn, hmacs);

            if all(MT50.get_amac() == amac)
                % Verify all of the messages
                for i = time - 5:time - 1
                    m = obj.message_table(i);
                    m.verified = true;
                end
            else
                error('Receiver:invalidHmac', 'Unable to recover aMAC');
            end

        end

        function output = check_if_dummy_mt50(obj, message)
            output = false;

            dummy_mt50 = MT50_AMAC28(uint8(zeros(obj.hmac_size, 1)), ...
                                     uint8(zeros(obj.hmac_size, 1)), ...
                                     uint8(zeros(obj.hmac_size, 1)), ...
                                     uint8(zeros(obj.hmac_size, 1)), ...
                                     uint8(zeros(obj.hmac_size, 1)), ...
                                     uint8(zeros(16, 1)), ...
                                     0);

            if all(message.datarec_1 == dummy_mt50.datarec_1) && ...
                    all(message.datarec_2 == dummy_mt50.datarec_2)
                output = true;
            end

        end

    end
end
