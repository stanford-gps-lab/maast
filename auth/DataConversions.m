classdef DataConversions
    % DATACONVERSIONS Contains static hashing methods pertinant to unit
    % conversions

    methods (Static)

        function uint8_array = int_to_uint8_16_array(input_integer)
            % INT_TO_UINT8_16_ARRAY  Convert an integer into a 16x1 uint8 column vector
            %   input_integer - an integer input
            %   returns - time as 16x1 uint8 vector
            decimal = reshape(DataConversions.de2bi(input_integer, 128)', [], 16)';
            uint8_array = uint8(DataConversions.bi2de(decimal));
        end

        function uint8_array = binary_string_to_uint8(bin_string)
            % BINARY_STRING_TO_UINT8  Convert a 250 char binary string into a 32x1 uint8 column vector
            %   bin_string - a string of 1s and 0s
            %   returns - bin_string as a 32x1 uint8 vector
            msg_logical = strcat(bin_string, '000000') == '1';
            uint8_array = uint8(DataConversions.bi2de(reshape(msg_logical, 8, 32)')')';
        end

        function binary_array = de2bi(array, size)
            % DE2BI Convert binary arrays with Left-MSB orientation to decimal arrays.
            %   array - an array of decimal number
            %   size - desired size of binary output for each number
            %   returns - binary array as logical array
            max_elem = max(array);
            min_size = floor(log2(double(max_elem))) + 1;
            if size < min_size
                error('DATACONVERSIONS:numColsToSmall', ...
                      'Specified number of columns in output matrix is too small');
            else
                binary_array = logical(rem(floor(double(array(:)) * pow2(1 - size:0)), 2));
            end

        end

        function dec_number = bi2de(binary_num)
            % BI2DE Converts a binary number into its decimal equivelent
            % using left msb
            %   binary_num - a logical array for a binary number
            %   returns - a decimal number as double
            pow2vector = 2.^((size(binary_num, 2) - 1):-1:0)';
            dec_number = binary_num * pow2vector;

        end

    end
end
