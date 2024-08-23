function svdata = L1_decodeMT1(time, msg, svdata)
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
% Decodes Message Type 1 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

global MOPS_MIN_GPSPRN MOPS_MAX_GPSPRN MOPS_MIN_GLOPRN MOPS_MAX_GLOPRN 
global MOPS_MIN_GEOPRN MOPS_MAX_GEOPRN

% copy older messages over
svdata.mt1(2:end) = svdata.mt1(1:(end-1));

svdata.mt1(1).mask = cast(bin2dec(msg(15:224)'), 'uint8');

svdata.mt1(1).iodp = bin2dec(msg(225:226));

svdata.mt1(1).time = time;

kdx = 1:212;
prns = kdx(svdata.mt1(1).mask>0)';
svdata.prns(1:length(prns)) = prns;
svdata.mt1(1).ngps = sum(prns >= MOPS_MIN_GPSPRN & prns <= MOPS_MAX_GPSPRN);
svdata.mt1(1).nglo = sum(prns >= MOPS_MIN_GLOPRN & prns <= MOPS_MAX_GLOPRN);
svdata.mt1(1).ngeo = sum(prns >= MOPS_MIN_GEOPRN & prns <= MOPS_MAX_GEOPRN);
svdata.mt1(1).nmeo = svdata.mt1(1).ngps + svdata.mt1(1).nglo;
slot = 1;
svdata.mt1(1).prn2slot = NaN(size(svdata.mt1(1).prn2slot));
svdata.mt1(1).slot2prn = NaN(size(svdata.mt1(1).slot2prn));
for prn = 1:210
    if svdata.mt1(1).mask(prn)
        svdata.mt1(1).prn2slot(prn) = slot;
        svdata.mt1(1).slot2prn(slot) = prn;
        slot = slot + 1;
    end
end

svdata.mt1(1).msg_idx = mod(round(time), 700) + 1;