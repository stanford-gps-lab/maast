function sv_xyz = sbas_geoeph2satpos(time, mt39, mt40)
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
%FUNCTION SV_XYZ=GEOEPH2SATPOS(TIME, MT39, MT40) given a time and ephemeris 
%  message data geoeph2satpos generates the ECEF XYZ coordinates of the geo 
%   TIME time at which to calculate satellite position in absolute seconds
%      since 1980 (vector)
%   MT39 & MT40 are structures whose elements correspond to L5 SBAS messages
%   mt39.cuc, mt39.cus, mt39.idot, mt39.omega, mt39.lan, mt39.M0, 
%   mt39.time, mt40.i, mt40.e, mt40.a, and mt40.te

% created December 29, 2020 by Todd Walter

global CONST_MU_E CONST_OMEGA_E;

if nargin < 3
  error('you must specify a time and the MT 39/40 parameters')
end

n0=sqrt(CONST_MU_E/mt40.a^3);

tk = time - mt40.te;

Mk = mt39.M0 + n0*tk;

E0=Mk+100;
Ek=Mk;
i=1;
while(any(abs(Ek-E0)>1e-12) && i < 250)
  E0=Ek;
  Ek=Mk + mt40.e*sin(E0);
  i=i+1;
end

cos_Ek = cos(Ek);
sin_Ek = sin(Ek);

c2 = sqrt(1 - mt40.e*mt40.e);
vk = atan2(c2*sin_Ek, cos_Ek - mt40.e);   

phik = vk + mt39.omega;

uk = phik + mt39.cus*sin(2*phik) + mt39.cuc*cos(2*phik);

rk = mt40.a*(1 - mt40.e*cos_Ek);

cos_uk = cos(uk);
sin_uk = sin(uk);

xxk = rk*cos_uk;
yyk = rk*sin_uk;

Omega_k = mt39.lan - CONST_OMEGA_E*tk;

ik = mt40.i + mt39.idot*tk;

cosO = cos(Omega_k);
sinO = sin(Omega_k);

cosi = cos(ik);
sini = sin(ik);

sv_xyz=[xxk*cosO - yyk*cosi*sinO xxk*sinO + yyk*cosi*cosO yyk*sini];