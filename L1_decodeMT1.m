function svdata = L1_decodeMT1(time, msg, svdata)


svdata.mt1_mask = cast(bin2dec(msg(15:224)'), 'uint8');

svdata.mt1_iodp = bin2dec(msg(225:226));

svdata.mt1_time = time;