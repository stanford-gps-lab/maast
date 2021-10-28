classdef ReceiverTESLA < handle
    % RECEIVERTESLA Class Responsible for receiving and verifying messages

    properties (SetAccess = protected)
        hash_path_function = @(x, t) ReceiverTESLA.hash_path_func(x, t)
        mac_signing_function = @(x, y)HashingWrappers.truncated_hmac_sha_256(x, y, 2)
        time_conversion = @(x)DataConversions.int_to_uint8_16_array(x)
        message_table % stores all recieved messages k = time and v = message + verified
        next_hash_path_end % stores the next end of hash path
        reciever_hash_path_end % stores end of hash path from mt51
    end

    properties (Access = private)
        mt50_table % stores verified mt50s
        missing_mt50 = {} % stores missed mt50s to go back and try verfiy
        pre_hash_mt50s = {} % stores mt50s recieved before the first hash point
        verified_hash_point_cache % hash point that is verified against hash path end for efficient verification
        max_hash_path_length = 100801
    end

    methods

        function obj = ReceiverTESLA(varargin)
            % Constructs a receiver and initializes its hash path ends to
            % passed in parameters. Initializes storage spaces for
            % messages.
            switch nargin
                case 0
                    obj.reciever_hash_path_end = [];
                    obj.next_hash_path_end = [];
                case 1
                    obj.reciever_hash_path_end = varargin{1};
                    obj.next_hash_path_end = [];
                case 2
                    obj.reciever_hash_path_end = varargin{1};
                    obj.next_hash_path_end = varargin{2};
                case 3
                    obj.reciever_hash_path_end = varargin{1};
                    obj.next_hash_path_end = varargin{2};
                    obj.max_hash_path_length = varargin{3};
                otherwise
                    error('Receiver:badConstructorArgs', 'Invalid constructor args');
            end

            obj.message_table = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
            obj.mt50_table = containers.Map('KeyType', 'uint32', 'ValueType', 'any');

            obj.verified_hash_point_cache = obj.reciever_hash_path_end;

        end

        function clear_mt50_list(obj)
            % Once the level 3 SBAS key is verified, this function passes
            % all the mt50s that were stored before the level 3 key was
            % passed to add_message_mt50
            while ~isempty(obj.pre_hash_mt50s)
                m = obj.pre_hash_mt50s{end};
                message = m{1};
                % Checks to make sure message isnt a dummy mt50 sent by the
                % sender on incorrect calls to get_mt50 inside of MAAST
                % simulation
                if all(message.HMAC_1 == uint8(zeros(2, 1))) && ...
                    all(message.HMAC_2 == uint8(zeros(2, 1))) && ...
                    all(message.HMAC_3 == uint8(zeros(2, 1))) && ...
                    all(message.HMAC_4 == uint8(zeros(2, 1))) && ...
                    all(message.HMAC_5 == uint8(zeros(2, 1)))

                    obj.pre_hash_mt50s(end) = [];
                else
                    time = m{2};
                    obj.pre_hash_mt50s(end) = [];
                    obj.add_message_mt50(message, time);
                end
            end

        end

        function add_message_mt50(obj, message, time)
            % Processes mt50s added to the reciver and verifies them
            %
            %   message - the mt50 object passed in
            %   time - time at which the mt50 is recieved
            if isempty(obj.reciever_hash_path_end)
                obj.pre_hash_mt50s{end + 1} = {message, time};
            else
                obj.clear_mt50_list;
                if all(message.hash_point == zeros(16, 1)) || obj.verify_mt50(message, time)
                    obj.verify_missed_mt50_hp;
                    % modify the entire message table
                    m = obj.message_table(time);
                    m.verified = true;
                    % add mt_50 to the mt50 table
                    mt50_num = idivide(uint32(time), 6);
                    obj.mt50_table(mt50_num) ...
                        = {message, time};
                    if isKey(obj.mt50_table, mt50_num - 1)
                        hash = message.hash_point;

                        mt50 = obj.mt50_table(mt50_num - 1);
                        m = mt50{1};
                        t = mt50{2};

                        obj.verify_hmac_block(m, hash, t);
                    else
                        obj.missing_mt50{end + 1} = mt50_num - 1;
                    end
                end
            end
        end

        function add_message(obj, message, time)
            % Responsible for adding messages into reciever message_table. If message is
            % mt50 then it passes it to add_message_mt50.
            %
            % message - 250 bit binary string
            % time - time as uint8
            message_logical = message == '1';
            message_uint8 = DataConversions.binary_string_to_uint8(message);
            obj.message_table(time) = MessageTableValue(message_uint8);

            if DataConversions.bi2de(message_logical(5:10)) == 50
                mt50 = MT50.decode(message_logical);
                obj.add_message_mt50(mt50, time);
            end

        end

        function verified = verify_mt50(obj, MT50, receipt_time)
            % Given an MT50 checks to see if it hashes down to hash path end
            %
            %   MT50 - an MT50 object
            %   returns - true if MT50 is authenticated and throws error
            %   otherwise
            hashpoint = MT50.hash_point;
            temp = hashpoint;
            verified = false;

            for i = 1:obj.max_hash_path_length
                temp = obj.hash_path_function(temp, receipt_time);
                if temp == obj.verified_hash_point_cache
                    verified = true;
                    obj.verified_hash_point_cache = hashpoint;
                    break
                end

                if ~isempty(obj.next_hash_path_end) && all(temp == obj.next_hash_path_end)
                    verified = true;
                    obj.reciever_hash_path_end = obj.next_hash_path_end;
                    obj.verified_hash_point_cache = obj.reciever_hash_path_end;
                    break
                end

                if i == obj.max_hash_path_length
                    error('ReveiverTESLA:InvalidHashPoint', ...
                          'Input Hash Point did not Hash down to verified Hash Point');
                end

                receipt_time = receipt_time - uint32(6);
            end
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
                key = bitxor(hashpoint, obj.time_conversion(i));
                hm = obj.mac_signing_function(message.message, key);

                if all(MT50.get_hmac(i - start + 1) == hm)
                    message.verified = true;
                else
                    error('Receiver:invalidHmac', 'can not handle incorrect hmac');
                end

            end
        end

        function verify_missed_mt50_hp(obj)
            % Used to verify possible hmacs that couldn't be because their
            % hashpoint was missed.
            largest_verified_key = max(cell2mat(keys(obj.mt50_table)));
            for i = 1:length(obj.missing_mt50)
                if isKey(obj.mt50_table, obj.missing_mt50{i} - 1) && ...
                         largest_verified_key > obj.missing_mt50{i}

                    count = largest_verified_key;
                    new_item = obj.mt50_table(largest_verified_key);
                    new_time = new_item{2};
                    new_hash = new_item{1}.hash_point;

                    while count ~= obj.missing_mt50{i}
                        new_hash = obj.hash_path_function(new_hash, new_time);
                        count = count - 1;
                    end

                    if obj.missing_mt50{i} - 1 ~= 0
                        mt50 = obj.mt50_table(obj.missing_mt50{i} - 1);
                        m = mt50{1};
                        t = mt50{2};

                        obj.verify_hmac_block(m, new_hash, t);
                    end
                end
            end

            obj.missing_mt50 = {};
        end

        function bool = check_if_message_verified(obj, time)
            % Checks if a message in the message table is verified
            %
            %   time - the time of the message you want to see was verfied
            %   returns - true if verified otherwise false
            if ~obj.message_table.isKey(time)
                bool = false;
            else
                message = obj.message_table(time);
                bool = message.verified;
            end

        end

        function set_hash_path_end(obj, hash_point)
            obj.reciever_hash_path_end = hash_point;
            obj.verified_hash_point_cache = hash_point;
        end

        function set_next_hash_path_end(obj, hash_point)
            obj.next_hash_path_end = hash_point;
        end

    end

    methods (Static, Access = private)

        function hash_point_out = hash_path_func(hash_point_in, time)
            counter = idivide(time, 6);
            counter_array = DataConversions.int_to_uint8_16_array(counter);
            hash_point_out = HashingWrappers.truncated_sha_256(bitxor(hash_point_in, counter_array), 16);
        end

    end
end
