function [msg, time, geo_prn, band] = read_sbas_rinex(filename)


% Norbert Suard?s proposal for SBAS Correction messages packaged into RINEX format.
% https://gssc.esa.int/wp-content/uploads/2018/07/geo_sbas.txt
%  
% CNES FTP Server providing all SBAS messages 
% ftp://serenad-public.cnes.fr/SERENAD0/FROM_NTMFV2/MSG/
 

%variable initialization
nEpochsAdd = 3600;
nEpochs = 3600;
time = NaN(nEpochs,1);
tow = NaN(nEpochs,1);
date = NaN(nEpochs,6);
msg = cast(zeros(nEpochs,32),'uint8');
geo_band = NaN;

%open RINEX observation file
fid = fopen(filename,'r');

%read the header file
geo_prn = RINEX_parse_sbas_hdr(fid);

mtype_set = [0:7 9 10 12 17 18 24:28 63]; %standard L1 SBAS message types

k = 1;    
while (~feof(fid))

    if (k > nEpochs)
        msg2 = cast(zeros(nEpochs+nEpochsAdd,size(msg,2)),'uint8');
        msg2(1:size(msg,1),:) = msg;
        msg = msg2;
        clearvars msg2

        date2 = nan(nEpochs+nEpochsAdd,size(date,2));
        date2(1:size(date,1),:) = date;
        date = date2;
        clearvars date2

        tow2 = nan(nEpochs+nEpochsAdd,size(tow,2));
        tow2(1:size(tow,1)) = tow;
        tow = tow2;
        clearvars tow2

        time2 = nan(nEpochs+nEpochsAdd,size(time,2));
        time2(1:size(time,1)) = time;
        time = time2;
        clearvars time2

        nEpochs = nEpochs  + nEpochsAdd;
    end

    %read data for the current epoch (ROVER)
    [time(k,1), date(k,:), prn, band, tow(k,1)] = RINEX_get_sbas_epoch(fid);
    
    %verify PRN number
    if prn ~= geo_prn
        fprintf('PRN mismatch %3d vs. %3d\n', prn, geo_prn);
    end

    %verify band
    if ~isnan(geo_band)
        if ~strcmp(band, geo_band)
            disp(['Broadcast band mismatch ' band ' vs. ' geo_band]);
        end
    else
        geo_band = band;
    end
    
    %read SBAS messages
    [mtype, msg(k,:)] = RINEX_get_sbas_msg(fid);
    if ~ismember(mtype, mtype_set)
        fprintf('Unexpected message number %d on PRN %d\n', mtype, prn);
        mtype_set = [mtype_set mtype]; %only show message once
    end
    k = k + 1;
end

%remove empty rows
k = k - 1;
time = floor(time(1:k)); % use the beginning of the second
msg = msg(1:k,:);

%close RINEX files
fclose(fid);

