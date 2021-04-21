classdef TestSenderNotary < matlab.unittest.TestCase

    methods (Test)

        function test_key_chain_construction(testCase)
            sn = SenderTESLA();
            for i = 1:sn.key_chain_length - 1
                hash = HashingWrappers.truncated_sha_256(sn.key_chain{i}, 16);
                testCase.assertEqual(hash, sn.key_chain{i + 1});
            end
        end

        function test_M50_creation(testCase)
            sn = SenderTESLA();
            count = 1;
            time = 1;
            for i = 1:100
                message = uint8(strcat(['message ', num2str(i)]));

                test = sn.load_new_message(message, time);

                if isa(test, 'MT50')
                    testCase.assertEqual(test.hash_point, sn.key_chain{end - count + 1});
                    count = count + 1;
                    if count >= sn.key_chain_length
                        count = 1;
                    end
                end
                time = time + 1;
            end

        end

        function test_next_keychain(testCase)
            sn = SenderTESLA();
            path1 = SenderTESLA.copy_keychain(sn.key_chain);
            path2 = sn.next_key_chain;
            time = 1;
            count = 1;

            for i = 1:700
                message = uint8(strcat(['message ', num2str(i)]));

                test = sn.load_new_message(message, time);

                if isa(test, 'MT50')
                    count = count + 1;
                    if count >= sn.key_chain_length
                        count = 1;
                    end
                end
                time = time + 1;
            end
            testCase.assertNotEqual(path1, sn.key_chain);
            testCase.assertEqual(path2, sn.key_chain);

        end

        function test_sender_and_reciever(testCase)
            sn = SenderTESLA();
            pass = sn.get_hash_path_end;
            pass2 = sn.get_next_hash_path_end;
            rn = ReceiverTESLA(pass, pass2);

            time = 1;

            for i = 1:100
                message = uint8(strcat(['message ', num2str(i)]));

                m = sn.load_new_message(message, time);
                rn.add_message(message, time);
                if isa(m, 'MT50')
                    time = time + 1;
                    rn.add_message(m, time);
                end
                time = time + 1;
            end

            for i = 1:114
                message = rn.message_table(i);
                testCase.assertTrue(message.verified);
            end
        end

        function test_manipulated_message(testCase)
            sn = SenderTESLA();
            pass = sn.get_hash_path_end;
            pass2 = sn.get_next_hash_path_end;
            rn = ReceiverTESLA(pass, pass2);

            time = 1;

            for i = 1:10
                message = uint8(strcat(['message ', num2str(i)]));

                m = sn.load_new_message(message, time);
                if i == 2
                    message = uint8(strcat(['message ', num2str(i + 1)]));
                end

                rn.add_message(message, time);

                if isa(m, 'MT50')
                    time = time + 1;
                    if time ~= 12
                        rn.add_message(m, time);
                    else
                        testCase.verifyError(@()rn.add_message(m, time), ...
                                             'Receiver:invalidHmac');
                    end
                end
                time = time + 1;
            end

        end

        function test_missing_mt50(testCase)
            sn = SenderTESLA();
            pass = sn.get_hash_path_end;
            pass2 = sn.get_next_hash_path_end;
            rn = ReceiverTESLA(pass, pass2);

            time = 1;

            for i = 1:100
                message = uint8(strcat(['message ', num2str(i)]));

                m = sn.load_new_message(message, time);

                rn.add_message(message, time);

                if isa(m, 'MT50')
                    time = time + 1;
                    if time ~= 12
                        rn.add_message(m, time);
                    end
                end
                time = time + 1;
            end

            for i = 1:114
                if i < 7 || i > 12
                    message = rn.message_table(i);
                    testCase.assertTrue(message.verified);
                elseif i ~= 12
                    message = rn.message_table(i);
                    testCase.assertFalse(message.verified);
                end
            end
        end

        function test_swapped_mt50(testCase)
            sn = SenderTESLA();
            pass = sn.get_hash_path_end;
            pass2 = sn.get_next_hash_path_end;
            rn = ReceiverTESLA(pass, pass2);

            time = 1;

            stored = cell(1, 12);

            while time < 19
                message = uint8(strcat(['message ', num2str(time)]));
                stored{time} = message;
                m = sn.load_new_message(message, time);

                if isa(m, 'MT50')
                    time = time + 1;
                    stored{time} = m;
                end
                time = time + 1;
            end

            temp = stored{12};
            stored{12} = stored{18};
            stored{18} = temp;

            for i = 1:11
                rn.add_message(stored{i}, i);
            end
            testCase.verifyError(@()rn.add_message(stored{12}, 12), ...
                                 'Receiver:invalidHmac');

        end

        function test_swapped_messages(testCase)
            sn = SenderTESLA();
            pass = sn.get_hash_path_end;
            pass2 = sn.get_next_hash_path_end;
            rn = ReceiverTESLA(pass, pass2);

            time = 1;

            stored = cell(1, 12);

            while time < 19
                message = uint8(strcat(['message ', num2str(time)]));
                stored{time} = message;
                m = sn.load_new_message(message, time);

                if isa(m, 'MT50')
                    time = time + 1;
                    stored{time} = m;
                end
                time = time + 1;
            end

            temp = stored{2};
            stored{2} = stored{3};
            stored{3} = temp;

            for i = 1:18
                if i == 12
                    testCase.verifyError(@()rn.add_message(stored{i}, i), ...
                                         'Receiver:invalidHmac');
                else
                    rn.add_message(stored{i}, i);
                end
            end

        end

        function test_sender_and_reciever_keychain_rotation(testCase)
            sn = SenderTESLA(4);
            pass = sn.get_hash_path_end;
            pass2 = sn.get_next_hash_path_end;
            rn = ReceiverTESLA(pass, pass2);

            time = 1;

            for i = 1:30
                message = uint8(strcat(['message ', num2str(i)]));

                m = sn.load_new_message(message, time);
                rn.add_message(message, time);
                if isa(m, 'MT50')
                    time = time + 1;
                    rn.add_message(m, time);
                end
                time = time + 1;
            end

            for i = 1:30
                message = rn.message_table(i);
                testCase.assertTrue(message.verified);
            end

        end
        
        function test_missing_message(testCase)
            sn = SenderTESLA();
            pass = sn.get_hash_path_end;
            pass2 = sn.get_next_hash_path_end;
            rn = ReceiverTESLA(pass, pass2);

            time = 1;

            for i = 1:24
                message = uint8(strcat(['message ', num2str(i)]));

                m = sn.load_new_message(message, time);
                
                if time ~= 2
                    rn.add_message(message, time);
                end
                if isa(m, 'MT50')
                    time = time + 1;
                    rn.add_message(m, time);
                end
                time = time + 1;
            end

            for i = 1:18
                message = rn.message_table(i);
                if i ~= 2
                    testCase.assertTrue(message.verified);
                else
                    testCase.assertFalse(message.verified);
                end
            end
        end
    end
end
