classdef MT50_AMAC36 < MT50
    % MT50 Class related to storage, encoding, and decoding MT50 messages.

    properties (Access = public)
        aMAC
        datarec_1
        datarec_2
        hash_point
    end

    methods

        function obj = MT50_AMAC36(HMAC1, HMAC2, HMAC3, HMAC4, HMAC5, hashpoint, time, prn)
            hmacs = [HMAC1, HMAC2, HMAC3, HMAC4, HMAC5];
            datarec = DataRecovery.generate_data_recovery_fields_36(hmacs);

            obj.aMAC = CreateAMAC.aggregate(36, time, hashpoint, prn, hmacs);
            obj.datarec_1 = datarec(:, 1);
            obj.datarec_2 = datarec(:, 2);
            obj.hash_point = hashpoint;
        end

        function amac = get_amac(obj)
            % returns aMAC in MT50
            amac = obj.aMAC;
        end

        function datarec = get_datarec(obj, index)
            % returns data recovery integer according to index.
            % produces an error if the index is invalid
            switch index
                case 1
                    datarec = obj.datarec_1;
                case 2
                    datarec = obj.datarec_2;
                otherwise
                    error('MT50_AMAC:invalidIndex', 'can not handle index outside of 1-2');
            end
        end

        function message_bits = encode(obj)
            % Create the logical array of bits for an encoded message.
            message_bits = false(250, 1);

            amac_bits = DataConversions.de2bi(obj.aMAC, 8);
            amac_bits = amac_bits';
            amac_bits = amac_bits(5:end);

            datarec1_bits = DataConversions.de2bi(obj.datarec_1, 8);
            datarec1_bits = datarec1_bits';
            datarec1_bits = datarec1_bits(5:end);

            datarec2_bits = DataConversions.de2bi(obj.datarec_2, 8);
            datarec2_bits = datarec2_bits';
            datarec2_bits = datarec2_bits(5:end);

            % message_bits(1:4)

            message_bits(5:10) = DataConversions.de2bi(uint8(50), 6);
            message_bits(11:46) = amac_bits(:);
            message_bits(47:82) = datarec1_bits(:);
            message_bits(83:118) = datarec2_bits(:);
            message_bits(119:246) = reshape(DataConversions.de2bi(obj.hash_point, 8)', [], 1)';
        end

    end

    methods (Static)

        function mt50 = decode(message, time, prn)
            % construct an mt50 class instance from input logical array of bits
            %
            %   message - a logical array of bits
            mt = DataConversions.bi2de(message(5:10));
            if  mt ~= 50
                error('MT50_AMAC:BadMessageType', 'Cannot decode message type %i.', mt);
            end

            aMAC = uint8(DataConversions.bi2de(reshape([zeros(1, 4), message(11:46)], 8, 5)'));
            datarec_1 = uint8(DataConversions.bi2de(reshape([zeros(1, 4), message(47:82)], 8, 5)'));
            datarec_2 = uint8(DataConversions.bi2de(reshape([zeros(1, 4), message(83:118)], 8, 5)'));
            hash_point = uint8(DataConversions.bi2de(reshape(message(119:246), 8, 16)'));

            mt50 = MT50_AMAC36(aMAC, aMAC, aMAC, aMAC, aMAC, hash_point, time, prn);
            mt50.aMAC = aMAC;
            mt50.datarec_1 = datarec_1;
            mt50.datarec_2 = datarec_2;

        end

    end
end
