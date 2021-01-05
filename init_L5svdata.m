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
global L5MOPS_DFREI_DNUSBAS L5MOPS_MAX_GEOPRN

%decoded SV data
max_sats = 53;
max_geos = 39;
max_prn  = L5MOPS_MAX_GEOPRN;

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
svdata.mt31(2) = mt31;
svdata.mt31(1) = mt31;
%MT32
mt32.iodn   = NaN(max_prn,1);
mt32.dxyzb  = NaN(max_prn,4);
mt32.dxyzb_dot = zeros(max_prn,4);
mt32.t0     = NaN(max_prn,1);
mt32.sc_exp = NaN(max_prn,1); %scale exponent
mt32.E      = NaN(max_prn,10); %[E11 E12 E13 E14  E22 E23 E24 E33 E34 E44
mt32.dCov   = repmat([1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0], max_prn,1); %covariance matrix
mt32.dfrei  = NaN(max_prn,1);
mt32.dRcorr = NaN(max_prn,1);
mt32.time   = NaN(max_prn,1);
svdata.mt32(2) = mt32;
svdata.mt32(1) = mt32;
%MT35
mt35.iodm = NaN;
mt35.dfrei = repmat(L5MOPS_DFREI_DNUSBAS,max_sats,1);
mt35.time = NaN;
svdata.mt35(2) = mt35;
svdata.mt35(1) = mt35;
%MT37
mt37.Ivalid32 = NaN;
mt37.Ivalid3940 = NaN;
mt37.Cer = NaN(max_sats,1);
mt37.Ccovariance = NaN(max_sats,1);
mt37.Icorr = NaN(6,1);
mt37.Ccorr = NaN(6,1);
mt37.Rcorr = NaN(6,1);
mt37.sig_dfre = [1.0625 2.125 2.25 2.375 2.5 4.5 4.75 5 5.25 5.5 9.5 10 18 49 100 NaN]';
mt37.trefid = NaN;
mt37.obadidx = NaN;
mt37.time = NaN;
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
for iodg = 4:-1:1
    svdata.mt39(iodg) = mt39;
    svdata.mt40(iodg) = mt40;
    svdata.mt3940(iodg).xyzb = NaN(1,4);
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
for i = max_geos:-1:1
    svdata.mt47alm(i) = mt47alm;
end
svdata.mt47_wnrocount = NaN;

%Satellite correction data
svdata.dxyzb   = NaN(max_sats,4); 
svdata.dCov    = NaN(max_sats,16); 
svdata.dCov_sf = NaN(max_sats,1); 
svdata.dfrei   = NaN(max_sats,1);
svdata.degradation  = NaN(max_sats,1);

%Geo data (max 5 channels)
svdata.geo_prn      = NaN;
svdata.geo_spid     = NaN;      % Service provider ID
svdata.geo_prn_time = NaN;
svdata.geo_xyzb     = NaN(5,4);
