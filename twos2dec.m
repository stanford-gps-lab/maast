function x = twos2dec(t)

% Example:
%     >> twos2dec(['010 111'; ' 010111'; '101011 '; ' 10   1'])
%     
%     ans =
%     
%         23
%         23
%        -21
%         -3


if t(1) =='1'
    if length(t) < 32
        t = [repmat('1', 1, 32 - length(t)) t];
        x = cast(bin2dec(t), 'uint32');
        x = -cast((bitcmp(x) + 1), 'int32');
        x = cast(x, 'double');
    else
        warning('too many bits')
    end
else
    x = bin2dec(t);
end