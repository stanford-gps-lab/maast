function svdata = L5_decodeMT40(time, msg, svdata)
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
% Decodes Message Type 40
%   per ED-259A
%
% SEE ALSO: L1_decode_messages

%created 29 December, 2020 by Todd Walter

%Header
iodg = bin2dec(msg(11:12)); % IODG
svdata.mt40(iodg + 1, 1).iodg = iodg; % IODG

% copy older messages over
svdata.mt40(iodg + 1, 2:end) = svdata.mt40(iodg + 1, 1:(end-1));

%Keplerian parameters part II
svdata.mt40(iodg + 1, 1).i = bin2dec(msg(13:45))*pi*(2^-33); %Inclination angle at te
svdata.mt40(iodg + 1, 1).e = bin2dec(msg(46:75))*(2^-30); %Eccentricity
svdata.mt40(iodg + 1, 1).a = bin2dec(msg(76:106))*0.02 + 6370000.0; %Semi-major axis
svdata.mt40(iodg + 1, 1).te = bin2dec(msg(107:119))*16 + floor(time/86400)*86400; %te
if svdata.mt40(iodg + 1, 1).te - time < -43200 %adjust for day rollover
    svdata.mt40(iodg + 1, 1).te = svdata.mt40(iodg + 1, 1).te + 86400;
elseif svdata.mt40(iodg + 1, 1).te - time > 43200
    svdata.mt40(iodg + 1, 1).te = svdata.mt40(iodg + 1, 1).te - 86400;
end        

%MT28 parameters
idx = 120;
svdata.mt40(iodg + 1, 1).sc_exp = bin2dec(msg(idx:(idx+2))); % scale factor exponent
idx = idx + 3;
svdata.mt40(iodg + 1, 1).E(iodg + 1, 1)  = bin2dec(msg(idx:(idx+8)));  %E11
idx = idx + 9;   
svdata.mt40(iodg + 1, 1).E(5)  = bin2dec(msg(idx:(idx+8)));  %E22
idx = idx + 9;           
svdata.mt40(iodg + 1, 1).E(8)  = bin2dec(msg(idx:(idx+8)));  %E33
idx = idx + 9;           
svdata.mt40(iodg + 1, 1).E(10) = bin2dec(msg(idx:(idx+8)));  %E44
idx = idx + 9;   
svdata.mt40(iodg + 1, 1).E(2) = twos2dec(msg(idx:(idx+9)));  %E12
idx = idx + 10;        
svdata.mt40(iodg + 1, 1).E(3) = twos2dec(msg(idx:(idx+9)));  %E13
idx = idx + 10; 
svdata.mt40(iodg + 1, 1).E(4) = twos2dec(msg(idx:(idx+9)));  %E14
idx = idx + 10; 
svdata.mt40(iodg + 1, 1).E(6) = twos2dec(msg(idx:(idx+9)));  %E23
idx = idx + 10;
svdata.mt40(iodg + 1, 1).E(7) = twos2dec(msg(idx:(idx+9)));  %E24
idx = idx + 10; 
svdata.mt40(iodg + 1, 1).E(9) = twos2dec(msg(idx:(idx+9)));  %E34
idx = idx + 10;         
SF = 2^(svdata.mt40(iodg + 1, 1).sc_exp - 5);
R = SF*[svdata.mt40(iodg + 1, 1).E(1:4); [0 svdata.mt40(iodg + 1, 1).E(5:7)]; ...
        [0 0 svdata.mt40(iodg + 1, 1).E(8:9)]; [0 0 0 svdata.mt40(iodg + 1, 1).E(10)]];
C = R'*R;
svdata.mt40(iodg + 1, 1).dCov = C(:)';

% decode DFREI and Rcorr scale factor
svdata.mt40(iodg + 1, 1).dfrei  = bin2dec(msg(idx:(idx+3))) + 1; %+1 to convert to matlab 1:n indexing
idx = idx + 4; 
svdata.mt40(iodg + 1, 1).dRcorr  = (bin2dec(msg(idx:(idx+2))) + 1)/8;

svdata.mt40(iodg + 1, 1).time = time;

svdata.mt40(iodg + 1, 1).msg_idx = mod(round(time), 700) + 1;
