function mt10 = init_mt10data()
%*************************************************************************
%*     Copyright c 2020 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************


%decoded MT10 data
msg.brrc = NaN;
msg.cltc_lsb = NaN;
msg.cltc_v1 = NaN;
msg.iltc_v1 = NaN;
msg.cltc_v0 = NaN;
msg.iltc_v0 = NaN;
msg.cgeo_lsb = NaN;
msg.cgeo_v = NaN;
msg.igeo = NaN;
msg.cer = NaN;
msg.ciono_step = NaN;
msg.iiono = NaN;
msg.ciono_ramp = NaN;
msg.rss_udre = NaN;
msg.rss_iono = NaN;
msg.ccovariance = NaN;
msg.time = NaN;
msg.msg_idx = 1;
mt10.msg(3) = msg;
mt10.msg(2) = msg;
mt10.msg(1) = msg;