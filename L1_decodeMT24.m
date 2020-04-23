function svdata = L1_decodeMT24(time, msg, svdata)
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
% Decodes Message Type 24 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

C = 299792458.0; % speed of light,  m/sec

blockID = bin2dec(msg(113:114));
jdx = blockID*13 + 1;

%move older data into corresponding slots
svdata.mt2_fc(jdx:(jdx+6),2:6) = svdata.mt2_fc(jdx:(jdx+6),1:5);
svdata.mt2_fc_time(jdx:(jdx+6),2:6) = svdata.mt2_fc_time(jdx:(jdx+6),1:5);
svdata.mt2_fc_iodf(jdx:(jdx+6),2:6) = svdata.mt2_fc_iodf(jdx:(jdx+6),1:5);

svdata.mt2_fc_time(jdx:(jdx+6),1) = time;


idx = 15;
for sdx = 0:5
    svdata.mt2_fc(jdx + sdx,1) = twos2dec(msg(idx:(idx + 11)))*0.125;
    idx = idx + 12;
end
for sdx = 0:5
    svdata.mt2_udrei(jdx + sdx,1) = bin2dec(msg(idx:(idx + 3))) + 1; %convert from MOPS 0-15 to matlab 1-16
    idx = idx + 4;
end

svdata.mt2_fc_iodp(jdx:(jdx+6),1) = bin2dec(msg(idx:(idx+1))); %IODP
idx = idx + 2 + 2;  %extra 2 bits for Block ID (read in earlier)

svdata.mt2_fc_iodf(jdx:(jdx+6)) = bin2dec(msg(idx:(idx+1))); %IODF
idx = idx + 2 + 4; %extra 4 bits for spare bits

%half MT25
vcode = bin2dec(msg(idx));
idx = idx + 1;
sdx = bin2dec(msg(idx:(idx+5)));
idx = idx + 6;
%velocity code = 1
if vcode && sdx
    t_adjust = floor(time/86400)*86400;
    svdata.mt25_iode(sdx) = bin2dec(msg(idx:(idx+7))); %IODE
    idx = idx + 8;
    svdata.mt25_dxyzb(sdx, 1) = twos2dec(msg(idx:(idx+10)))*0.125; %delta_x
    idx = idx + 11;        
    svdata.mt25_dxyzb(sdx, 2) = twos2dec(msg(idx:(idx+10)))*0.125; %delta_y
    idx = idx + 11;        
    svdata.mt25_dxyzb(sdx, 3) = twos2dec(msg(idx:(idx+10)))*0.125; %delta_z
    idx = idx + 11;       
    svdata.mt25_dxyzb(sdx, 4) = C*twos2dec(msg(idx:(idx+10)))*(2^(-31));   %delta_af0
    idx = idx + 11;        
    svdata.mt25_dxyzb_dot(sdx, 1) = twos2dec(msg(idx:(idx+7)))*(2^(-11));  %delta_x_dot
    idx = idx + 8;         
    svdata.mt25_dxyzb_dot(sdx, 2) = twos2dec(msg(idx:(idx+7)))*(2^(-11));  %delta_y_dot
    idx = idx + 8;
    svdata.mt25_dxyzb_dot(sdx, 3) = twos2dec(msg(idx:(idx+7)))*(2^(-11));  %delta_z_dot
    idx = idx + 8;        
    svdata.mt25_dxyzb_dot(sdx, 4) = C*twos2dec(msg(idx:(idx+7)))*(2^(-39)); %delta_af1
    idx = idx + 8;
    svdata.mt25_t0(sdx) = bin2dec(msg(idx:(idx+12)))*16 + t_adjust;         %t0
    if svdata.mt25_t0(sdx) - time < -43200 %adjust for day rollover
        svdata.mt25_t0(sdx) = svdata.mt25_t0(sdx) + 86400;
    elseif svdata.mt25_t0(sdx) - time > 43200
        svdata.mt25_t0(sdx) = svdata.mt25_t0(sdx) - 86400;
    end            
    idx = idx + 13;
    svdata.mt25_iodp(sdx) = bin2dec(msg(idx:(idx+1))); %IODP
    idx = idx + 2;
    svdata.mt25_time(sdx) = time;
%velocity code = 0 %NOT REALLY TESTED YET
elseif sdx
    %first satellite in half
    svdata.mt25_iode(sdx) = bin2dec(msg(idx:(idx+7))); %IODE
    idx = idx + 8;
    svdata.mt25_dxyzb(sdx, 1) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_x
    idx = idx + 9;        
    svdata.mt25_dxyzb(sdx, 2) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_y
    idx = idx + 9;        
    svdata.mt25_dxyzb(sdx, 3) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_z
    idx = idx + 9;       
    svdata.mt25_dxyzb(sdx, 4) = C*twos2dec(msg(idx:(idx+9)))*(2^(-31)); %delta_af0
    idx = idx + 10;        
    svdata.mt25_time(sdx) = time;
    svdata.mt25_dxyzb_dot(sdx, :) = 0; % make sure the derivatives are set to 0
    svdata.mt25_t0(sdx) = NaN;

    %second satellite in half
    sdx2 = bin2dec(msg(idx:(idx+5)));
    idx = idx + 6;
    if sdx2
        svdata.mt25_iode(sdx2) = bin2dec(msg(idx:(idx+7))); %IODE
        idx = idx + 8;
        svdata.mt25_dxyzb(sdx2, 1) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_x
        idx = idx + 9;        
        svdata.mt25_dxyzb(sdx2, 2) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_y
        idx = idx + 9;        
        svdata.mt25_dxyzb(sdx2, 3) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_z
        idx = idx + 9;       
        svdata.mt25_dxyzb(sdx2, 4) = C*twos2dec(msg(idx:(idx+9)))*(2^(-31)); %delta_af0
        idx = idx + 10;        
        svdata.mt25_iodp(sdx) = bin2dec(msg(idx:(idx+1))); %IODP
        svdata.mt25_iodp(sdx2) = svdata.mt25_iodp(sdx);
        idx = idx + 2 + 1; %extra bit is a spare
        svdata.mt25_time(sdx2) = time;
        svdata.mt25_dxyzb_dot(sdx2, :) = 0; % make sure the derivatives are set to 0
        svdata.mt25_t0(sdx2) = NaN;
    else
        idx = idx + 45; 
        svdata.mt25_iodp(sdx) = bin2dec(msg(idx:(idx+1))); %IODP
        idx = idx + 2 + 1; %extra bit is a spare
    end
end


