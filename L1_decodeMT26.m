function igpdata = L1_decodeMT26(time, msg, igpdata)

global MOPS_GIVEI_NM

bandid = bin2dec(msg(15:18)) + 1;
kdx = bin2dec(msg(19:22))*15 + 1;
iodi = bin2dec(msg(218:219));

idx = 23;
for sdx = 0:14
    if strcmp(msg(idx:(idx+8)), '111111111') % Special code indicates do not use
        igpdata.mt26_Iv(bandid, kdx + sdx) = NaN;
        igpdata.mt26_givei(bandid, kdx + sdx) = MOPS_GIVEI_NM;
        idx = idx + 13;
    else
        igpdata.mt26_Iv(bandid, kdx + sdx) = bin2dec(msg(idx:(idx+8)))*0.125;
        idx = idx + 9;
        igpdata.mt26_givei(bandid, kdx + sdx) = bin2dec(msg(idx:(idx+3))) + 1; %convert from MOPS 0-15 to matlab 1-16
        idx = idx + 4;
        igpdata.mt26_iodi(bandid, kdx + sdx) = iodi;
        igpdata.mt26_time(bandid, kdx + sdx) = time;
    end
end

