function svdata = L5_decodeMT0(time, msg, svdata, test_mode)
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
%   per ED-259A
%
% SEE ALSO: L1_decode_messages

%created 28 December, 2020 by Todd Walter

%if not in test mode or if it is a zero filled type zero (ZFTZ), erase all old data 
if ~test_mode || strcmp(msg(11:226), repmat('0',1, 216))
    svdata = init_L5svdata();
else
    %check to see if it matches MT 35   %%%%%TODO  code up for MT 34 & 36
    if bin2dec(msg(223:224)) == 1
        %read in DFREIs
        idx = 11;
        for jdx = 1:53
            svdata.mt35_dfrei(jdx) = bin2dec(msg(idx:(idx+3))) + 1; %convert from MOPS 0-15 to matlab 1-16
            idx = idx + 4;
        end

        % skip two reserve bits
        idx = idx + 2;

        %read in IODM
        svdata.mt35_iodm = bin2dec(msg(idx:(idx+3)));

        svdata.mt35_time = time;
    end
end