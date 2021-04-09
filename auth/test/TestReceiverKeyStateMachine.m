classdef TestReceiverKeyStateMachine < matlab.unittest.TestCase

    methods (Test)

        function test_display(testcase)
            current_time = uint32(posixtime(datetime(datestr(now()))));

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            ks = SBASKeyStack(current_time, current_hash_path_end, next_hash_path_end);
            mt51_set = [ks.current_mt51_set; ks.next_mt51_set];

            messages = false(250, length(mt51_set));
            for i = 1:length(mt51_set)
                messages(:, i) = mt51_set(i).encode();
            end

            ksm = ReceiverKeyStateMachine();

            for i = 1:size(messages, 2)
                message = messages(:, i);
                mt51 = MT51.decode(message);
                ksm.process_mt51(mt51);
            end

            disp(ks);
            disp(ksm);

            testcase.verifyEqual(ksm.level_1_keys.Count, uint64(2));
            testcase.verifyEqual(ksm.level_2_keys.Count, uint64(2));
            testcase.verifyEqual(ksm.level_3_keys.Count, uint64(2));

            ksm.get_current_key(1, current_time + 1e9);
            ksm.get_current_key(2, current_time + 1e9);
            ksm.get_current_key(3, current_time + 1e9);

            testcase.verifyEqual(ksm.level_1_keys.Count, uint64(0));
            testcase.verifyEqual(ksm.level_2_keys.Count, uint64(0));
            testcase.verifyEqual(ksm.level_3_keys.Count, uint64(0));
        end

        function test_process_mt51_exceptions(testcase)
            level = 2;
            hash = [uint8(3); uint8(5)];
            time = uint32(123456789);
            auth_hash = [uint8(7); uint8(11)];
            payload_type = uint8(3);
            payload_page = uint8(13);
            payload = uint8(1:16)';

            mt51 = MT51(level, hash, time, auth_hash, payload_type, payload_page, payload);
            ksm = ReceiverKeyStateMachine();
            testcase.verifyError(@() ksm.process_mt51(mt51), 'ReceiverKeyStateMachine:NotImplementedPayloadType');
        end

        function test_complete_otar(testcase)

            current_time = uint32(posixtime(datetime(datestr(now()))));

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            ks = SBASKeyStack(current_time, current_hash_path_end, next_hash_path_end);
            mt51_set = [ks.current_mt51_set; ks.next_mt51_set];

            messages = false(250, length(mt51_set));
            for i = 1:length(mt51_set)
                messages(:, i) = mt51_set(i).encode();
            end

            ksm = ReceiverKeyStateMachine();

            for i = 1:size(messages, 2)
                if i <= 17
                    testcase.verifyFalse(ksm.full_stack_authenticated(current_time));
                    if i > 1
                        testcase.verifyEqual(ksm.level_1_keys.Count, uint64(1));
                    else
                        testcase.verifyEqual(ksm.level_1_keys.Count, uint64(0));
                    end
                    if i > 5
                        testcase.verifyEqual(ksm.level_2_keys.Count, uint64(1));
                    else
                        testcase.verifyEqual(ksm.level_2_keys.Count, uint64(0));
                    end
                    if i > 13
                        testcase.verifyEqual(ksm.level_3_keys.Count, uint64(1));
                    else
                        testcase.verifyEqual(ksm.level_3_keys.Count, uint64(0));
                    end
                else
                    testcase.verifyTrue(ksm.full_stack_authenticated(current_time));
                    if i > 18
                        testcase.verifyEqual(ksm.level_1_keys.Count, uint64(2));
                    else
                        testcase.verifyEqual(ksm.level_1_keys.Count, uint64(1));
                    end
                    if i > 22
                        testcase.verifyEqual(ksm.level_2_keys.Count, uint64(2));
                    else
                        testcase.verifyEqual(ksm.level_2_keys.Count, uint64(1));
                    end
                    if i > 30
                        testcase.verifyEqual(ksm.level_3_keys.Count, uint64(2));
                    else
                        testcase.verifyEqual(ksm.level_3_keys.Count, uint64(1));
                    end
                end
                message = messages(:, i);
                mt51 = MT51.decode(message);
                ksm.process_mt51(mt51);
            end

            testcase.verifyEqual(ksm.get_current_key(1, current_time), ks.current_level_1_key);
            testcase.verifyEqual(ksm.get_current_key(2, current_time), ks.current_level_2_key);
            testcase.verifyEqual(ksm.get_current_key(3, current_time), ks.current_level_3_key);
        end

        function test_complete_otar_random_mt51_order(testcase)

            current_time = uint32(posixtime(datetime(datestr(now()))));

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            ks = SBASKeyStack(current_time, current_hash_path_end, next_hash_path_end);
            mt51_set = [ks.current_mt51_set; ks.next_mt51_set];

            mt51_set = mt51_set([28, 31, 5, 30, 27, 1, 25, 18, 2, 8, 22, 12, 20, 11, 10, 4, 17, 3, 32, 34, 7, 24, ...
                                 13, 16, 9, 26, 23, 33, 19, 29, 6, 21, 14, 15]);

            messages = false(250, length(mt51_set));
            for i = 1:length(mt51_set)
                messages(:, i) = mt51_set(i).encode();
            end

            ksm = ReceiverKeyStateMachine();

            for i = 1:size(messages, 2)
                if i <= 25
                    testcase.verifyFalse(ksm.full_stack_authenticated(current_time));
                end
                message = messages(:, i);
                mt51 = MT51.decode(message);
                ksm.process_mt51(mt51);
            end
            testcase.verifyTrue(ksm.full_stack_authenticated(current_time));

            testcase.verifyEqual(ksm.level_1_keys.Count, uint64(2));
            testcase.verifyEqual(ksm.level_2_keys.Count, uint64(2));
            testcase.verifyEqual(ksm.level_3_keys.Count, uint64(2));

            testcase.verifyEqual(ksm.get_current_key(1, current_time), ks.current_level_1_key);
            testcase.verifyEqual(ksm.get_current_key(2, current_time), ks.current_level_2_key);
            testcase.verifyEqual(ksm.get_current_key(3, current_time), ks.current_level_3_key);
        end

        function test_failed_otar_wrong_level_1(testcase)

            current_time = uint32(posixtime(datetime(datestr(now()))));

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            ks = SBASKeyStack(current_time, current_hash_path_end, next_hash_path_end);
            mt51_set = [ks.current_mt51_set; ks.next_mt51_set];

            mt51_subset = mt51_set(5:end);

            messages = false(250, length(mt51_subset));
            for i = 1:length(mt51_subset)
                messages(:, i) = mt51_subset(i).encode();
            end

            ksm = ReceiverKeyStateMachine();

            for i = 1:size(messages, 2)
                message = messages(:, i);
                mt51 = MT51.decode(message);
                ksm.process_mt51(mt51);
            end
            testcase.verifyFalse(ksm.full_stack_authenticated(current_time));

        end

        function test_failed_otar_wrong_level_2(testcase)

            current_time = uint32(posixtime(datetime(datestr(now()))));

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            ks = SBASKeyStack(current_time, current_hash_path_end, next_hash_path_end);
            mt51_set = [ks.current_mt51_set; ks.next_mt51_set];

            mt51_subset = mt51_set([1:11, 13:17, 22:29]);

            messages = false(250, length(mt51_subset));
            for i = 1:length(mt51_subset)
                messages(:, i) = mt51_subset(i).encode();
            end

            ksm = ReceiverKeyStateMachine();

            for i = 1:size(messages, 2)
                message = messages(:, i);
                mt51 = MT51.decode(message);
                ksm.process_mt51(mt51);
            end
            testcase.verifyFalse(ksm.full_stack_authenticated(current_time));
            ksm.process_mt51(MT51.decode(mt51_set(12).encode()));
            testcase.verifyTrue(ksm.full_stack_authenticated(current_time));

        end

        function test_failed_otar_wrong_level_3(testcase)

            current_time = uint32(posixtime(datetime(datestr(now()))));

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            ks = SBASKeyStack(current_time, current_hash_path_end, next_hash_path_end);
            mt51_set = [ks.current_mt51_set; ks.next_mt51_set];

            mt51_subset = mt51_set([1:12, 19:34]);

            messages = false(250, length(mt51_subset));
            for i = 1:length(mt51_subset)
                messages(:, i) = mt51_subset(i).encode();
            end

            ksm = ReceiverKeyStateMachine();

            for i = 1:size(messages, 2)
                message = messages(:, i);
                mt51 = MT51.decode(message);
                ksm.process_mt51(mt51);
            end

            testcase.verifyFalse(ksm.full_stack_authenticated(current_time, current_hash_path_end));
            testcase.verifyTrue(ksm.full_stack_authenticated(current_time, next_hash_path_end));
            testcase.verifyTrue(ksm.full_stack_authenticated(current_time));

            ksm.process_mt51(mt51_set(13));
            testcase.verifyFalse(ksm.full_stack_authenticated(current_time, current_hash_path_end));
            testcase.verifyFalse(ksm.full_stack_authenticated(current_time));
            testcase.verifyTrue(ksm.full_stack_authenticated(current_time, next_hash_path_end));
        end

        function test_failed_otar_empty_level_2(testcase)

            current_time = uint32(posixtime(datetime(datestr(now()))));

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            ks = SBASKeyStack(current_time, current_hash_path_end, next_hash_path_end);
            mt51_set = [ks.current_mt51_set; ks.next_mt51_set];

            mt51_subset = mt51_set([1:4, 13:17]);

            messages = false(250, length(mt51_subset));
            for i = 1:length(mt51_subset)
                messages(:, i) = mt51_subset(i).encode();
            end

            ksm = ReceiverKeyStateMachine();

            for i = 1:size(messages, 2)
                message = messages(:, i);
                mt51 = MT51.decode(message);
                ksm.process_mt51(mt51);
            end
            testcase.verifyFalse(ksm.full_stack_authenticated(current_time));
        end

    end
end
