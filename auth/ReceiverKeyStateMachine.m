classdef ReceiverKeyStateMachine < handle
    % ReceiverKeyStateMachine Class that processes MT51 messages to maintain a receiver key state machine to track
    % receipt and authenticity of SBAS keys. This class stores and validates the level-1, level-2, and TESLA Hash Path
    % Ends.

    properties (SetAccess = protected, GetAccess = public)
        level_1_keys
        level_2_keys
        level_3_keys
    end

    methods

        function obj = ReceiverKeyStateMachine()
            % Construct an instance of this class

            % initialize data structures of keys
            obj.level_1_keys = containers.Map();
            obj.level_2_keys = containers.Map();
            obj.level_3_keys = containers.Map();
        end

        function process_mt51(obj, mt51)
            % Processes data from input mt51 into state machine.

            % recall map relevant to input data
            relevant_container = obj.get_relevant_container(mt51.germane_key_level);

            % convert relevant short hash for format readable my relevant map
            short_hash = obj.uint8_to_char(mt51.germane_key_hash);

            % if key is not in relevant map, then add it
            if ~relevant_container.isKey(short_hash)
                relevant_container(short_hash) = SBASKey(mt51.germane_key_level, mt51.germane_key_hash, ...
                                                         mt51.germane_key_expiration, mt51.authenticating_key_hash);
            end

            % set the input payload data
            relevant_key = relevant_container(short_hash);
            switch mt51.payload_type
                case 0
                    relevant_key.set_key_page(mt51.payload_page, mt51.payload);
                case 1
                    relevant_key.set_signature_page(mt51.payload_page, mt51.payload);
                otherwise
                    error('ReceiverKeyStateMachine:NotImplementedPayloadType', ...
                          'Processing payload type %i, which is not 0 or 1', mt51.payload_type);
            end
        end

        function current_key = get_current_key(obj, level, current_time)
            % Retrieves current key among all of them.

            % initialize function output
            current_key = [];

            % recall map relevant to input level
            relevant_container = obj.get_relevant_container(level);

            % get cell array of all keys in map
            keys = relevant_container.values;

            % return empty if no keys stored
            if isempty(keys)
                return
            end

            % find the key with the soonest expiration date that has not yet expired
            for i = 1:length(keys)
                if current_time > keys{i}.expiration_time % skip if key expired
                    obj.purge_expired_keys(current_time);
                    continue
                elseif isempty(current_key) % set if no key yet found that is no expired
                    current_key = keys{i};
                elseif keys{i}.expiration_time < current_key.expiration_time % replace if not expired with sooner expiry
                    current_key = keys{i};
                end
            end
        end

        function next_key = get_next_key(obj, level)
            % Retrieves next key among all of them.

            % initialize function output
            next_key = [];

            % recall map relevant to input level
            relevant_container = obj.get_relevant_container(level);

            % get cell array of all keys in map
            keys = relevant_container.values;

            % return empty if no keys stored
            if length(keys) < 2
                return
            end

            % retreive next key after next expiry
            expiration_times = cellfun(@(x) x.expiration_time, keys);
            expiration_times(min(expiration_times) == expiration_times) = Inf;
            [~, next_key_index] = min(expiration_times);
            next_key = keys{next_key_index};
        end

        function key = get_key(obj, level, hash)
            % Retrieves key of input level from has provided it exists and has not expired.

            hash_char = obj.uint8_to_char(hash);

            % initialize function output
            key = [];

            % recall map relevant to input level
            relevant_container = obj.get_relevant_container(level);

            % if key not present, return empty; otherwise, grab key
            if ~isKey(relevant_container, hash_char)
                return
            end

            % grab key
            key = relevant_container(hash_char);
        end

        function boolean = full_stack_authenticated(obj, current_time, hash_path_end)
            % Returns true if there exists a complete set of keys with authenticating signatures on the input hash path
            % end at the input time; otherwise, returns false.

            boolean = false;

            % purge all expired keys
            obj.purge_expired_keys(current_time);

            % recall current set of keys
            if nargin == 2
                level_3_key = obj.get_current_key(3, current_time);
            else
                hash_path_end_short_hash = HashingWrappers.truncated_sha_256(hash_path_end, 2);
                level_3_key = obj.get_key(3, hash_path_end_short_hash);
            end
            if isempty(level_3_key)
                return
            else
                level_2_key = obj.get_key(2, level_3_key.authenticating_key_short_hash);
            end
            if isempty(level_2_key)
                return
            else
                level_1_key = obj.get_key(1, level_2_key.authenticating_key_short_hash);
            end
            if isempty(level_1_key)
                return
            end

            % check that signature on level-2 from level-1 key
            ae_level_1 = AuthenticatorECDSA(DERMethods.PK2DER(level_1_key.key, "ECDSA256"));
            if ~ae_level_1.verify(level_2_key.signing_data(), DERMethods.SIG2DER(level_2_key.signature, "ECDSA256"))
                return
            end

            % check that signature on level-3 from level-2 key
            ae_level_2 = AuthenticatorECDSA(DERMethods.PK2DER(level_2_key.key, "ECDSA256"));
            if ~ae_level_2.verify(level_3_key.signing_data(), DERMethods.SIG2DER(level_3_key.signature, "ECDSA256"))
                return
            end

            boolean = true;
        end

        function disp(obj)
            % Display keys in this ReceiverKeyStateMachine.
            fprintf('Keys in this ReceiverKeyStateMachine\n');
            for key_table = {obj.level_1_keys, obj.level_2_keys, obj.level_3_keys}
                keys = key_table{1}.values;
                for key = keys
                    fprintf('Level %i [%3i %3i] expires %i\n', ...
                            key{1}.level, ...
                            key{1}.key_short_hash(1), ...
                            key{1}.key_short_hash(2), ...
                            key{1}.expiration_time);
                end
            end

        end

    end
    methods (Static, Access = protected)

        function char_array = uint8_to_char(uint8_array)
            % convert uint8 array to hex char array
            char_array = reshape(dec2hex(uint8_array), 1, []);
        end

    end
    methods (Access = protected)

        function relevant_container = get_relevant_container(obj, level)
            % returns the relevant map that stores the keys of input level
            switch level
                case 1
                    relevant_container = obj.level_1_keys;
                case 2
                    relevant_container = obj.level_2_keys;
                case 3
                    relevant_container = obj.level_3_keys;
            end
        end

        function purge_expired_keys(obj, current_time, level)
            % Removes all expired keys of input level (or all levels if no input level provided).

            if nargin == 2
                % if no level specified, purge all 3 levels
                for i = 1:3
                    obj.purge_expired_keys(current_time, i);
                end
            else
                % recall map relevant to input level
                relevant_container = obj.get_relevant_container(level);

                % get cell array of all keys in map
                keys = relevant_container.values;

                % find the key with the soonest expiration date that has not yet expired
                for i = 1:length(keys)
                    if current_time >= keys{i}.expiration_time % skip if key expired
                        remove(relevant_container, obj.uint8_to_char(keys{i}.key_short_hash));
                    end
                end
            end
        end

    end

end
