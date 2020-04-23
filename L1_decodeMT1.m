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

svdata.mt1_mask = cast(bin2dec(msg(15:224)'), 'uint8');

svdata.mt1_iodp = bin2dec(msg(225:226));

svdata.mt1_time = time;

kdx = 1:212;
prns = kdx(svdata.mt1_mask>0)';
svdata.prns(1:length(prns)) = prns;
svdata.mt1_ngps = sum(prns >= MOPS_MIN_GPSPRN & prns <= MOPS_MAX_GPSPRN);
svdata.mt1_nglo = sum(prns >= MOPS_MIN_GLOPRN & prns <= MOPS_MAX_GLOPRN);
svdata.mt1_ngeo = sum(prns >= MOPS_MIN_GEOPRN & prns <= MOPS_MAX_GEOPRN);