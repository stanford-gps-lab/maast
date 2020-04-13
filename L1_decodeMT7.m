function svdata = L1_decodeMT7(time, msg, svdata)

svdata.mt7_t_lat = bin2dec(msg(15:18));
svdata.mt7_iodp = bin2dec(msg(19:20));
idx = 22;
for jdx = 1:51
    svdata.mt7_ai(jdx) = bin2dec(msg((idx + 1):(idx + 4)));
    idx = idx + 4;
end

svdata.mt7_time = time;
