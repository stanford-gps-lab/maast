function igpdata = L1_decodeMT18(time, msg, igpdata)

bandid = bin2dec(msg(19:22)) + 1;

igpdata.mt18_num_bands(bandid) = bin2dec(msg(15:18));
igpdata.mt18_iodi(bandid) = bin2dec(msg(23:24));
igpdata.mt18_mask(bandid,:) = cast(bin2dec(msg(25:225)'), 'uint8')';

igpdata.mt18_time(bandid) = time;
