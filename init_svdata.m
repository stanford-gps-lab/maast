function svdata = init_svdata()
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
svdata.prns = NaN(max_sats,1);
%MT1
svdata.mt1_mask = cast(zeros(210,1), 'uint8');
svdata.mt1_iodp = NaN;
svdata.mt1_time = NaN;
svdata.mt1_ngps = NaN;
svdata.mt1_nglo = NaN;
svdata.mt1_ngeo = NaN;
%MT2 - 5
svdata.mt2_fc = NaN(max_sats,6);
svdata.mt2_fc_time = NaN(max_sats,6);
svdata.mt2_fc_iodf = NaN(max_sats,6);
svdata.mt2_udrei = repmat(MOPS_UDREI_NM,max_sats,1);
svdata.mt2_fc_iodp = NaN(max_sats,1);
%MT6
svdata.mt6_iodf = NaN;
svdata.mt6_udrei = repmat(MOPS_UDREI_NM,max_sats,1);
svdata.mt6_time = NaN;
%MT7
svdata.mt7_iodp = NaN;
svdata.mt7_t_lat = NaN;
svdata.mt7_ai = NaN(max_sats,1);
svdata.mt7_time = NaN;
%MT9
svdata.mt9_t0 = NaN;
svdata.mt9_ura = NaN;
svdata.mt9_xyz = NaN(1,3);
svdata.mt9_xyz_dot = NaN(1,3);
svdata.mt9_xyz_dot_dot = NaN(1,3);
svdata.mt9_af0 = NaN;
svdata.mt9_af1 = NaN;
svdata.mt9_time = NaN;
%MT17
svdata.mt17_t0 = NaN(max_geos,1);
svdata.mt17_prn = NaN(max_geos,1);
svdata.mt17_health = NaN(max_geos,1);
svdata.mt17_xyz = NaN(max_geos,3);
svdata.mt17_xyz_dot = NaN(max_geos,3);
svdata.mt17_time = NaN(max_geos,1);
%MT25
svdata.mt25_dxyzb = NaN(max_sats,4);
svdata.mt25_dxyzb_dot = zeros(max_sats,4);
svdata.mt25_t0 = NaN(max_sats,1);
svdata.mt25_iode = NaN(max_sats,1);
svdata.mt25_iodp = NaN(max_sats,1);
svdata.mt25_time = NaN(max_sats,1);
%MT27
svdata.mt27_msg_poly = [];
svdata.mt27_time = NaN;
svdata.mt27_polygon = [];
svdata.mt27_polytime = NaN;
%MT28
svdata.mt28_iodp = NaN(max_sats,1);
svdata.mt28_sc_exp = NaN(max_sats,1); %scale exponent
svdata.mt28_E    = NaN(max_sats,10); %[E11 E12 E13 E14  E22 E23 E24 E33 E34 E44
svdata.mt28_dCov = repmat([1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0], max_sats,1); %covariance matrix
svdata.mt28_time = NaN(max_sats,1);

%Satellite correction data
svdata.dxyzb  = NaN(max_sats,4); 
svdata.udrei  = NaN(max_sats,1);
svdata.degradation  = NaN(max_sats,1);

%Geo data (max 5 channels)
svdata.geo_prn      = NaN;
svdata.geo_spid     = NaN;      % Service provider ID
svdata.geo_flags    = NaN(4,1); % [ranging, precise corr, basic corr, reserved] [0: on / 1: off]
svdata.geo_prn_time = NaN;
svdata.geo_xyzb     = NaN(5,4);
svdata.geo_deg      = NaN(5,1);
