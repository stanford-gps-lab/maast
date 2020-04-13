%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Grace Gao Dec 18 2008
% read NSTB data in matlab
% output: WAAS satellite Doppler
% Modified March 12, 2020 by Todd Walter to ouput WAAS GEO data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fileName = 'Geo138_00b5_2097_04';
pathName = '';


fid_in  = fopen([pathName fileName ], 'r');
ReadLength = 86400;

GPSWeek = zeros(ReadLength, 1);
GPSReceiveTime_msec = zeros(ReadLength, 1);
MessageType  = zeros(ReadLength, 1);
PRN  = zeros(ReadLength, 1);
SBASMessage  = zeros(ReadLength, 32,'uint8');

i=1;
j=1;
ReadHead = dec2hex(fread(fid_in,1, 'uint32', 0));
while ( (i<=ReadLength) & ( ReadHead == 'ADDECEFA')) % check the head is correct. Head: FACEDEAD
    GPSWeek(i)= fread(fid_in,1, 'uint8', 0)*2^8+fread(fid_in,1, 'uint8', 0);
    temp = fread(fid_in,4, 'uint8', 0);
    GPSReceiveTime_msec(i)=temp(1)*2^24+temp(2)*2^16+temp(3)*2^8+temp(4);
    
    MessageType(i) = fread(fid_in,1, 'uchar');
    
%     if i ==  36883
%         i
%     end
    if MessageType(i) ==1
         fseek(fid_in, 10, 0);
         NumDualChannels = fread(fid_in,1, 'uchar');
         NumSingleChannels = fread(fid_in,1, 'uchar');
         fseek(fid_in, 49*NumDualChannels, 0);
         for k=1:NumSingleChannels
                PRN = fread(fid_in,1, 'uchar');
                SVstatusFlags = fread(fid_in,1, 'ulong');
                L1PseudoRange = fread(fid_in,1, 'double');
                L1CarrierRange = fread(fid_in,1, 'double');
%               fseek(fid_in, 20, 0);
                Doppler = fread(fid_in,1, 'float');
                if PRN == 135 %120 for BGR. Different receiver type?  %130 for EKO & MNL
                    WAAS135Doppler(i) = Doppler; 
                    WAAS135L1PeudoRange(i) = L1PseudoRange; 
                    WAAS135L1CarrierRange(i) = L1CarrierRange; 
                    
                elseif PRN ==138
                    WAAS138Doppler(i) = Doppler ;
                    WAAS138L1PeudoRange(i) = L1PseudoRange; 
                    WAAS138L1CarrierRange(i) = L1CarrierRange; 
                    
                end
                fseek(fid_in, 4, 0);              
         end
         fseek(fid_in, 2, 0); 
         
    elseif MessageType(i) ==5
         fseek(fid_in, 8, 0);
         NumGEOTracked = fread(fid_in,1, 'uchar', 0);
         for k=1:NumGEOTracked
             PRN(j) = fread(fid_in,1, 'uchar');
             SBASMessage(j,:) = fread(fid_in,32, 'uchar');
             j = j+1;
         end
         fseek(fid_in, 2, 0); 


    elseif MessageType(i) ==20
        fseek(fid_in, 76, 0);
    elseif MessageType(i) ==30
        fseek(fid_in, 22, 0);
    elseif MessageType(i) ==31
        fseek(fid_in, 24, 0);
    elseif MessageType(i) ==32
        fseek(fid_in, 10, 0);   
        NumSVs=fread(fid_in,1, 'uchar');
        fseek(fid_in, 28*NumSVs+2, 0); 
    elseif MessageType(i) ==40
        fseek(fid_in, 46, 0);
        
    else
        MessageType(i);
        i
    end
 ReadHead = dec2hex(fread(fid_in,1, 'uint32', 0));

i=i+1;
end

fclose(fid_in);


save sbasmessages_138_19Mar2020 GPSWeek GPSReceiveTime_msec PRN SBASMessage


% % prepend file with first ten minutes of the previous day
% clear variables
% load sbasmessages_138_18Mar2020
% tmp_GPSWeek = GPSWeek((end-600):end);
% tmp_GPSReceiveTime_msec = GPSReceiveTime_msec((end-600):end);
% tmp_PRN = PRN((end-600):end);
% tmp_SBASMessage = SBASMessage((end-600):end,:);
% 
% clear GPSWeek GPSReceiveTime_msec PRN SBASMessage
% load sbasmessages_138_19Mar2020
% GPSWeek = [tmp_GPSWeek; GPSWeek];
% GPSReceiveTime_msec = [tmp_GPSReceiveTime_msec; GPSReceiveTime_msec];
% PRN = [tmp_PRN; PRN];
% SBASMessage = [tmp_SBASMessage; SBASMessage];
% save sbasmessages_138_19Mar2020 GPSWeek GPSReceiveTime_msec PRN SBASMessage


