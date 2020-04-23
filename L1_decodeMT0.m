function [svdata, igpdata, mt10] = L1_decodeMT0(time, msg, svdata, igpdata, mt10, test_mode)
%*************************************************************************
%*     Copyright c 2020 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% Decodes Message Type 0 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

%if not in test mode or if it is a zero filled type zero (ZFTZ), erase all old data 
if ~test_mode || strcmp(msg(15:226), repmat('0',1, 212))
    svdata = init_svdata();
    igpdata = init_igp_msg_data();
    mt10 = init_mt10data();
else
    %move older data into corresponding slots
    svdata.mt2_fc(1:12,2:6) = svdata.mt2_fc(1:12,1:5);
    svdata.mt2_fc_time(1:12,2:6) = svdata.mt2_fc_time(1:12,1:5);
    svdata.mt2_fc_iodf(1:12,2:6) = svdata.mt2_fc_iodf(1:12,1:5);

    svdata.mt2_fc_time(1:12,1) = time;

    svdata.mt2_fc_iodf(1:12,1) = bin2dec(msg(15:16));
    svdata.mt2_fc_iodp(1:12) = bin2dec(msg(17:18));
    idx = 18;
    for sdx = 1:12
        svdata.mt2_fc(sdx,1) = twos2dec(msg((idx + 1):(idx + 12)))*0.125;
        idx = idx + 12;
    end
    idx = 174;
    for sdx = 1:12
        svdata.mt2_udrei(sdx,1) = bin2dec(msg((idx + 1):(idx + 4))) + 1; %convert from MOPS 0-15 to matlab 1-16
        idx = idx + 4;
    end    
end