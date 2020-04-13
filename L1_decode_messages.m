function [svdata, igpdata, mt10, flag] = L1_decode_messages(time, msg, svdata, igpdata, mt10)
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

global MOPS_L1_PREAMBLE

flag  = 0;

if crc24q(msg)
    warning('CRC does not match')
    return
end
if ~strcmp(msg(1:8), MOPS_L1_PREAMBLE(mod(round(time), 3) + 1,:))
    warning('preamble does not match')
    return
end

flag = 1;
mt = bin2dec(msg(9:14));

switch mt
    case 0
        [svdata, igpdata, mt10] = L1_decodeMT0(time, msg, svdata, igpdata, mt10, 1);
    case 1
        svdata = L1_decodeMT1(time, msg, svdata);
    case {2, 3, 4, 5}
        svdata = L1_decodeMT2345(time, msg, svdata);
    case 6
        svdata = L1_decodeMT6(time, msg, svdata);
    case 7
        svdata = L1_decodeMT7(time, msg, svdata);
    case 9
        svdata = L1_decodeMT9(time, msg, svdata);
    case 10
        mt10 = L1_decodeMT10(time, msg);
    case 17
        svdata = L1_decodeMT17(time, msg, svdata); 
    case 18
        igpdata = L1_decodeMT18(time, msg, igpdata); 
    case 24
        svdata = L1_decodeMT24(time, msg, svdata);
    case 25
        svdata = L1_decodeMT25(time, msg, svdata);
    case 26
        igpdata = L1_decodeMT26(time, msg, igpdata); 
    case 27
        svdata = L1_decodeMT27(time, msg, svdata);        
    case 28
        svdata = L1_decodeMT28(time, msg, svdata);  
end