function svdata = L1_decodeMT9(time, msg, svdata)
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
% Decodes Message Type 9 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

svdata.mt9_t0 = bin2dec(msg(23:35))*16 + floor(time/86400)*86400; %t0
if svdata.mt9_t0 - time < -43200 %adjust for day rollover
    svdata.mt9_t0 = svdata.mt9_t0 + 86400;
elseif svdata.mt9_t0 - time > 43200
    svdata.mt9_t0 = svdata.mt9_t0 - 86400;
end          
svdata.mt9_ura = bin2dec(msg(36:39)); % URA
svdata.mt9_xyz(1) = twos2dec(msg(40:69))*0.08; %X_G
svdata.mt9_xyz(2) = twos2dec(msg(70:99))*0.08; %Y_G
svdata.mt9_xyz(3) = twos2dec(msg(100:124))*0.4;  %Z_G
svdata.mt9_xyz_dot(1) = twos2dec(msg(125:141))*0.000625; %X_dot_G
svdata.mt9_xyz_dot(2) = twos2dec(msg(142:158))*0.000625; %Y_dot_G
svdata.mt9_xyz_dot(3) = twos2dec(msg(159:176))*0.004;    %Z_dot_G
svdata.mt9_xyz_dot_dot(1) = twos2dec(msg(177:186))*0.0000125; %X_dot_dot_G
svdata.mt9_xyz_dot_dot(2) = twos2dec(msg(187:196))*0.0000125; %Y_dot_dot_G
svdata.mt9_xyz_dot_dot(3) = twos2dec(msg(197:206))*0.0000625; %Z_dot_dot_G
svdata.mt9_af0 = twos2dec(msg(207:218))*(2^(-31)); %a_Gf0
svdata.mt9_af1 = twos2dec(msg(219:226))*(2^(-40)); %a_Gf1
svdata.mt9_time = time;

