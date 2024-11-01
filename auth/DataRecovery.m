classdef DataRecovery
    % Implemented using EvenOdd algorithm

    properties
    end

    methods (Static)

        function R = generate_data_recovery_fields(H)

            if H == 0
                R = [0, 0];
                return
            end

            if ~isequal(size(H), [1, 5])
                error('DataRecovery:invalidInput', 'input array must have exactly 5 elements');
            end

            cl = class(H);

            nr_nibbles = ceil(str2double(cl(5:end)) / 16);
            n_nibbles = 4 * nr_nibbles;

            temp = dec2hex(H, n_nibbles);

            for i = 4:-1:1
                Hrows(i, 1) = hex2dec(temp(1, (nr_nibbles * (i - 1) + 1):nr_nibbles * i));
                Hrows(i, 2) = hex2dec(temp(2, (nr_nibbles * (i - 1) + 1):nr_nibbles * i));
                Hrows(i, 3) = hex2dec(temp(3, (nr_nibbles * (i - 1) + 1):nr_nibbles * i));
                Hrows(i, 4) = hex2dec(temp(4, (nr_nibbles * (i - 1) + 1):nr_nibbles * i));
                Hrows(i, 5) = hex2dec(temp(5, (nr_nibbles * (i - 1) + 1):nr_nibbles * i));
            end

            % Find the first erasure field from the XOR of all of the hashes
            Rrows(:, 1) = bitxor(bitxor(bitxor(bitxor(Hrows(:, 1), ...
                                                      Hrows(:, 2)), Hrows(:, 3)), Hrows(:, 4)), Hrows(:, 5));

            % Find the parity field S
            S = bitxor(bitxor(bitxor(Hrows(4, 2), Hrows(3, 3)), Hrows(2, 4)), Hrows(1, 5));

            % Find the second erasure field
            Rrows(4, 2) = bitxor(bitxor(bitxor(bitxor(S, Hrows(4, 1)), ...
                                               Hrows(3, 2)), Hrows(2, 3)), Hrows(1, 4));
            Rrows(3, 2) = bitxor(bitxor(bitxor(bitxor(S, Hrows(3, 1)), ...
                                               Hrows(2, 2)), Hrows(1, 3)), Hrows(4, 5));
            Rrows(2, 2) = bitxor(bitxor(bitxor(bitxor(S, Hrows(2, 1)), ...
                                               Hrows(1, 2)), Hrows(4, 4)), Hrows(3, 5));
            Rrows(1, 2) = bitxor(bitxor(bitxor(bitxor(S, Hrows(1, 1)), ...
                                               Hrows(4, 3)), Hrows(3, 4)), Hrows(2, 5));

            R = DataRecovery.EvenOddRowsHex2Dec(Rrows, nr_nibbles);

        end

        function H = recover_data(H, R, flag)

            Hrows = NaN(4, 5);

            cl = class(H);

            nr_nibbles = ceil(str2double(cl(5:end)) / 16);
            n_nibbles = 4 * nr_nibbles;

            num_missing = sum(~flag);

            if num_missing == 0
                return
            elseif  num_missing > 2
                H = false;
                return
            end

            hi = find(~flag);

            if num_missing == 1

                idx = 1:5;
                idx(hi) = [];

                % Break the n-bit  Hashes into four 0.25*n-bit subcomponents
                tempH = dec2hex(H, n_nibbles);
                tempR = dec2hex(R, n_nibbles);
                for i = 4:-1:1
                    Hrows(i, idx(1)) = hex2dec(tempH(idx(1), ...
                                                     (nr_nibbles * (i - 1) + 1):nr_nibbles * i));
                    Hrows(i, idx(2)) = hex2dec(tempH(idx(2), ...
                                                     (nr_nibbles * (i - 1) + 1):nr_nibbles * i));
                    Hrows(i, idx(3)) = hex2dec(tempH(idx(3), ...
                                                     (nr_nibbles * (i - 1) + 1):nr_nibbles * i));
                    Hrows(i, idx(4)) = hex2dec(tempH(idx(4), ...
                                                     (nr_nibbles * (i - 1) + 1):nr_nibbles * i));
                    Rrows(i, 1) = hex2dec(tempR(1, ...
                                                (nr_nibbles * (i - 1) + 1):nr_nibbles * i));
                end

                % Recover the message by doing a bitwise XOR with th remaining messages
                % and the first recovery field
                Hrows(:, hi) = bitxor(bitxor(bitxor(bitxor(Rrows(:, 1), ...
                                                           Hrows(:, idx(1))), Hrows(:, idx(2))), ...
                                             Hrows(:, idx(3))), Hrows(:, idx(4)));

                H(hi) = DataRecovery.EvenOddRowsHex2Dec(Hrows(:, hi), nr_nibbles);
            else

                % identify the missing messages where i < j
                i = hi(1);
                j = hi(2);
                idx = 1:5;
                idx(j) = [];
                idx(i) = [];

                % Break the n-bit  Hashses into four 0.25*n-bit subcomponents
                tempH = dec2hex(H, n_nibbles);
                tempR = dec2hex(R, n_nibbles);
                for ii = 4:-1:1
                    Hrows(ii, idx(1)) = hex2dec(tempH(idx(1), ...
                                                      (nr_nibbles * (ii - 1) + 1):nr_nibbles * ii));
                    Hrows(ii, idx(2)) = hex2dec(tempH(idx(2), ...
                                                      (nr_nibbles * (ii - 1) + 1):nr_nibbles * ii));
                    Hrows(ii, idx(3)) = hex2dec(tempH(idx(3), ...
                                                      (nr_nibbles * (ii - 1) + 1):nr_nibbles * ii));
                    Rrows(ii, 1) = hex2dec(tempR(1, ...
                                                 (nr_nibbles * (ii - 1) + 1):nr_nibbles * ii));
                    Rrows(ii, 2) = hex2dec(tempR(2, ...
                                                 (nr_nibbles * (ii - 1) + 1):nr_nibbles * ii));
                end

                % Pad with a fifth row of zeros
                Hrows(5, :) = 0;
                Rrows(5, :) = 0;

                % Find the diagonal parity
                S = bitxor(bitxor(bitxor(bitxor(Rrows(1, 1), ...
                                                Rrows(2, 1)), Rrows(3, 1)), Rrows(4, 1)), ...
                           bitxor(bitxor(bitxor(Rrows(1, 2), ...
                                                Rrows(2, 2)), Rrows(3, 2)), Rrows(4, 2)));

                % Find the horizontal syndromes
                S0 = bitxor(bitxor(bitxor(Rrows(:, 1), ...
                                          Hrows(:, idx(1))), Hrows(:, idx(2))), Hrows(:, idx(3)));

                % Find the vertical syndromes
                S1(5) = 0;
                kdx = mod(1 - idx, 5) + 1;
                S1(1) = bitxor(bitxor(bitxor(bitxor(S, Rrows(1, 2)), ...
                                             Hrows(kdx(1), idx(1))), Hrows(kdx(2), idx(2))), ...
                               Hrows(kdx(3), idx(3)));
                kdx = mod(2 - idx, 5) + 1;
                S1(2) = bitxor(bitxor(bitxor(bitxor(S, Rrows(2, 2)), ...
                                             Hrows(kdx(1), idx(1))), Hrows(kdx(2), idx(2))), ...
                               Hrows(kdx(3), idx(3)));
                kdx = mod(3 - idx, 5) + 1;
                S1(3) = bitxor(bitxor(bitxor(bitxor(S, Rrows(3, 2)), ...
                                             Hrows(kdx(1), idx(1))), Hrows(kdx(2), idx(2))), ...
                               Hrows(kdx(3), idx(3)));
                kdx = mod(4 - idx, 5) + 1;
                S1(4) = bitxor(bitxor(bitxor(bitxor(S, Rrows(4, 2)), ...
                                             Hrows(kdx(1), idx(1))), Hrows(kdx(2), idx(2))), ...
                               Hrows(kdx(3), idx(3)));
                kdx = mod(5 - idx, 5) + 1;
                S1(5) = bitxor(bitxor(bitxor(bitxor(S, Rrows(5, 2)), ...
                                             Hrows(kdx(1), idx(1))), Hrows(kdx(2), idx(2))), ...
                               Hrows(kdx(3), idx(3)));

                % Perform the iterative recovery
                p = mod(i - j - 1, 5) + 1;
                while p ~= 5
                    Hrows(p, j) = bitxor(S1(mod(j + p - 2, 5) + 1), ...
                                         Hrows(mod(p + j - i - 1, 5) + 1, i));
                    Hrows(p, i) = bitxor(S0(p), Hrows(p, j));
                    p = mod(p + i - j - 1, 5) + 1;
                end
                Hrows(5, :) = [];

                H([i j]) = DataRecovery.EvenOddRowsHex2Dec(Hrows(:, [i j]), nr_nibbles);
            end
        end

        function R = generate_data_recovery_fields_28(H)
            H = DataRecovery.matrix_to_arr(H, 28);
            padded_hmacs = DataRecovery.zero_pad(H, 28);
            padded_datarecs = DataRecovery.generate_data_recovery_fields(padded_hmacs);
            R = DataRecovery.remove_zero_pad(padded_datarecs, 28);
            R = DataRecovery.arr_to_matrix(R, 28);
        end

        function H = recover_data_28(H, R, flag)
            H = DataRecovery.matrix_to_arr(H, 28);
            R = DataRecovery.matrix_to_arr(R, 28);
            padded_hmacs = DataRecovery.zero_pad(H, 28);
            padded_recovery_fields = DataRecovery.zero_pad(R, 28);
            padded_recovered_hmacs = DataRecovery.recover_data(padded_hmacs, padded_recovery_fields, flag);
            if (padded_recovered_hmacs) == false
                H = false;
                return
            end
            H = DataRecovery.remove_zero_pad(padded_recovered_hmacs, 28);
            H = DataRecovery.arr_to_matrix(H, 28);
        end

        function R = generate_data_recovery_fields_32(H)
            H = DataRecovery.matrix_to_arr(H, 32);
            R = DataRecovery.generate_data_recovery_fields(H);
            R = DataRecovery.arr_to_matrix(R, 32);
        end

        function H = recover_data_32(H, R, flag)
            H = DataRecovery.matrix_to_arr(H, 32);
            R = DataRecovery.matrix_to_arr(R, 32);
            recovered_hmacs = DataRecovery.recover_data(H, R, flag);
            if (recovered_hmacs) == false
                H = false;
                return
            end
            H = DataRecovery.arr_to_matrix(recovered_hmacs, 32);
        end

        function R = generate_data_recovery_fields_36(H)
            H = DataRecovery.matrix_to_arr(H, 36);
            padded_hmacs = DataRecovery.zero_pad(H, 36);
            padded_datarecs = DataRecovery.generate_data_recovery_fields(padded_hmacs);
            R = DataRecovery.remove_zero_pad(padded_datarecs, 36);
            R = DataRecovery.arr_to_matrix(R, 36);
        end

        function H = recover_data_36(H, R, flag)
            H = DataRecovery.matrix_to_arr(H, 36);
            R = DataRecovery.matrix_to_arr(R, 36);
            padded_hmacs = DataRecovery.zero_pad(H, 36);
            padded_recovery_fields = DataRecovery.zero_pad(R, 36);
            padded_recovered_hmacs = DataRecovery.recover_data(padded_hmacs, padded_recovery_fields, flag);
            if (padded_recovered_hmacs) == false
                H = false;
                return
            end
            H = DataRecovery.remove_zero_pad(padded_recovered_hmacs, 36);
            H = DataRecovery.arr_to_matrix(H, 36);
        end

        function H = EvenOddRowsHex2Dec(Hrows, nr_nibbles) %#ok<STOUT>
            temp = reshape(dec2hex(Hrows, nr_nibbles)', 4 * nr_nibbles, size(Hrows, 2))';

            for i = size(Hrows, 2):-1:1
                eval(sprintf('H(%i) = 0x%s;', i, temp(i, :)));
            end
        end

        function H = zero_pad(H, nbits)
            % No need to do much if already divisible by 16 or equals 8
            if mod(nbits, 16) == 0 || nbits == 8  || nbits > 64
                if nbits == 8
                    H = cast(H, 'uint8');
                elseif nbits < 65
                    eval(sprintf('H = cast(H, ''uint%2i'');', nbits));
                else
                    error('DataRecovery:invalidInput', ...
                          '%i is too many bits to work\n', nbits);
                end
                return
            end
            ncols = size(H, 2);

            % Determine the number of bits per row
            nbits_per_row = repmat(ceil(nbits / 4), 4, 1);

            % See if all rows will have the same number
            r = mod(nbits, 4);
            if r == 1
                nbits_per_row(2:4) = nbits_per_row(1) - 1;
            elseif r == 2
                nbits_per_row(3:4) = nbits_per_row(1) - 1;
            elseif r == 3
                nbits_per_row(4) = nbits_per_row(1) - 1;
            end

            % Find whether each row can be represented by an 8-bit or a 16-bit integer
            if nbits_per_row(1) <= 4
                nr_nibbles = 1;
                clr = 'uint8';
                cl = 'uint16';
            elseif nbits_per_row(1) <= 8
                nr_nibbles = 2;
                clr = 'uint8';
                cl = 'uint32';
            else
                nr_nibbles = 4;
                clr = 'uint16';
                cl = 'uint64';
            end

            Hrows = cast(zeros(4, ncols), clr);

            % Find the first row
            tmp = bitshift(H, -sum(nbits_per_row(2:4)));
            Hrows(1, :) = bitshift(tmp, 4 * nr_nibbles - nbits_per_row(1));

            % Find the second row
            tmp = bitshift(tmp, sum(nbits_per_row(2:4)));
            H = H - tmp;
            tmp = bitshift(H, -sum(nbits_per_row(3:4)));
            Hrows(2, :) = bitshift(tmp, 4 * nr_nibbles - nbits_per_row(2));

            % Find the third row
            tmp = bitshift(tmp, sum(nbits_per_row(3:4)));
            H = H - tmp;
            tmp = bitshift(H, -sum(nbits_per_row(4)));
            Hrows(3, :) = bitshift(tmp, 4 * nr_nibbles - nbits_per_row(3));

            % Find the fourth row
            tmp = bitshift(tmp, sum(nbits_per_row(4)));
            Hrows(4, :) = bitshift(H - tmp, 4 * nr_nibbles - nbits_per_row(4));

            Hrows = cast(Hrows, cl);
            H = bitshift(Hrows(1, :), 12 * nr_nibbles) + bitshift(Hrows(2, :), 8 * nr_nibbles) + ...
                bitshift(Hrows(3, :), 4 * nr_nibbles) + Hrows(4, :);
        end

        function H = remove_zero_pad(H, nbits)
            ncols = size(H, 2);

            % No need to do much if already divisible by 16 or equals 8
            if mod(nbits, 16) == 0 || nbits == 8  || nbits > 64
                if nbits == 8
                    H = cast(H, 'uint8');
                elseif nbits < 65
                    eval(sprintf('H = cast(H, ''uint%2i'');', nbits));
                else
                    error('DataRecovery:invalidInput', '%i is too many bits to work\n', nbits);
                end
                return
            end

            % Determine the number of bits per row
            nbits_per_row = repmat(ceil(nbits / 4), 4, 1);

            % See if all rows will have the same number
            r = mod(nbits, 4);
            if r == 1
                nbits_per_row(2:4) = nbits_per_row(1) - 1;
            elseif r == 2
                nbits_per_row(3:4) = nbits_per_row(1) - 1;
            elseif r == 3
                nbits_per_row(4) = nbits_per_row(1) - 1;
            end

            % Find whether each row can be represented by an 8-bit or a 16-bit integer
            if nbits_per_row(1) <= 4
                nr_nibbles = 1;
                clr = 'uint8';
                cl = 'uint16';
            elseif nbits_per_row(1) <= 8
                nr_nibbles = 2;
                clr = 'uint8';
                cl = 'uint32';
            else
                nr_nibbles = 4;
                clr = 'uint16';
                cl = 'uint64';
            end

            Hrows = cast(zeros(4, ncols), clr);

            % Find the first rows of nbits
            tmp = bitshift(H, -16 * nr_nibbles + nbits_per_row(1));
            Hrows(1, :) = tmp;

            % Find the second rows of nbits
            H = H - bitshift(tmp, 16 * nr_nibbles - nbits_per_row(1));
            tmp = bitshift(H, -12 * nr_nibbles + nbits_per_row(2));
            Hrows(2, :) = tmp;

            % Find the third rows of nbits
            H = H - bitshift(tmp, 12 * nr_nibbles - nbits_per_row(2));
            tmp = bitshift(H, -8 * nr_nibbles + nbits_per_row(3));
            Hrows(3, :) = tmp;

            % Find the last rows of nbits
            H = H - bitshift(tmp, 8 * nr_nibbles - nbits_per_row(3));
            tmp = bitshift(H, -4 * nr_nibbles + nbits_per_row(4));
            Hrows(4, :) = tmp;
            Hrows = cast(Hrows, cl);
            H = bitshift(Hrows(1, :), sum(nbits_per_row(2:4))) + ...
                bitshift(Hrows(2, :), sum(nbits_per_row(3:4))) + ...
                bitshift(Hrows(3, :), nbits_per_row(4)) + Hrows(4, :);
        end

        function H = matrix_to_arr(matrix, bitSize)
            % Calculate the number of bytes based on bit size
            numBytes = ceil(bitSize / 8);  % Ensure numBytes is an integer

            % Get the number of columns in the matrix
            numColumns = size(matrix, 2);

            % Initialize the result array as uint64 to handle all cases initially
            H = zeros(1, numColumns, 'uint64');

            % Convert each column to the appropriate bit-size integer
            for col = 1:numColumns
                % Initialize the integer result for this column
                int_result = uint64(0);

                % Get the current column as an array
                arr = matrix(:, col);

                % Convert the array to the appropriate bit-size integer
                for i = 1:numBytes
                    int_result = bitor(int_result, bitshift(uint64(arr(i)), 8 * (numBytes - i)));
                end

                % Mask the result to ensure it fits within the bitSize
                mask = bitshift(1, bitSize) - 1;  % Create a mask with `bitSize` bits set
                H(col) = bitand(int_result, mask);  % Apply the mask to truncate any excess bits
            end

            % Cast to uint32 if bitSize is less than or equal to 32
            if bitSize <= 32
                H = uint32(H);
            end
        end

        function H = arr_to_matrix(arr, bitSize)
            % Calculate the number of bytes based on bit size
            numBytes = ceil(bitSize / 8);

            % Determine the number of integers in the input array
            numIntegers = length(arr);

            % Initialize the matrix to store the 8-bit arrays
            H = zeros(numBytes, numIntegers, 'uint8');

            % Convert each integer back into a column of 8-bit integers
            for col = 1:numIntegers
                currentInt = arr(col);

                % Extract each 8-bit value
                for i = 1:numBytes
                    H(i, col) = bitand(bitshift(currentInt, -8 * (numBytes - i)), 255);
                end
            end
        end

    end
end
