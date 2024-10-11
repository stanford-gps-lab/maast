classdef MT51 < handle
    % MT51 Class related to storage, encoding, and decoding MT51 messages.

    properties
        germane_key_level
        germane_key_hash
        germane_key_expiration
        authenticating_key_hash
        payload_type
        payload_page
        payload
    end

    methods

        function obj = MT51( ...
                            germane_key_level, ...
                            germane_key_hash, ...
                            germane_key_expiration, ...
                            authenticating_key_hash, ...
                            payload_type, ...
                            payload_page, ...
                            payload)
            % Construct MT51 Instance.

            obj.germane_key_level = germane_key_level;
            obj.germane_key_hash = germane_key_hash;
            obj.germane_key_expiration = germane_key_expiration;
            obj.authenticating_key_hash = authenticating_key_hash;
            obj.payload_type = payload_type;
            obj.payload_page = payload_page;
            obj.payload = payload;
        end

        function message_bits = encode(obj)
            % Create the logical array of bits for an encoded message.

            message_bits = false(250, 1);

            % message_bits(1:4)
            message_bits(5:10) = DataConversions.de2bi(uint8(51), 6);
            message_bits(11:12) = DataConversions.de2bi(obj.germane_key_level, 2);
            message_bits(13:28) = reshape(DataConversions.de2bi(obj.germane_key_hash, 8)', [], 1);
            message_bits(29:60) = DataConversions.de2bi(obj.germane_key_expiration, 32);
            message_bits(61:76) = reshape(DataConversions.de2bi(obj.authenticating_key_hash, 8)', [], 1);
            message_bits(77:78) = DataConversions.de2bi(obj.payload_type, 2);
            message_bits(79:82) = DataConversions.de2bi(obj.payload_page, 4);
            message_bits(83:210) = reshape(DataConversions.de2bi(obj.payload, 8)', [], 1);
        end

    end

    methods (Static)

        function mt51 = decode(message)
            % construct an MT51 class instance from input logical array of bits.

            mt = DataConversions.bi2de(message(5:10)');
            if mt ~= 51
                error('MT51:BadMessageType', 'Cannot decode message type %i.', mt);
            end

            germane_key_level = DataConversions.bi2de(message(11:12)');
            germane_key_hash = uint8(DataConversions.bi2de(reshape(message(13:28), 8, 2)'));
            germane_key_expiration = uint32(DataConversions.bi2de(message(29:60)'));
            authenticating_key_hash = uint8(DataConversions.bi2de(reshape(message(61:76), 8, 2)')')';
            payload_type = uint8(DataConversions.bi2de(message(77:78)'));
            payload_page = uint8(DataConversions.bi2de(message(79:82)'));
            payload = uint8(DataConversions.bi2de(reshape(message(83:210), 8, 16)')')';
            mt51 = MT51( ...
                        germane_key_level, ...
                        germane_key_hash, ...
                        germane_key_expiration, ...
                        authenticating_key_hash, ...
                        payload_type, ...
                        payload_page, ...
                        payload);
        end

    end
end
