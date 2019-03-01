function [prn,sv_xyz,sv_xyz_dot]=alm2satposvel(time, alm_param)
%*************************************************************************
%*     Copyright c 2001 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%FUNCTION SV_XYZ=ALM2XYZ(TIME, ALM_PARAM) given a time and alamanac data
%  alm2xyz generates the ECEF XYZ coordinates of the gps satellites
%   TIME time at which to calculate satellite position in absolute seconds
%      since 1980 (vector)
%   ALM_PARAM is a matrix whose rows correspond to satellites and with columns:
%    1    2    3    4     5    6       7       8          9     10  11  12
%   PRN ECCEN TOA INCLIN RORA SQRT_A R_ACEN ARG_PERIG MEAN_ANOM AF0 AF1 WEEK
%    -    -   sec  rad    r/s m^(1/2) rad     rad        rad     s  s/s  -
%
% see also READ_YUMA
% Modified by Juan Blanch 22 Aug 2006 to match ICD 200 (pp98-100) 

global CONST_MU_E CONST_OMEGA_E;

if nargin < 2
  error('you must specify a time and the almanac parameters')
end
if size(time,2)~=1,
    error('time must be specified as a column vector');
end
if size(time,1)>1,
    nsat=size(alm_param,1);
    alm_param = repmat(alm_param,size(time,1),1);
    time = repmat(time,1,nsat)';
    time = time(:);
end

axis=alm_param(:,6).^2;
n0=sqrt(CONST_MU_E./axis.^3);

%Modification
Tk=time-alm_param(:,3);
Tk = mod(Tk,604800);
if Tk>302400
    Tk = Tk - 604800;
end

eccen=alm_param(:,2);
Mk=alm_param(:,9)+n0.*Tk;
E0=Mk+100;
Ek=Mk;
i=1;
while(abs(Ek-E0)>1e-12 & i < 250)
  E0=Ek;
  Ek=Mk + eccen.*sin(E0);
  i=i+1;
end

cos_Ek = cos(Ek);
sin_Ek = sin(Ek);


c1 = 1 - eccen .* cos_Ek;
Ek_dot=n0./c1;

c2 = sqrt(1 - eccen.*eccen);
vk = atan2(c2.*sin_Ek, cos_Ek-eccen);   
vk_dot=Ek_dot.*c2./c1;

phik   = vk + alm_param(:,8);

uk=phik;
uk_dot=vk_dot;

rk = axis .* ( 1- eccen.*cos_Ek );
rk_dot=axis.*eccen.*Ek_dot.*sin_Ek;

ik=alm_param(:,4);

cos_uk = cos(uk);
sin_uk = sin(uk);

xxk = rk.*cos_uk;
xxk_dot=rk_dot.*cos_uk - uk_dot.*rk.*sin_uk;

yyk = rk.*sin_uk;
yyk_dot=rk_dot.*sin_uk + uk_dot.*rk.*cos_uk;

Omegak_dot= alm_param(:,5) - CONST_OMEGA_E;



Omega_k   = alm_param(:,7) + Omegak_dot.*Tk -...
            CONST_OMEGA_E* mod(alm_param(:,3),604800);


cosO = cos(Omega_k);
sinO = sin(Omega_k);
cosi = cos(ik);
sini = sin(ik);

sv_xyz=[xxk.*cosO - yyk.*cosi.*sinO xxk.*sinO + yyk.*cosi.*cosO yyk.*sini];
sv_xyz_dot=[xxk_dot.*cosO - Omegak_dot.*xxk.*sinO-...
            yyk_dot.*cosi.*sinO - Omegak_dot.*yyk.*cosi.*cosO ...
            xxk_dot.*sinO + Omegak_dot.*xxk.*cosO+...
            yyk_dot.*cosi.*cosO - Omegak_dot.*yyk.*cosi.*sinO ...
            yyk_dot.*sini];

prn = alm_param(:,1);

