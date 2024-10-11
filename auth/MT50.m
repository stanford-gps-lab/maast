classdef MT50 < handle
    % MT50 Class related to storage, encoding, and decoding MT50 messages.

    properties (Access = public)
        HMAC_1
        HMAC_2
        HMAC_3
        HMAC_4
        HMAC_5
        hash_point
    end

    methods

        function obj = MT50(HMAC_1, HMAC_2, HMAC_3, HMAC_4, HMAC_5, hash_point)
            % Construct MT50 Instance.

            obj.HMAC_1 = HMAC_1;
            obj.HMAC_2 = HMAC_2;
            obj.HMAC_3 = HMAC_3;
            obj.HMAC_4 = HMAC_4;
            obj.HMAC_5 = HMAC_5;
            obj.hash_point = hash_point;
        end

        function hmac = get_hmac(obj, index)
            % returns HMAC coresponding to index in mt50. Throws error if
            % index isn't between 1-5
            switch index
                case 1
                    hmac = obj.HMAC_1;
                case 2
                    hmac = obj.HMAC_2;
                case 3
                    hmac = obj.HMAC_3;
                case 4
                    hmac = obj.HMAC_4;
                case 5
                    hmac = obj.HMAC_5;
                otherwise
                    error('MT50:invalidIndex', 'can not handle index outside of 1-5');
            end
        end

        function message_bits = encode(obj)
            % Create the logical array of bits for an encoded message.
            message_bits = false(250, 1);

            % message_bits(1:4)
            message_bits(5:10) = DataConversions.de2bi(uint8(50), 6);
            message_bits(11:26) = reshape(DataConversions.de2bi(obj.HMAC_1, 8)', [], 1)';
            message_bits(27:42) = reshape(DataConversions.de2bi(obj.HMAC_2, 8)', [], 1)';
            message_bits(43:58) = reshape(DataConversions.de2bi(obj.HMAC_3, 8)', [], 1)';
            message_bits(59:74) = reshape(DataConversions.de2bi(obj.HMAC_4, 8)', [], 1)';
            message_bits(75:90) = reshape(DataConversions.de2bi(obj.HMAC_5, 8)', [], 1)';
            message_bits(91:218) = reshape(DataConversions.de2bi(obj.hash_point, 8)', [], 1)';
        end

    end

    methods (Static)

        function mt50 = decode(message)
            % construct an mt50 class instance from input logical array of bits
            %
            %   message - a logical array of bits
            mt = DataConversions.bi2de(message(5:10));
            if  mt ~= 50
                error('MT50:BadMessageType', 'Cannot decode message type %i.', mt);
            end

            HMAC_1 = uint8(DataConversions.bi2de(reshape(message(11:26), 8, 2)'));
            HMAC_2 = uint8(DataConversions.bi2de(reshape(message(27:42), 8, 2)'));
            HMAC_3 = uint8(DataConversions.bi2de(reshape(message(43:58), 8, 2)'));
            HMAC_4 = uint8(DataConversions.bi2de(reshape(message(59:74), 8, 2)'));
            HMAC_5 = uint8(DataConversions.bi2de(reshape(message(75:90), 8, 2)'));
            hp = uint8(DataConversions.bi2de(reshape(message(91:218), 8, 16)'));

            mt50 = MT50(HMAC_1, HMAC_2, HMAC_3, HMAC_4, HMAC_5, hp);
        end

    end
end
