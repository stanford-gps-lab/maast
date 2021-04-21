classdef ReceiverTESLA < handle
    % RECIEVER Summary of this class goes here
    %   Detailed explanation goes here

    properties
        key_chain_function = @(x)HashingWrappers.truncated_sha_256(x, 16)
        mac_signing_function = @(x, y)HashingWrappers.truncated_hmac_sha_256(x, y, 2)
        message_table
        reciever_key_chain_end
        next_key_chain_end
        verified_block = cell (1, 5)
        mt50_table
        missing_mt50 = {}
    end

    methods

        function obj = ReceiverTESLA(hp, hp2)
            obj.reciever_key_chain_end = hp;
            obj.next_key_chain_end = hp2;
            obj.message_table = containers.Map('KeyType', 'double', 'ValueType', 'any');
            obj.mt50_table = containers.Map('KeyType', 'double', 'ValueType', 'any');
        end

        function add_message(obj, message, time)
            obj.message_table(time) = MessageTableValue(message);

            if isa(message, 'MT50')
                if time == 6
                    % for ecdsa code to verify
                    m = obj.message_table(time);
                    m.verified = true;
                    obj.mt50_table(1) = {message, time};
                else
                    if obj.verify_mt50(message)
                        obj.verify_missed_mt50_hp;
                        % modify the entire message table
                        m = obj.message_table(time);
                        m.verified = true;
                        % add mt_50 to the mt50 table
                        mt50_num = idivide(time, uint8(6));
                        obj.mt50_table(mt50_num) ...
                            = {message, time};
                        if isKey(obj.mt50_table, mt50_num - 1)
                            hash = obj.message_table(time);
                            hash = hash.message.hash_point;

                            mt50 = obj.mt50_table(mt50_num - 1);
                            m = mt50{1};
                            t = mt50{2};

                            obj.verify_hmac_block(m, hash, t);
                        else
                            obj.missing_mt50{end + 1} = mt50_num - 1;
                            disp("missing mt50 to verify hmacs");
                        end
                    end
                end
            end
        end

        function verified = verify_mt50(obj, MT50)
            hashpoint = MT50.hash_point;
            temp = obj.key_chain_function(hashpoint);
            for i = 1:100
                if temp == obj.reciever_key_chain_end
                    verified = true;
                else
                    temp = obj.key_chain_function(temp);
                end
            end

            if obj.key_chain_function(hashpoint) == obj.next_key_chain_end
                verified = true;
                obj.reciever_key_chain_end = obj.next_key_chain_end;
            end

            if verified ~= true
                error('Receiver:invalidMT50', 'can not handle incorrect mt50');
            end
        end

        function verified = verify_hmac_block(obj, MT50, hashpoint, time)
            start = time - 5;

            for i = start:start + 4
                if ~isKey(obj.message_table, i)
                    continue
                end
                message = obj.message_table(i);
                key = xor(hashpoint, i);
                hm = obj.mac_signing_function(message.message, key);

                if MT50.get_hmac(mod(i, 6)) == hm
                    message.verified = true;
                    obj.verified_block{mod(i, 6)} = message;
                else
                    error('Receiver:invalidHmac', 'can not handle incorrect hmac');
                end

                verified = obj.verified_block{mod(i, 6)};
            end
        end

        function verify_missed_mt50_hp(obj)
            largest_verified_key = max(cell2mat(keys(obj.mt50_table)));
            for i = 1:length(obj.missing_mt50)
                if isKey(obj.mt50_table, obj.missing_mt50{i} - 1) && ...
                         largest_verified_key > obj.missing_mt50{i}

                    count = largest_verified_key;
                    new_hash = obj.mt50_table(largest_verified_key);
                    new_hash = new_hash{1}.hash_point;

                    while count ~= obj.missing_mt50{i}
                        new_hash = obj.key_chain_function(new_hash);
                        count = count - 1;
                    end

                    mt50 = obj.mt50_table(obj.missing_mt50{i} - 1);
                    m = mt50{1};
                    t = mt50{2};

                    obj.verify_hmac_block(m, new_hash, t);
                end
            end

            obj.missing_mt50 = {};
        end

    end
end
