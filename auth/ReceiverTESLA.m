classdef ReceiverTESLA < handle
    % RECEIVERTESLA Class Responsible for receiving and verifying messages

    properties (SetAccess = protected)
        hash_path_function = @(x, t) ReceiverTESLA.hash_path_func(x, t)
        mac_signing_function = []
        time_conversion = @(x)DataConversions.int_to_uint8_16_array(x)
        message_table % stores all recieved messages k = time and v = message + verified
        next_hash_path_end % stores the next end of hash path
        reciever_hash_path_end % stores end of hash path from mt51
        mt50_decode = []
        hmac_size
        include_crc
        prn
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
                    obj.prn = 131;
                case 1
                    obj.reciever_hash_path_end = varargin{1};
                    obj.next_hash_path_end = [];
                    obj.prn = 131;
                case 2
                    obj.reciever_hash_path_end = varargin{1};
                    obj.next_hash_path_end = varargin{2};
                    obj.prn = 131;
                case 3
                    obj.reciever_hash_path_end = varargin{1};
                    obj.next_hash_path_end = varargin{2};
                    obj.max_hash_path_length = varargin{3};
                    obj.prn = 131;
                case 4
                    obj.reciever_hash_path_end = varargin{1};
                    obj.next_hash_path_end = varargin{2};
                    obj.max_hash_path_length = varargin{3};
                    obj.prn = varargin{4};
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
                output = obj.check_if_dummy_mt50(message);
                if output == true
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
                mt50 = obj.mt50_decode(message_logical, obj.prn);
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
                    error('ReceiverTESLA:InvalidHashPoint', ...
                          'Input Hash Point did not Hash down to verified Hash Point');
                end

                receipt_time = receipt_time - uint32(6);
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

    methods (Abstract)
        verify_hmac_block(obj, MT50, hashpoint, time)
        output = check_if_dummy_mt50(obj, message)
    end
end
