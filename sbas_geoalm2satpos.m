function sv_xyz = sbas_geoalm2satpos(time, mt47alm)
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
%FUNCTION SV_XYZ=GEOALM2SATPOS(TIME, MT47) given a time and almanac 
%  message data geoalm2satpos generates the ECEF XYZ coordinates of the geo 
%   TIME time at which to calculate satellite position in absolute seconds
%      since 1980 (vector)
%   MT47 is a structure whose elements correspond to L5 SBAS messages
%   mt47alm.a, mt47alm.e, mt47alm.omega, mt47alm.lan, mt47alm.lan_dot, 
%   mt47alm.M0, mt47alm.ta

% created January 1, 2021 by Todd Walter

global CONST_MU_E CONST_OMEGA_E;

if nargin < 2
  error('you must specify a time and the MT 47 parameters')
end

n0=sqrt(CONST_MU_E/mt47alm.a^3);

tk = time - mt47alm.ta;

Mk = mt47alm.M0 + n0*tk;

E0=Mk+100;
Ek=Mk;
i=1;
while(any(abs(Ek-E0)>1e-12) && i < 250)
  E0=Ek;
  Ek=Mk + mt47alm.e*sin(E0);
  i=i+1;
end

cos_Ek = cos(Ek);
sin_Ek = sin(Ek);

c2 = sqrt(1 - mt47alm.e*mt47alm.e);
vk = atan2(c2*sin_Ek, cos_Ek - mt47alm.e);   

phik = vk + mt47alm.omega;

uk = phik;

rk = mt47alm.a*(1 - mt47alm.e*cos_Ek);

cos_uk = cos(uk);
sin_uk = sin(uk);

xxk = rk*cos_uk;
yyk = rk*sin_uk;

Omega_k = mt47alm.lan + mt47alm.lan_dot*tk - CONST_OMEGA_E*tk;

ik = mt47alm.i;

cosO = cos(Omega_k);
sinO = sin(Omega_k);

cosi = cos(ik);
sini = sin(ik);

sv_xyz=[xxk*cosO - yyk*cosi*sinO xxk*sinO + yyk*cosi*cosO yyk*sini];