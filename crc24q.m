
function crc = crc24q(msg, num_bit)

%  Function : CRC24Q(MSG)
%  -----------------------------------------
%  Generate SBAS MOPS CRC parity ( 24 bits ) to provide
%  protection against burst as well as random errors
%  with a probability of undetected error < 2^(-24).
%  

if nargin < 2
    num_bit = 250;
end

CRC24 = cast(hex2dec('864CFB'), 'uint32');       % WAAS - CRC24Q


% Initialize first 24 bits
crc =  cast(bin2dec(msg(1:24)), 'uint32');

  for bit_index=25:num_bit
    leadbit = bitshift(bitand(crc, cast(hex2dec('00800000'), 'uint32')), -23);

    % left-shift and add one bit
    crc = bitor(bitand(bitshift(crc,1), cast(hex2dec('00ffffff'), 'uint32')), bin2dec(msg(bit_index))); 

    if (leadbit == 1) 
		crc = bitxor(crc, CRC24);
    end
  end
  % extract only last 24 bits
  crc = bitand(crc, cast(hex2dec('00ffffff'), 'uint32')); 
