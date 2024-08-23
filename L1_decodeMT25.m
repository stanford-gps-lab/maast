function svdata = L1_decodeMT25(time, msg, svdata)
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
% Decodes Message Type 25 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

C = 299792458.0; % speed of light,  m/sec

t_adjust = floor(time/86400)*86400;
idx = 15;
for jdx = 1:2
    vcode = bin2dec(msg(idx));
    idx = idx + 1;
    sdx = bin2dec(msg(idx:(idx+5)));
    idx = idx + 6;
    %velocity code = 1
    if vcode && sdx
        % copy older messages over
        svdata.mt25(sdx,2:end) = svdata.mt25(sdx,1:(end-1)); 
        
        svdata.mt25(sdx).iode = bin2dec(msg(idx:(idx+7))); %IODE
        idx = idx + 8;
        svdata.mt25(sdx).dxyzb(1) = twos2dec(msg(idx:(idx+10)))*0.125; %delta_x
        idx = idx + 11;        
        svdata.mt25(sdx).dxyzb(2) = twos2dec(msg(idx:(idx+10)))*0.125; %delta_y
        idx = idx + 11;        
        svdata.mt25(sdx).dxyzb(3) = twos2dec(msg(idx:(idx+10)))*0.125; %delta_z
        idx = idx + 11;       
        svdata.mt25(sdx).dxyzb(4) = C*twos2dec(msg(idx:(idx+10)))*(2^(-31));   %delta_af0
        idx = idx + 11;        
        svdata.mt25(sdx).dxyzb_dot(1) = twos2dec(msg(idx:(idx+7)))*(2^(-11));  %delta_x_dot
        idx = idx + 8;         
        svdata.mt25(sdx).dxyzb_dot(2) = twos2dec(msg(idx:(idx+7)))*(2^(-11));  %delta_y_dot
        idx = idx + 8;
        svdata.mt25(sdx).dxyzb_dot(3) = twos2dec(msg(idx:(idx+7)))*(2^(-11));  %delta_z_dot
        idx = idx + 8;        
        svdata.mt25(sdx).dxyzb_dot(4) = C*twos2dec(msg(idx:(idx+7)))*(2^(-39)); %delta_af1
        idx = idx + 8;
        svdata.mt25(sdx).t0 = bin2dec(msg(idx:(idx+12)))*16 + t_adjust;         %t0
        if svdata.mt25(sdx).t0 - time < -43200 %adjust for day rollover
            svdata.mt25(sdx).t0 = svdata.mt25(sdx).t0 + 86400;
        elseif svdata.mt25(sdx).t0 - time > 43200
            svdata.mt25(sdx).t0 = svdata.mt25(sdx).t0 - 86400;
        end            
        idx = idx + 13;
        svdata.mt25(sdx).iodp = bin2dec(msg(idx:(idx+1))); %IODP
        idx = idx + 2;
        svdata.mt25(sdx).time = time;
        svdata.mt25(sdx,1).msg_idx = mod(round(time), 700) + 1;
    %velocity code = 0 %NOT REALLY TESTED YET
    elseif sdx
        %first satellite in half
        svdata.mt25(sdx).iode = bin2dec(msg(idx:(idx+7))); %IODE
        idx = idx + 8;
        svdata.mt25(sdx).dxyzb(s1) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_x
        idx = idx + 9;        
        svdata.mt25(sdx).dxyzb(2) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_y
        idx = idx + 9;        
        svdata.mt25(sdx).dxyzb(3) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_z
        idx = idx + 9;       
        svdata.mt25(sdx).dxyzb(4) = C*twos2dec(msg(idx:(idx+9)))*(2^(-31)); %delta_af0
        idx = idx + 10;        
        svdata.mt25(sdx).time = time;
        svdata.mt25(sdx,1).msg_idx = mod(round(time), 700) + 1;
        svdata.mt25(sdx).dxyzb_dot(1:4) = 0; % make sure the derivatives are set to 0
        svdata.mt25(sdx).t0 = NaN;
        
        %second satellite in half
        sdx2 = bin2dec(msg(idx:(idx+5)));
        idx = idx + 6;
        if sdx2
            svdata.mt25(sdx2).iode = bin2dec(msg(idx:(idx+7))); %IODE
            idx = idx + 8;
            svdata.mt25(sdx2).dxyzb(1) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_x
            idx = idx + 9;        
            svdata.mt25(sdx2).dxyzb(2) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_y
            idx = idx + 9;        
            svdata.mt25(sdx2).dxyzb(3) = twos2dec(msg(idx:(idx+8)))*0.125; %delta_z
            idx = idx + 9;       
            svdata.mt25(sdx2).dxyzb(4) = C*twos2dec(msg(idx:(idx+9)))*(2^(-31)); %delta_af0
            idx = idx + 10;        
            svdata.mt25(sdx).iodp = bin2dec(msg(idx:(idx+1))); %IODP
            svdata.mt25(sdx2).iodp = svdata.mt25_iodp(sdx);
            idx = idx + 2 + 1; %extra bit is a spare
            svdata.mt25(sdx2).time = time;
            svdata.mt25(sdx2,1).msg_idx = mod(round(time), 700) + 1;
            svdata.mt25(sdx2).dxyzb_dot(1:4) = 0; % make sure the derivatives are set to 0
            svdata.mt25(sdx2).t0 = NaN;
        else
            idx = idx + 45; 
            svdata.mt25(sdx).iodp = bin2dec(msg(idx:(idx+1))); %IODP
            idx = idx + 2 + 1; %extra bit is a spare
        end
    end
end

