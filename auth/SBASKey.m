classdef SBASKey < handle
    % Class SBASKey contains all methods pertaining to storing an asymmetric key or hash path end with the associated
    % meta data (e.g., expiration, signature from another key) inside a SBASKeyStateMachine object.

    properties
        level % The key level of this key.
        key_short_hash % An abridged hash to identify this key.
        key % The uint8 array of the key itself.
        expiration_time % the POSIX time of key expiration
        authenticating_key_short_hash % An abridged hash to identify the key that generated the signature.
        signature % The uint8 array of the signature of by the key identified by the authenticating key short hash.
    end

    methods

        function obj = SBASKey(level, key_short_hash, expiration_time, authenticating_key_short_hash, key, signature)
            % construct an instance of the class

            obj.level = level;
            obj.key_short_hash = key_short_hash;
            obj.expiration_time = expiration_time;

            if isempty(authenticating_key_short_hash)
                authenticating_key_short_hash = zeros(2, 1, 'uint8');
            end
            obj.authenticating_key_short_hash = authenticating_key_short_hash;

            switch obj.level
                case 1
                    obj.key = zeros(64, 1, 'uint8');
                    obj.signature = [];
                case 2
                    obj.key =  zeros(64, 1, 'uint8');
                    obj.signature = uint8(randi([0, 255], 64, 1));
                case 3
                    obj.key = zeros(16, 1, 'uint8');
                    obj.signature = uint8(randi([0, 255], 64, 1));
                otherwise
                    error('SBASKey:InvalidKeyLevel', 'Received key level %i, which is not 1 or 2.', level);
            end

            if nargin > 4
                if length(key) ~= length(obj.key)
                    error('SBASKey:BadConstructorArguments', 'SBASKey-length not valid.');
                end
                obj.key = key;
            end

            if nargin > 5
                if length(signature) ~= length(obj.signature)
                    error('SBASKey:BadConstructorArguments', 'Signature-length not valid.');
                end
                obj.signature = signature;
            end
        end

        function set_key_page(obj, page, key_page)
            % set the key data of the input page

            indices = 1 + (page - 1) * 16:page * 16;
            obj.key(indices) = key_page;
        end

        function set_signature_page(obj, page, signature_page)
            % set the signature data of the input page

            indices = 1 + (page - 1) * 16:page * 16;
            obj.signature(indices) = signature_page;
        end

        function boolean = eq(key1, key2)
            % returns true if two input keys represent the same key information, otherwise false.

            boolean = false;
            if ~all(key1.level == key2.level)
                return
            end
            if ~all(key1.key_short_hash == key2.key_short_hash)
                return
            end
            if ~all(key1.key == key2.key)
                return
            end
            if ~all(key1.expiration_time == key2.expiration_time)
                return
            end
            if ~all(key1.authenticating_key_short_hash == key2.authenticating_key_short_hash)
                return
            end
            if ~all(key1.signature == key2.signature)
                return
            end

            boolean = true;
        end

        function data = signing_data(obj)
            % Computes logical array of data the must be signed by asymmetric method for complete security

            data = false(66 + 8 * length(obj.key), 1);
            data(1:2) = DataConversions.de2bi(obj.level, 2);
            data(3:18) = reshape(DataConversions.de2bi(obj.key_short_hash, 8), [], 1);
            data(19:50) = DataConversions.de2bi(obj.expiration_time, 32);
            data(51:66) = reshape(DataConversions.de2bi(obj.authenticating_key_short_hash, 8), [], 1);
            data(67:end) = reshape(DataConversions.de2bi(obj.key, 8), [], 1);
        end

        function mt51_set = mt51_set(obj)
            % generates the complete set of MT51 objects for the messages that must be sent to OTAR

            number_of_key_messages = length(obj.key) * 8 / 128;
            key_mt51_set = MT51.empty(number_of_key_messages, 0);
            for i = 1:number_of_key_messages
                key_mt51_set(i) = MT51( ...
                                       obj.level, ...
                                       obj.key_short_hash, ...
                                       obj.expiration_time, ...
                                       obj.authenticating_key_short_hash, ...
                                       0, ...
                                       i, ...
                                       obj.key(1 + (i - 1) * 16:i * 16));
            end

            number_of_signature_messages = length(obj.signature) * 8 / 128;
            signature_mt51_set = MT51.empty(number_of_signature_messages, 0);
            for i = 1:number_of_signature_messages
                signature_mt51_set(i) = MT51( ...
                                             obj.level, ...
                                             obj.key_short_hash, ...
                                             obj.expiration_time, ...
                                             obj.authenticating_key_short_hash, ...
                                             1, ...
                                             i, ...
                                             obj.signature(1 + (i - 1) * 16:i * 16));
            end

            mt51_set = [key_mt51_set'; signature_mt51_set'];
        end

    end
end
