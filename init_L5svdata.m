function svdata = init_L5svdata()
%*************************************************************************
%*     Copyright c 2020 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
global L5MOPS_DFREI_DNUSBAS L5MOPS_MIN_GEOPRN L5MOPS_MAX_GEOPRN L5MOPS_MAX_BDSPRN

%decoded SV data
max_sats = 53;
max_geos = L5MOPS_MAX_GEOPRN - L5MOPS_MIN_GEOPRN + 1;
max_prn  = L5MOPS_MAX_BDSPRN;

svdata.prns = NaN(max_sats,1);

%MT31
mt31.mask = cast(zeros(214,1), 'uint8');
mt31.iodm = NaN;
mt31.time = NaN;
mt31.ngps = NaN;
mt31.nglo = NaN;
mt31.ngal = NaN;
mt31.ngeo = NaN;
mt31.nbds = NaN;
mt31.prn2slot = NaN(max_prn,1);
mt31.slot2prn = NaN(max_sats,1);
mt31.msg_idx = 1;
svdata.mt31(3) = mt31;
svdata.mt31(2) = mt31;
svdata.mt31(1) = mt31;
%MT32
mt32.iodn   = NaN;
mt32.dxyzb  = NaN(1,4);
mt32.dxyzb_dot = zeros(1,4);
mt32.t0     = NaN;
mt32.sc_exp = NaN; %scale exponent
mt32.E      = NaN(1,10); %[E11 E12 E13 E14  E22 E23 E24 E33 E34 E44
mt32.dCov   = [1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0]; %covariance matrix
mt32.dfrei  = NaN;
mt32.dRcorr = NaN;
mt32.time   = NaN;
mt32.msg_idx = 1;
for pdx = max_prn:-1:1
    svdata.mt32(pdx,3) = mt32;
    svdata.mt32(pdx,2) = mt32;
    svdata.mt32(pdx,1) = mt32;
end
%MT35
mt35.iodm = NaN;
mt35.dfrei = repmat(L5MOPS_DFREI_DNUSBAS,max_sats,1);
mt35.time = NaN;
mt35.msg_idx = 1;
svdata.mt35(6) = mt35;
svdata.mt35(5) = mt35;
svdata.mt35(4) = mt35;
svdata.mt35(3) = mt35;
svdata.mt35(2) = mt35;
svdata.mt35(1) = mt35;
%MT37
mt37.Ivalid32 = NaN;
mt37.Ivalid3940 = NaN;
mt37.Cer = NaN;
mt37.Ccovariance = NaN;
mt37.Icorr = NaN(6,1);
mt37.Ccorr = NaN(6,1);
mt37.Rcorr = NaN(6,1);
mt37.sig_dfre = [1.0625 2.125 2.25 2.375 2.5 4.5 4.75 5 5.25 5.5 9.5 10 18 49 100 NaN]';
mt37.trefid = NaN;
mt37.obadidx = NaN;
mt37.time = NaN;
mt37.msg_idx = 1;
svdata.mt37(3) = mt37;
svdata.mt37(2) = mt37;
svdata.mt37(1) = mt37;
%MT39/40
mt39.prn = NaN;
mt39.iodg = NaN;
mt39.spid = NaN;
mt39.cuc = NaN;
mt39.cus = NaN;
mt39.idot = NaN;
mt39.omega = NaN;
mt39.lan = NaN;
mt39.M0 = NaN;
mt39.agf0 = NaN;
mt39.agf1 = NaN;
mt39.time   = NaN;
mt39.msg_idx = 1;
mt40.iodg = NaN;
mt40.i = NaN;
mt40.e = NaN;
mt40.a = NaN;
mt40.te = NaN;
mt40.sc_exp = NaN; %scale exponent
mt40.E      = NaN(1,10); %[E11 E12 E13 E14  E22 E23 E24 E33 E34 E44
mt40.dCov = [1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0];
mt40.dfrei  = NaN;
mt40.dRcorr = NaN;
mt40.time   = NaN;
mt40.msg_idx = 1;
for iodg = 4:-1:1
    svdata.mt39(iodg,3) = mt39;
    svdata.mt39(iodg,2) = mt39;
    svdata.mt39(iodg,1) = mt39;
    svdata.mt40(iodg,3) = mt40;
    svdata.mt40(iodg,2) = mt40;
    svdata.mt40(iodg,1) = mt40;
    for j = 5:-1:1 %Geo data (max 5 channels)
        svdata.mt3940(iodg,j).prn = NaN;
        svdata.mt3940(iodg,j).xyzb = NaN(1,4);
        svdata.mt3940(iodg,j).time = NaN;
        svdata.mt3940(iodg,j).kdx40 = NaN;
    end
end
%MT47
mt47alm.prn = NaN;
mt47alm.spid = NaN;
mt47alm.brid = NaN;
mt47alm.a = NaN;
mt47alm.e = NaN;
mt47alm.omega = NaN;
mt47alm.lan = NaN;
mt47alm.lan_dot = NaN;
mt47alm.M0 = NaN;
mt47alm.ta = NaN;
mt47alm.time = NaN;
mt47alm.msg_idx = 1;
for i = max_geos:-1:1
    svdata.mt47alm(i) = mt47alm;
end
svdata.mt47_wnrocount = NaN;
%MT50
mt50.key_num = NaN;
mt50.mac_msg_ids = NaN(5,1);
mt50.time = NaN;
mt50.msg_idx = 1;
svdata.mt50(4) = mt50;
svdata.mt50(3) = mt50;
svdata.mt50(2) = mt50;
svdata.mt50(1) = mt50;

%Satellite correction data
svdata.dxyzb   = NaN(max_prn,4); 
svdata.dCov    = NaN(max_prn,16); 
svdata.dCov_sf = NaN(max_prn,1); 
svdata.dfrei   = NaN(max_prn,1);
svdata.degradation  = NaN(max_prn,1);

%Geo data (max 5 channels)
svdata.geo_prn      = NaN;
svdata.geo_channel  = NaN;
svdata.geo_spid     = NaN;      % Service provider ID
svdata.geo_prn_time = NaN;
svdata.geo_xyzb     = NaN(5,4);

%Satellite authentication data
svdata.received  = false(700, 1);
svdata.auth_pass = false(700, 1);
