classdef SenderTESLA < handle
    % SENDER_NOTARY Summary of this class goes here
    %   Detailed explanation goes here

    properties (Access = public)
        key_chain_length = 100
        key_disclosure_delay = 5
        key_chain_function = @(x)HashingWrappers.truncated_sha_256(x, 16)
        hmac_function = @(x, y)HashingWrappers.truncated_hmac_sha_256(x, y, 2)
        key_chain
        next_key_chain
    end

    properties (Access = private)
        sending_interval
        current_block = 1
        time_now
        time_start
        message_count = 0
        hmac_num = 0
        stored_block = cell(1, 6)
    end

    methods

        function obj = SenderTESLA(hash_path_length)
            if nargin > 0
                obj.key_chain_length = hash_path_length;
            end
            obj.stored_block{6} = [];
            obj.key_chain = obj.build_new_keychain;
            obj.next_key_chain = obj.build_new_keychain;
        end

        function m = load_new_message(obj, message, time)
            obj.message_count = obj.message_count + 1;
            obj.hmac_num = obj.hmac_num + 1;

            if obj.key_chain_length - obj.current_block <= 0
                obj.stored_block{6} = obj.key_chain{1};
                obj.rotate_hash_path();
                obj.current_block = 1;
            end

            % HMAC geration
            key = obj.key_chain{end - obj.current_block};
            key = xor(key, time);
            HMAC = obj.hmac_function(message, key);

            % store HMAC for future M50
            obj.stored_block{obj.hmac_num} = HMAC;
            if obj.hmac_num == 5
                obj.hmac_num = 0;
                m = obj.build_tesla_message;
            else
                m = [];
            end
        end

        function message_obj = build_tesla_message(obj)
            if isempty(obj.stored_block{6})
                MT_50 = MT50(obj.stored_block{1}, ...
                             obj.stored_block{2}, ...
                             obj.stored_block{3}, ...
                             obj.stored_block{4}, ...
                             obj.stored_block{5}, ...
                             obj.key_chain{end - obj.current_block + 1});
            else
                MT_50 = MT50(obj.stored_block{1}, ...
                             obj.stored_block{2}, ...
                             obj.stored_block{3}, ...
                             obj.stored_block{4}, ...
                             obj.stored_block{5}, ...
                             obj.stored_block{6});
                obj.stored_block{6} = [];
            end

            obj.current_block = obj.current_block + 1;
            message_obj = MT_50;

        end

        function keychain = build_new_keychain(obj)
            % build new key chain

            random_secret = obj.random_uint8_array();

            keychain = cell(1, obj.key_chain_length);
            keychain{1} = random_secret;

            for i = 1:obj.key_chain_length - 1
                keychain{i + 1} = obj.key_chain_function(keychain{i});
            end
        end

        function hash_point = get_hash_path_end(obj)
            hash_point = obj.key_chain{end};
        end

        function hash_point = get_next_hash_path_end(obj)
            hash_point = obj.next_key_chain{end};
        end

        function rotate_hash_path(obj)
            obj.key_chain = obj.next_key_chain;
            obj.next_key_chain = obj.build_new_keychain;
        end

    end

    methods (Access = public, Static)

        function array = random_uint8_array()
            array = uint8(randi([0, 255], 16, 1));
        end

        function array = copy_keychain(key)
            array = cell(1, 100);
            array{1} = key{1};
            for i = 1:99
                array{i + 1} = HashingWrappers.sha_256(array{i});
            end
        end

    end
end
