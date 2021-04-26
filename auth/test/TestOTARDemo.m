classdef TestOTARDemo < matlab.unittest.TestCase
    % TESTOTARDEMO A collection of examples for how to use OTAR classes.

    methods (Test)

        function test_simple_otar(testcase)

            sim_start_time = 0;
            sim_length = 1000;

            % provided by TESLA code
            first_hash_path_end = uint8(1:16);
            second_hash_path_end = uint8(17:32);

            % initialize provider object
            mt51_scheduler = ProviderMT51Scheduler(sim_start_time, first_hash_path_end, second_hash_path_end);

            % initialize receiver object
            receiver_otar_state_machine = ReceiverKeyStateMachine();

            % data structure to keep track of when complete SBAS key stack is authenticated
            completed_otar = false(sim_length, 1);

            % execute simulation
            for t = 1:sim_length
                current_time = sim_start_time + t;

                % provider side
                transmitted_mt51 = mt51_scheduler.get_next_mt51(current_time);
                message_bits = transmitted_mt51.encode();

                % receiver side
                received_mt51 = MT51.decode(message_bits);
                receiver_otar_state_machine.process_mt51(received_mt51);
                completed_otar(t) = receiver_otar_state_machine.full_stack_authenticated(current_time);
            end

            % receiver was authenticated for 983/1000 seconds of the simulation time
            testcase.assertEqual(sum(completed_otar), 983);
        end

    end
end
