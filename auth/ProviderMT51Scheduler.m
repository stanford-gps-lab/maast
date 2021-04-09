classdef ProviderMT51Scheduler < handle
    % ProviderMT51Scheduler Class that generates and manages sets of SBAS keys and generates the MT51 messages for
    % an SBAS Provider to sent

    properties (Access = public)
        key_stack
    end

    properties (Access = protected)
        current_mt51_counter = 1
        current_mt51_set_total

        next_mt51_counter = 1
        next_mt51_set_total

        main_counter = 1
        next_set_frequency = 12
    end

    methods

        function obj = ProviderMT51Scheduler(current_time, current_hash_path_end, next_hash_path_end)
            % Construct an instance of this class.
            obj.key_stack = SBASKeyStack(current_time, current_hash_path_end, next_hash_path_end);
            obj.current_mt51_set_total = length(obj.key_stack.current_mt51_set);
            obj.next_mt51_set_total = length(obj.key_stack.next_mt51_set);
        end

        function mt51 = get_next_mt51(obj, current_time)
            % Update keys, as necessary given the input current time, and then get the next MT51 message.

            % update key stack given input current input
            obj.key_stack.update_stack(current_time);

            % select the appropriate MT51 message and update the counters
            if obj.main_counter ~= obj.next_set_frequency
                mt51 = obj.key_stack.current_mt51_set(obj.current_mt51_counter);
                obj.current_mt51_counter = obj.mod_1_indexed(obj.current_mt51_counter + 1, obj.current_mt51_set_total);
            else
                mt51 = obj.key_stack.next_mt51_set(obj.next_mt51_counter);
                obj.next_mt51_counter = obj.mod_1_indexed(obj.next_mt51_counter + 1, obj.next_mt51_set_total);
            end
            obj.main_counter = obj.mod_1_indexed(obj.main_counter + 1, obj.next_set_frequency);
        end

        function queue_hash_path_end(obj, next_hash_path_end, expiration_time)
            % queue next hash path end to prepare for next level-3 key rotation
            obj.key_stack.queue_hash_path_end(next_hash_path_end, expiration_time);
        end

    end

    methods (Static, Access = protected)

        function output = mod_1_indexed(input, modulo)
            % modulo operation for matlab 1-indexed arrays: normal mod, but everything is +1
            output = mod(input - 1, modulo) + 1;
        end

    end
end
