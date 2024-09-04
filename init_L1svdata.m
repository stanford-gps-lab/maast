function svdata = init_L1svdata()
%*************************************************************************
%*     Copyright c 2020 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
global MOPS_UDREI_NM

%decoded SV data
max_sats = 51;
max_geos = 39;
max_prn = 210;
svdata.prns = NaN(max_sats,1);

%MT1
mt1.mask = cast(zeros(max_prn,1), 'uint8');
mt1.iodp = NaN;
mt1.time = NaN;
mt1.ngps = NaN;
mt1.nglo = NaN;
mt1.ngeo = NaN;
mt1.prn2slot = NaN(max_prn,1);
mt1.slot2prn = NaN(max_sats,1);
mt1.msg_idx = 1;
svdata.mt1(3) = mt1;
svdata.mt1(2) = mt1;
svdata.mt1(1) = mt1;
%MT2 - 5
mt2345.fc = NaN;
mt2345.time = NaN;
mt2345.iodf = NaN;
mt2345.udrei = MOPS_UDREI_NM;
mt2345.iodp = NaN;
mt2345.msg_idx = 1;
for pdx = max_sats:-1:1
    svdata.mt2345(pdx,6) = mt2345;
    svdata.mt2345(pdx,5) = mt2345;
    svdata.mt2345(pdx,4) = mt2345;
    svdata.mt2345(pdx,3) = mt2345;
    svdata.mt2345(pdx,2) = mt2345;
    svdata.mt2345(pdx,1) = mt2345;
end
%MT6
mt6.iodf = NaN(max_sats,1);
mt6.udrei = repmat(MOPS_UDREI_NM,max_sats,1);
mt6.time = NaN;
mt6.msg_idx = 1;
svdata.mt6(3) = mt6;
svdata.mt6(2) = mt6;
svdata.mt6(1) = mt6;
%MT7
mt7.iodp = NaN;
mt7.t_lat = NaN;
mt7.ai = NaN(max_sats,1);
mt7.time = NaN;
mt7.msg_idx = 1;
svdata.mt7(3) = mt7;
svdata.mt7(2) = mt7;
svdata.mt7(1) = mt7;
%MT9
mt9.t0 = NaN;
mt9.ura = NaN;
mt9.xyz = NaN(1,3);
mt9.xyz_dot = NaN(1,3);
mt9.xyz_dot_dot = NaN(1,3);
mt9.af0 = NaN;
mt9.af1 = NaN;
mt9.time = NaN;
mt9.msg_idx = 1;
svdata.mt9(3) = mt9;
svdata.mt9(2) = mt9;
svdata.mt9(1) = mt9;
%MT17
mt17.t0 = NaN;
mt17.prn = NaN;
mt17.health = NaN;
mt17.xyz = NaN(1,3);
mt17.xyz_dot = NaN(1,3);
mt17.time = NaN;
mt17.msg_idx = 1;
for gdx = max_geos:-1:1
    svdata.mt17(gdx,3) = mt17;
    svdata.mt17(gdx,2) = mt17;
    svdata.mt17(gdx,1) = mt17;
end
%MT20
mt50.key_num = NaN;
mt50.mac_msg_ids = NaN(5,1);
mt50.time = NaN;
mt50.msg_idx = 1;
svdata.mt50(4) = mt50;
svdata.mt50(3) = mt50;
svdata.mt50(2) = mt50;
svdata.mt50(1) = mt50;
%MT25
mt25.dxyzb = NaN(1,4);
mt25.dxyzb_dot = zeros(1,4);
mt25.t0 = NaN;
mt25.iode = NaN;
mt25.iodp = NaN;
mt25.time = NaN;
mt25.msg_idx = 1;
svdata.mt25(3) = mt25;
svdata.mt25(2) = mt25;
svdata.mt25(1) = mt25;
for pdx = max_sats:-1:1
    svdata.mt25(pdx,3) = mt25;
    svdata.mt25(pdx,2) = mt25;
    svdata.mt25(pdx,1) = mt25;
end
%MT27
mt27.msg_poly = [];
mt27.time = NaN;
mt27.polygon = [];
mt27.polytime = NaN;
mt27.msg_idx = 1;
svdata.mt27(5) = mt27;
svdata.mt27(4) = mt27;
svdata.mt27(3) = mt27;
svdata.mt27(2) = mt27;
svdata.mt27(1) = mt27;
%MT28
mt28.iodp = NaN;
mt28.sc_exp = NaN; %scale exponent
mt28.E    = NaN(1,10); %[E11 E12 E13 E14  E22 E23 E24 E33 E34 E44
mt28.dCov = [1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0]; %covariance matrix
mt28.time = NaN;
mt28.msg_idx = 1;
for pdx = max_sats:-1:1
    svdata.mt28(pdx,3) = mt28;
    svdata.mt28(pdx,2) = mt28;
    svdata.mt28(pdx,1) = mt28;
end

%Satellite correction data
svdata.dxyzb  = NaN(max_sats,4); 
svdata.udrei  = NaN(max_sats,1);
svdata.degradation  = NaN(max_sats,1);
svdata.mt27_polygon = [];
svdata.mt28_dCov = NaN(max_sats,16);
svdata.mt28_sc_exp = NaN(max_sats,1);
svdata.mt28_time = -inf;

%Geo data (max 5 channels)
svdata.geo_prn      = NaN;
svdata.geo_spid     = NaN;      % Service provider ID
svdata.geo_flags    = NaN(4,1); % [ranging, precise corr, basic corr, reserved] [0: on / 1: off]
svdata.geo_prn_time = NaN;
svdata.geo_xyzb     = NaN(5,4);
svdata.geo_deg      = NaN(5,1);

%Satellite authentication data
svdata.received  = false(700, 1);
svdata.auth_pass = false(700, 1);