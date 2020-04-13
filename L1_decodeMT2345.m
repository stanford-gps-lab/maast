function svdata = L1_decodeMT2345(time, msg, svdata)

mtype = bin2dec(msg(9:14));
jdx = (mtype - 2)*13 + 1;

if mtype == 5
    max_sdx = 11;
else
    max_sdx = 12;
end

%move older data into corresponding slots
svdata.mt2_fc(jdx:min([jdx+12 51]),2:6) = svdata.mt2_fc(jdx:min([jdx+12 51]),1:5);
svdata.mt2_fc_time(jdx:min([jdx+12 51]),2:6) = svdata.mt2_fc_time(jdx:min([jdx+12 51]),1:5);
svdata.mt2_fc_iodf(jdx:min([jdx+12 51]),2:6) = svdata.mt2_fc_iodf(jdx:min([jdx+12 51]),1:5);

svdata.mt2_fc_time(jdx:min([jdx+12 51]),1) = time;

svdata.mt2_fc_iodf(jdx:min([jdx+12 51]),1) = bin2dec(msg(15:16));
svdata.mt2_fc_iodp(jdx:min([jdx+12 51])) = bin2dec(msg(17:18));
idx = 18;
for sdx = 0:max_sdx
    svdata.mt2_fc(jdx + sdx,1) = twos2dec(msg((idx + 1):(idx + 12)))*0.125;
    idx = idx + 12;
end
idx = 174;
for sdx = 0:max_sdx
    svdata.mt2_udrei(jdx + sdx,1) = bin2dec(msg((idx + 1):(idx + 4))) + 1; %convert from MOPS 0-15 to matlab 1-16
    idx = idx + 4;
end

