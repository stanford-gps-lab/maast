function svdata = L5_decodeMT31(time, msg, svdata)
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
% Decodes Message Type 31 
%   per ED-259A
%
% SEE ALSO: L5_decode_messages

%created 28 December, 2020 by Todd Walter

global L5MOPS_MIN_GPSPRN L5MOPS_MAX_GPSPRN L5MOPS_MIN_GLOPRN L5MOPS_MAX_GLOPRN 
global L5MOPS_MIN_GALPRN L5MOPS_MAX_GALPRN L5MOPS_MIN_GEOPRN L5MOPS_MAX_GEOPRN
global L5MOPS_MIN_BDSPRN L5MOPS_MAX_BDSPRN

% copy older messages over
svdata.mt31(2:end) = svdata.mt31(1:(end-1));

svdata.mt31(1).mask = cast(bin2dec(msg(11:224)'), 'uint8');

svdata.mt31(1).iodm = bin2dec(msg(225:226));

svdata.mt31(1).time = time;

kdx = 1:214;
prns = kdx(svdata.mt31(1).mask>0)';
svdata.prns(1:length(prns)) = prns;
svdata.mt31(1).ngps = sum(prns >= L5MOPS_MIN_GPSPRN & prns <= L5MOPS_MAX_GPSPRN);
svdata.mt31(1).nglo = sum(prns >= L5MOPS_MIN_GLOPRN & prns <= L5MOPS_MAX_GLOPRN);
svdata.mt31(1).ngal = sum(prns >= L5MOPS_MIN_GALPRN & prns <= L5MOPS_MAX_GALPRN);
svdata.mt31(1).ngeo = sum(prns >= L5MOPS_MIN_GEOPRN & prns <= L5MOPS_MAX_GEOPRN);
svdata.mt31(1).nbds = sum(prns >= L5MOPS_MIN_BDSPRN & prns <= L5MOPS_MAX_BDSPRN);

slot = 1;
svdata.mt31(1).prn2slot = NaN(size(svdata.mt31(1).prn2slot));
svdata.mt31(1).slot2prn = NaN(size(svdata.mt31(1).slot2prn));
for prn = 1:214
    if svdata.mt31(1).mask(prn)
        svdata.mt31(1).prn2slot(prn) = slot;
        svdata.mt31(1).slot2prn(slot) = prn;
        slot = slot + 1;
    end
end

svdata.mt31(1).msg_idx = mod(round(time), 700) + 1;