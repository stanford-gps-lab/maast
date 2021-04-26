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
            message_bits(5:10) = logical(de2bi(uint8(51), 'left-msb'));
            message_bits(11:12) = logical(de2bi(obj.germane_key_level, 2, 'left-msb'));
            message_bits(13:28) = reshape(logical(de2bi(obj.germane_key_hash, 8, 'left-msb'))', [], 1);
            message_bits(29:60) = logical(de2bi(obj.germane_key_expiration, 32, 'left-msb'));
            message_bits(61:76) = reshape(de2bi(obj.authenticating_key_hash, 8, 'left-msb')', [], 1);
            message_bits(77:78) = logical(de2bi(obj.payload_type, 2, 'left-msb'));
            message_bits(79:82) = logical(de2bi(obj.payload_page, 4, 'left-msb'));
            message_bits(83:210) = reshape(logical(de2bi(obj.payload, 8, 'left-msb'))', [], 1);
        end

    end

    methods (Static)

        function mt51 = decode(message)
            % construct an MT51 class instance from input logical array of bits.

            mt = bi2de(message(5:10)', 'left-msb');
            if mt ~= 51
                error('MT51:BadMessageType', 'Cannot decode message type %i.', mt);
            end

            germane_key_level = bi2de(message(11:12)', 'left-msb');
            germane_key_hash = uint8(bi2de(reshape(message(13:28), 8, 2)', 'left-msb'));
            germane_key_expiration = uint32(bi2de(message(29:60)', 'left-msb'));
            authenticating_key_hash = uint8(bi2de(reshape(message(61:76), 8, 2)', 'left-msb')')';
            payload_type = uint8(bi2de(message(77:78)', 'left-msb'));
            payload_page = uint8(bi2de(message(79:82)', 'left-msb'));
            payload = uint8(bi2de(reshape(message(83:210), 8, 16)', 'left-msb')')';
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
