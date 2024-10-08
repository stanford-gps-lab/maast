function svdata = L1_decodeMT28(time, msg, svdata)
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
% Decodes Message Type 28 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter


iodp = bin2dec(msg(15:16));

idx = 17;
for jdx = 1:2
    sdx = bin2dec(msg(idx:(idx+5))); 
    idx = idx + 6;
    if sdx
        % copy older messages over
        svdata.mt28(sdx,2:end) = svdata.mt28(sdx,1:(end-1));

        svdata.mt28(sdx,1).iodp = iodp;
        svdata.mt28(sdx,1).sc_exp = bin2dec(msg(idx:(idx+2)));
        idx = idx + 3;
        svdata.mt28(sdx,1).E(1)  = bin2dec(msg(idx:(idx+8)));  %E11
        idx = idx + 9;   
        svdata.mt28(sdx,1).E(5)  = bin2dec(msg(idx:(idx+8)));  %E22
        idx = idx + 9;           
        svdata.mt28(sdx,1).E(8)  = bin2dec(msg(idx:(idx+8)));  %E33
        idx = idx + 9;           
        svdata.mt28(sdx,1).E(10) = bin2dec(msg(idx:(idx+8)));  %E44
        idx = idx + 9;   
        svdata.mt28(sdx,1).E(2) = twos2dec(msg(idx:(idx+9)));  %E12
        idx = idx + 10;        
        svdata.mt28(sdx,1).E(3) = twos2dec(msg(idx:(idx+9)));  %E13
        idx = idx + 10; 
        svdata.mt28(sdx,1).E(4) = twos2dec(msg(idx:(idx+9)));  %E14
        idx = idx + 10; 
        svdata.mt28(sdx,1).E(6) = twos2dec(msg(idx:(idx+9)));  %E23
        idx = idx + 10;
        svdata.mt28(sdx,1).E(7) = twos2dec(msg(idx:(idx+9)));  %E24
        idx = idx + 10; 
        svdata.mt28(sdx,1).E(9) = twos2dec(msg(idx:(idx+9)));  %E34
        idx = idx + 10;         
        svdata.mt28(sdx,1).time = time;
        svdata.mt28(sdx,1).msg_idx = mod(round(time), 700) + 1;
        SF = 2^(svdata.mt28(sdx,1).sc_exp - 5);
        R = SF*[svdata.mt28(sdx,1).E(1:4); [0 svdata.mt28(sdx,1).E(5:7)]; ...
                [0 0 svdata.mt28(sdx,1).E(8:9)]; [0 0 0 svdata.mt28(sdx,1).E(10)]];
        C = R'*R;
        svdata.mt28(sdx,1).dCov = C(:)';
    end
end

if time > svdata.mt28_time
    svdata.mt28_time = time;
end

