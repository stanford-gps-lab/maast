classdef TestProviderMT51Scheduler < matlab.unittest.TestCase
    methods (Test)

        function test_scheduler_with_two_keystacks(testcase)
            current_time = uint32(posixtime(datetime(datestr(now()))));

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            mt51_scheduler = ProviderMT51Scheduler(current_time, current_hash_path_end, next_hash_path_end);

            for i = 1:20
                current_time = current_time + 1;
                mt51_scheduler.get_next_mt51(current_time);
            end

            ksm = ReceiverKeyStateMachine();
            for i = 21:250
                current_time = current_time + 1;

                mt51 = mt51_scheduler.get_next_mt51(current_time);
                ksm.process_mt51(MT51.decode(mt51.encode()));

                if i < 23
                    testcase.assertEqual(ksm.level_1_keys.Count, uint64(1));
                    testcase.assertEqual(ksm.level_2_keys.Count, uint64(0));
                    testcase.assertEqual(ksm.level_3_keys.Count, uint64(0));
                    testcase.assertFalse(ksm.full_stack_authenticated(current_time));
                elseif i == 23
                    testcase.assertEqual(ksm.level_1_keys.Count, uint64(1));
                    testcase.assertEqual(ksm.level_2_keys.Count, uint64(1));
                    testcase.assertEqual(ksm.level_3_keys.Count, uint64(0));
                    testcase.assertFalse(ksm.full_stack_authenticated(current_time));
                elseif i < 32
                    testcase.assertEqual(ksm.level_1_keys.Count, uint64(2));
                    testcase.assertEqual(ksm.level_2_keys.Count, uint64(1));
                    testcase.assertEqual(ksm.level_3_keys.Count, uint64(0));
                    testcase.assertFalse(ksm.full_stack_authenticated(current_time));
                elseif i < 39
                    testcase.assertEqual(ksm.level_1_keys.Count, uint64(2));
                    testcase.assertEqual(ksm.level_2_keys.Count, uint64(1));
                    testcase.assertEqual(ksm.level_3_keys.Count, uint64(1));
                    testcase.assertFalse(ksm.full_stack_authenticated(current_time));
                elseif i < 60
                    testcase.assertEqual(ksm.level_1_keys.Count, uint64(2));
                    testcase.assertEqual(ksm.level_2_keys.Count, uint64(1));
                    testcase.assertEqual(ksm.level_3_keys.Count, uint64(1));
                    testcase.assertTrue(ksm.full_stack_authenticated(current_time));
                elseif i < 156
                    testcase.assertEqual(ksm.level_1_keys.Count, uint64(2));
                    testcase.assertEqual(ksm.level_2_keys.Count, uint64(2));
                    testcase.assertEqual(ksm.level_3_keys.Count, uint64(1));
                    testcase.assertTrue(ksm.full_stack_authenticated(current_time));
                else
                    testcase.assertEqual(ksm.level_1_keys.Count, uint64(2));
                    testcase.assertEqual(ksm.level_2_keys.Count, uint64(2));
                    testcase.assertEqual(ksm.level_3_keys.Count, uint64(2));
                    testcase.assertTrue(ksm.full_stack_authenticated(current_time));
                end
            end

            time_soon = current_time + 604800;
            ksm.full_stack_authenticated(time_soon);
            testcase.assertEqual(ksm.level_1_keys.Count, uint64(2));
            testcase.assertEqual(ksm.level_2_keys.Count, uint64(2));
            testcase.assertEqual(ksm.level_3_keys.Count, uint64(1));

            time_soon = current_time + 2 * 604800;
            ksm.full_stack_authenticated(time_soon);
            testcase.assertEqual(ksm.level_1_keys.Count, uint64(2));
            testcase.assertEqual(ksm.level_2_keys.Count, uint64(2));
            testcase.assertEqual(ksm.level_3_keys.Count, uint64(0));

            time_soon = current_time + 6048000;
            ksm.full_stack_authenticated(time_soon);
            testcase.assertEqual(ksm.level_1_keys.Count, uint64(2));
            testcase.assertEqual(ksm.level_2_keys.Count, uint64(1));
            testcase.assertEqual(ksm.level_3_keys.Count, uint64(0));

            time_soon = current_time + 2 * 6048000;
            ksm.full_stack_authenticated(time_soon);
            testcase.assertEqual(ksm.level_1_keys.Count, uint64(2));
            testcase.assertEqual(ksm.level_2_keys.Count, uint64(0));
            testcase.assertEqual(ksm.level_3_keys.Count, uint64(0));

            time_soon = current_time + 60480000;
            ksm.full_stack_authenticated(time_soon);
            testcase.assertEqual(ksm.level_1_keys.Count, uint64(1));
            testcase.assertEqual(ksm.level_2_keys.Count, uint64(0));
            testcase.assertEqual(ksm.level_3_keys.Count, uint64(0));

            time_soon = current_time + 2 * 60480000;
            ksm.full_stack_authenticated(time_soon);
            testcase.assertEqual(ksm.level_1_keys.Count, uint64(0));
            testcase.assertEqual(ksm.level_2_keys.Count, uint64(0));
            testcase.assertEqual(ksm.level_3_keys.Count, uint64(0));
        end

        function test_continous_operation(testcase)

            start_time = uint32(posixtime(datetime(datestr(now()))));
            current_time = start_time;

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            mt51_scheduler = ProviderMT51Scheduler(current_time, current_hash_path_end, next_hash_path_end);

            for i = 1:200
                current_time = current_time + 1;
                mt51_scheduler.get_next_mt51(current_time);
            end

            ksm = ReceiverKeyStateMachine();
            for i = 201:300
                current_time = current_time + 1;
                mt51 = mt51_scheduler.get_next_mt51(current_time);
                ksm.process_mt51(mt51);
            end

            for t = 1:330

                if mod(t, 10) == 0
                    fprintf('t = %i / 330\n', t);
                end

                for i = 1:250
                    current_time = current_time + 1;
                    mt51 = mt51_scheduler.get_next_mt51(current_time);
                    ksm.process_mt51(mt51);
                    testcase.assertTrue(ksm.full_stack_authenticated(current_time, current_hash_path_end));
                end

                testcase.assertEqual(ksm.level_1_keys.Count, uint64(2));
                testcase.assertEqual(ksm.level_2_keys.Count, uint64(2));
                testcase.assertEqual(ksm.level_3_keys.Count, uint64(2));

                current_hash_path_end = next_hash_path_end;
                next_hash_path_end = uint8(randi([0, 255], 16, 1));
                mt51_scheduler.queue_hash_path_end(next_hash_path_end, start_time + (t + 2) * 604800);

                current_time = start_time + t * 604800;
                testcase.assertTrue(ksm.full_stack_authenticated(current_time, current_hash_path_end));
                mt51_scheduler.get_next_mt51(current_time);
                if mod(t, 100) == 0
                    testcase.assertEqual(ksm.level_1_keys.Count, uint64(1));
                else
                    testcase.assertEqual(ksm.level_1_keys.Count, uint64(2));
                end
                if mod(t, 10) == 0
                    testcase.assertEqual(ksm.level_2_keys.Count, uint64(1));
                else
                    testcase.assertEqual(ksm.level_2_keys.Count, uint64(2));
                end
                testcase.assertEqual(ksm.level_3_keys.Count, uint64(1));
            end
        end

        function test_exception_no_queued_hash_path_end(testcase)

            start_time = uint32(posixtime(datetime(datestr(now()))));
            current_time = start_time;

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            mt51_scheduler = ProviderMT51Scheduler(current_time, current_hash_path_end, next_hash_path_end);

            current_time = start_time + 1 * 604800;
            testcase.verifyError(@()mt51_scheduler.get_next_mt51(current_time), 'SBASKeyStack:NoQueuedHashPathEnd');
        end

        function test_cold_start_level_2(testcase)

            start_time = uint32(posixtime(datetime(datestr(now()))));
            current_time = start_time;

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            mt51_scheduler = ProviderMT51Scheduler(current_time, current_hash_path_end, next_hash_path_end);

            ksm = ReceiverKeyStateMachine();
            for i = 1:250
                current_time = current_time + 1;
                mt51 = mt51_scheduler.get_next_mt51(current_time);
                ksm.process_mt51(mt51);
            end

            for t = 1:85

                current_time = start_time + (t - 1) * 604800 + 1;

                if mod(t, 10) == 0
                    fprintf('t = %i / 110\n', t);
                end

                for i = 1:250
                    current_time = current_time + 1;
                    mt51 = mt51_scheduler.get_next_mt51(current_time);
                    if t < 37 || t > 63
                        ksm.process_mt51(mt51);
                    end
                end

                for i = 1:250
                    current_time = current_time + 1;
                    mt51 = mt51_scheduler.get_next_mt51(current_time);
                    if t < 37 || t > 63
                        ksm.process_mt51(mt51);
                        testcase.assertTrue(ksm.full_stack_authenticated(current_time, current_hash_path_end));
                    end
                end

                current_hash_path_end = next_hash_path_end;
                next_hash_path_end = uint8(randi([0, 255], 16, 1));
                mt51_scheduler.queue_hash_path_end(next_hash_path_end, start_time + (t + 2) * 604800);

                current_time = start_time + t * 604800;
                if t < 37 || t > 63
                    testcase.assertTrue(ksm.full_stack_authenticated(current_time, current_hash_path_end));
                end
                mt51_scheduler.get_next_mt51(current_time);

            end
        end

        function test_cold_start_level_1(testcase)

            start_time = uint32(posixtime(datetime(datestr(now()))));
            current_time = start_time;

            current_hash_path_end = uint8(randi([0, 255], 16, 1));
            next_hash_path_end = uint8(randi([0, 255], 16, 1));

            mt51_scheduler = ProviderMT51Scheduler(current_time, current_hash_path_end, next_hash_path_end);

            ksm = ReceiverKeyStateMachine();
            for i = 1:250
                current_time = current_time + 1;
                mt51 = mt51_scheduler.get_next_mt51(current_time);
                ksm.process_mt51(mt51);
            end

            for t = 1:430

                current_time = start_time + (t - 1) * 604800 + 1;

                if mod(t, 10) == 0
                    fprintf('t = %i / 430\n', t);
                end

                for i = 1:250
                    current_time = current_time + 1;
                    mt51 = mt51_scheduler.get_next_mt51(current_time);
                    if t < 37 || 350 > 63
                        ksm.process_mt51(mt51);
                    end
                end

                for i = 1:250
                    current_time = current_time + 1;
                    mt51 = mt51_scheduler.get_next_mt51(current_time);
                    if t < 37 || t > 350
                        ksm.process_mt51(mt51);
                        testcase.assertTrue(ksm.full_stack_authenticated(current_time, current_hash_path_end));
                    end
                end

                current_hash_path_end = next_hash_path_end;
                next_hash_path_end = uint8(randi([0, 255], 16, 1));
                mt51_scheduler.queue_hash_path_end(next_hash_path_end, start_time + (t + 2) * 604800);

                current_time = start_time + t * 604800;
                if t < 37 || t > 350
                    testcase.assertTrue(ksm.full_stack_authenticated(current_time, current_hash_path_end));
                end
                mt51_scheduler.get_next_mt51(current_time);

            end
        end

    end
end
