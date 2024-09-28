classdef SBASKeyStack < handle
    % SBASKeyStack Class to store the current and next set of authenticating SBASKeys.
    %   This class contains the methods that pertain to storing a set of level-1, level-2, and level-3 SBAS Keys
    %   necessary to authenticate SBAS messages.

    properties (SetAccess = protected)
        current_level_1_authenticator
        current_level_2_authenticator
        next_level_1_authenticator
        next_level_2_authenticator
        queued_hash_path_end
        queued_hash_path_end_expiration_time
    end

    properties (SetAccess = protected, GetAccess = public)
        current_mt51_set
        next_mt51_set

        current_level_1_key
        current_level_2_key
        current_level_3_key

        next_level_1_key
        next_level_2_key
        next_level_3_key

        level_1_crypto_period_s = 60480006
        level_2_crypto_period_s = 6048006
        level_3_crypto_period_s = 604806
    end

    methods

        function obj = SBASKeyStack(current_time, current_hash_path_end, next_hash_path_end, ...
                                    level_1_crypto_period_s, level_2_crypto_period_s, level_3_crypto_period_s)

            switch nargin
                case 3
                case 6
                    obj.level_1_crypto_period_s = level_1_crypto_period_s;
                    obj.level_2_crypto_period_s = level_2_crypto_period_s;
                    obj.level_3_crypto_period_s = level_3_crypto_period_s;
                otherwise
                    error('SBASKeyStack:BadConstructorArguments', 'Received incorrect number of arguments.');
            end

            % create an instance of the class

            % create a new set of level-1 SBAS keys
            obj.rotate_level_1(current_time + obj.level_1_crypto_period_s);
            obj.rotate_level_1(current_time + 2 * obj.level_1_crypto_period_s);

            % create a new set of level-2 SBAS keys
            obj.rotate_level_2(current_time + obj.level_2_crypto_period_s);
            obj.rotate_level_2(current_time + 2 * obj.level_2_crypto_period_s);

            % create a new set of level-3 SBAS keys
            obj.rotate_level_3(current_time + obj.level_3_crypto_period_s, current_hash_path_end);
            obj.rotate_level_3(current_time + 2 * obj.level_3_crypto_period_s, next_hash_path_end);

            % update the mt51 message sets
            obj.update_mt51_sets();
        end

        function update_stack(obj, current_time)
            % checks expiration time of all keys and rotates them as necessary

            % flag to track whether any keys were rotated
            update_flag = false;

            % check expiration of level-1 key and rotate if necessary
            if obj.current_level_1_key.expiration_time <= current_time
                obj.rotate_level_1(current_time + 2 * obj.level_1_crypto_period_s);
                update_flag = true;
            end

            % check expiration of level-2 key and rotate if necessary
            if obj.current_level_2_key.expiration_time <= current_time
                obj.rotate_level_2(current_time + 2 * obj.level_2_crypto_period_s);
                update_flag = true;
            end

            % check expiration of level-3 key and rotate if necessary
            if obj.current_level_3_key.expiration_time <= current_time

                % check if there is a queued hash path end, otherwise throw error
                if isempty(obj.queued_hash_path_end) || isempty(obj.queued_hash_path_end_expiration_time)
                    error('SBASKeyStack:NoQueuedHashPathEnd', ...
                          'Key stack attempted to rotate a new hash path end but no hash path end available to queue.');
                end

                obj.rotate_level_3(obj.queued_hash_path_end_expiration_time, obj.queued_hash_path_end);
                update_flag = true;

                % clear queue
                obj.queued_hash_path_end = [];
                obj.queued_hash_path_end_expiration_time = [];
            end

            % update mt51 set if any keys were rotated
            if update_flag
                obj.update_mt51_sets();
            end
        end

        function disp(obj)
            % Display the keys of this instance.
            fprintf('Keys in this KeyStack\n');
            for key = {obj.current_level_1_key, ...
                       obj.next_level_1_key, ...
                       obj.current_level_2_key, ...
                       obj.next_level_2_key, ...
                       obj.current_level_3_key, ...
                       obj.next_level_3_key}
                fprintf('Level %i [%3i %3i] expires %i\n', ...
                        key{1}.level, ...
                        key{1}.key_short_hash(1), ...
                        key{1}.key_short_hash(2), ...
                        key{1}.expiration_time);
            end
        end

        function queue_hash_path_end(obj, next_hash_path_end, expiration_time)
            % Set the queued hash path end to prepare for the next level-3 SBAS key rotation
            obj.queued_hash_path_end = next_hash_path_end;
            obj.queued_hash_path_end_expiration_time = expiration_time;
        end

    end

    methods (Access = protected)

        function update_mt51_sets(obj)
            % Recompute the set of MT51 messages based on the stored keys.
            obj.current_mt51_set = [ ...
                                    obj.current_level_1_key.mt51_set(); ...
                                    obj.current_level_2_key.mt51_set(); ...
                                    obj.current_level_3_key.mt51_set() ...
                                   ];
            obj.next_mt51_set = [ ...
                                 obj.next_level_1_key.mt51_set(); ...
                                 obj.next_level_2_key.mt51_set(); ...
                                 obj.next_level_3_key.mt51_set() ...
                                ];
        end

        function rotate_level_1(obj, next_expiration_time)
            % pops current level 1 key and adds a new random one to the next one

            % rotate authenticators
            obj.current_level_1_authenticator = obj.next_level_1_authenticator;
            obj.next_level_1_authenticator = AuthenticatorECDSA();

            % rotate_keys
            obj.current_level_1_key = obj.next_level_1_key;
            obj.next_level_1_key = obj.make_key(1, obj.next_level_1_authenticator, next_expiration_time);
        end

        function rotate_level_2(obj, next_expiration_time)
            % pops current level 2 key and adds a new random one to the next one

            % rotate authenticators
            obj.current_level_2_authenticator = obj.next_level_2_authenticator;
            obj.next_level_2_authenticator = AuthenticatorECDSA();

            % if next expiration time is beyond level 1 expiry, then use
            % next level 1
            if next_expiration_time < obj.current_level_1_key.expiration_time
                level_1_authenticator = obj.current_level_1_authenticator;
            else
                level_1_authenticator = obj.next_level_1_authenticator;
            end

            % rotate_keys
            obj.current_level_2_key = obj.next_level_2_key;
            obj.next_level_2_key = obj.make_key(2, obj.next_level_2_authenticator, next_expiration_time, ...
                                                level_1_authenticator);
        end

        function rotate_level_3(obj, next_expiration_time, new_hash_path)
            % pops current level 3 key and adds a new random one to the next one

            % rotate_keys
            obj.current_level_3_key = obj.next_level_3_key;

            % if next expiration time is beyond level 2 expiry, then use
            % next level 2
            if next_expiration_time < obj.current_level_2_key.expiration_time
                level_2_authenticator = obj.current_level_2_authenticator;
            else
                level_2_authenticator = obj.next_level_2_authenticator;
            end

            obj.next_level_3_key = obj.make_hash_path_end(new_hash_path, ...
                                                          next_expiration_time, ...
                                                          level_2_authenticator);
        end

    end

    methods (Static, Access = protected)

        function key = make_key(level, authenticator, expiration_time, authenticator_level_up)
            % Helper function to make SBAS keys from input data.

            % remove DER encoded headers to get naked public key
            public_key = DERMethods.DER2PK(authenticator.get_public_key_der(), 'ECDSA256');

            % derive abridged hash for associating purposes
            key_short_hash = HashingWrappers.truncated_sha_256(public_key, 2);

            % if key must be authenticated by another key
            if nargin == 4
                level_up_key = DERMethods.DER2PK(authenticator_level_up.get_public_key_der(), 'ECDSA256');
                auth_short_hash = HashingWrappers.truncated_sha_256(level_up_key, 2);
            else
                auth_short_hash = [];
            end

            key = SBASKey(level, key_short_hash, expiration_time, auth_short_hash, public_key);

            % if key must be authenticated by another key
            if nargin == 4
                key.signature = DERMethods.DER2SIG(authenticator_level_up.sign(key.signing_data()), 'ECDSA256');
            end
        end

        function key = make_hash_path_end(hash, expiration_time, level_2_authenticator)
            % Helper function to make SBAS keys from input data.
            level = 3;
            key_short_hash = HashingWrappers.truncated_sha_256(hash, 2);
            level_2_public_key = DERMethods.DER2PK(level_2_authenticator.get_public_key_der(), 'ECDSA256');
            auth_short_hash = HashingWrappers.truncated_sha_256(level_2_public_key, 2);
            key = SBASKey(level, key_short_hash, expiration_time, auth_short_hash, hash);
            key.signature = DERMethods.DER2SIG(level_2_authenticator.sign(key.signing_data()), 'ECDSA256');
        end

    end
end
