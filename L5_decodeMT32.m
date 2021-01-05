function svdata = L5_decodeMT32(time, msg, svdata)
%*************************************************************************
%*     Copyright c 2021 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% Decodes Message Type 32 
%   per ED-259A
%
% SEE ALSO: L5_decode_messages

%created 28 December, 2020 by Todd Walter

% copy older messages over
svdata.mt32(2:end) = svdata.mt32(1:(end-1));

t_adjust = floor(time/86400)*86400;

%decode satellite prn
idx = 11;
sdx = bin2dec(msg(idx:(idx+8)));
idx = idx + 9;

%decode satellite corrections
svdata.mt32(1).iodn(sdx) = bin2dec(msg(idx:(idx+9))); %IODE
idx = idx + 10;
svdata.mt32(1).dxyzb(sdx, 1) = twos2dec(msg(idx:(idx+10)))*0.0625; %delta_x
idx = idx + 11;        
svdata.mt32(1).dxyzb(sdx, 2) = twos2dec(msg(idx:(idx+10)))*0.0625; %delta_y
idx = idx + 11;        
svdata.mt32(1).dxyzb(sdx, 3) = twos2dec(msg(idx:(idx+10)))*0.0625; %delta_z
idx = idx + 11;       
svdata.mt32(1).dxyzb(sdx, 4) = twos2dec(msg(idx:(idx+11)))*0.03125;   %delta_B
idx = idx + 12;        
svdata.mt32(1).dxyzb_dot(sdx, 1) = twos2dec(msg(idx:(idx+7)))*(2^(-11));  %delta_x_dot
idx = idx + 8;         
svdata.mt32(1).dxyzb_dot(sdx, 2) = twos2dec(msg(idx:(idx+7)))*(2^(-11));  %delta_y_dot
idx = idx + 8;
svdata.mt32(1).dxyzb_dot(sdx, 3) = twos2dec(msg(idx:(idx+7)))*(2^(-11));  %delta_z_dot
idx = idx + 8;        
svdata.mt32(1).dxyzb_dot(sdx, 4) = twos2dec(msg(idx:(idx+8)))*(2^(-12)); %delta_af1
idx = idx + 9;
svdata.mt32(1).t0(sdx) = bin2dec(msg(idx:(idx+12)))*16 + t_adjust;         %t0
if svdata.mt32(1).t0(sdx) - time < -43200 %adjust for day rollover
    svdata.mt32(1).t0(sdx) = svdata.mt32(1).t0(sdx) + 86400;
elseif svdata.mt32(1).t0(sdx) - time > 43200
    svdata.mt32(1).t0(sdx) = svdata.mt32(1).t0(sdx) - 86400;
end            
idx = idx + 13;

%decode satellite MT 28 parameters
svdata.mt32(1).sc_exp(sdx) = bin2dec(msg(idx:(idx+2)));
idx = idx + 3;
svdata.mt32(1).E(sdx, 1)  = bin2dec(msg(idx:(idx+8)));  %E11
idx = idx + 9;   
svdata.mt32(1).E(sdx, 5)  = bin2dec(msg(idx:(idx+8)));  %E22
idx = idx + 9;           
svdata.mt32(1).E(sdx, 8)  = bin2dec(msg(idx:(idx+8)));  %E33
idx = idx + 9;           
svdata.mt32(1).E(sdx, 10) = bin2dec(msg(idx:(idx+8)));  %E44
idx = idx + 9;   
svdata.mt32(1).E(sdx, 2) = twos2dec(msg(idx:(idx+9)));  %E12
idx = idx + 10;        
svdata.mt32(1).E(sdx, 3) = twos2dec(msg(idx:(idx+9)));  %E13
idx = idx + 10; 
svdata.mt32(1).E(sdx, 4) = twos2dec(msg(idx:(idx+9)));  %E14
idx = idx + 10; 
svdata.mt32(1).E(sdx, 6) = twos2dec(msg(idx:(idx+9)));  %E23
idx = idx + 10;
svdata.mt32(1).E(sdx, 7) = twos2dec(msg(idx:(idx+9)));  %E24
idx = idx + 10; 
svdata.mt32(1).E(sdx, 9) = twos2dec(msg(idx:(idx+9)));  %E34
idx = idx + 10; 

SF = 2^(svdata.mt32(1).sc_exp(sdx) - 5);
R = SF*[svdata.mt32(1).E(sdx, 1:4); [0 svdata.mt32(1).E(sdx, 5:7)]; ...
        [0 0 svdata.mt32(1).E(sdx, 8:9)]; [0 0 0 svdata.mt32(1).E(sdx, 10)]];
C = R'*R;
svdata.mt32(1).dCov(sdx,:) = C(:)';

% decode DFREI and Rcorr scale factor
svdata.mt32(1).dfrei(sdx)  = bin2dec(msg(idx:(idx+3))) + 1;
idx = idx + 4; 
svdata.mt32(1).dRcorr(sdx)  = (bin2dec(msg(idx:(idx+2))) + 1)/8;

svdata.mt32(1).time(sdx) = time;
