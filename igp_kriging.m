function [sig2,vargive, r, rcm, idx, opt_var,delay,chi2] = igp_kriging(xyz_igp, igp_en_hat, xyz_ipp, sig2_ipp, dist_mat_ipp,lat_igp,lon_igp,Ivpp)
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
%IGP_KRIGING returns the pre-R_IRREG GIVE value given by an algorithm based on kriging
%  The method used here to generate the GIVE can be found in the paper "Adapting
%  Kriging to the WAAS MOPS Ionospheric Grid." ION NTM 2003 
%  [COV, R, RCM, IDX] = IGP_PLANE(XYZ_IGP, IGP_EN_HAT, XYZ_IPP, SIG2_IPP)
%  XYZ_IGP are the XYZ ECEF coordinates of the IGP
%  IGP_EN_HAT are the unit vectors in the east and north directions (the east
%             vector is in the first 3 columns and the north vector is in 
%             columns 4 through 6
%
%  XYZ_IPP are the XYZ ECEF coordinates of all the IPPs
%  SIG2_IPP are the variances of the the IPPs used to weight the fit
%  DIST_MAT_IPP is matrix of IPP distances in meters 
%  LAT_IGP is the latitude of the IGP
%  LON_IGP is the longitude of the IGP
%  The return values are:
%  R is the radius used for the fit
%  RCM is the relative centroid (weighted average of IPP positions / R)
%  IDX are the indices of the IPPs used in the fit
%  VARGIVE is the computed GIVE at the IGP location
%  OPT_VAR is the optimal estimation variance based on a noiseless
%  measurement. It is not used in the algorithm.
%   See also: GIVE_ADD INIT_KRIG_OSP

%   TWalter 21 Mar 00
%modified 05 Nov 2001 by Todd Walter
%modified 25 Feb 2003 by Juan Blanch
%modified 12 Aug 2003 by Juan Blanch

global MOPS_NOT_MONITORED;
global KRIG_N_MIN KRIG_N_PTS KRIG_RMAX KRIG_RMIN  KRIG_R2_IRREG RTR_MULT
global RTR_FLAG KRIG_ORDER TRUTH_FLAG


H_iono=350000;
KRIG_RMIN=KRIG_RMIN;

%initialize values
cov=MOPS_NOT_MONITORED*eye(3);
vargive=MOPS_NOT_MONITORED;
sig2=MOPS_NOT_MONITORED;
rcm=1;
opt_var=.7;
delay=NaN;
chi2=NaN;
[n_ipps temp]=size(xyz_ipp);

%calculate distance to each IPP
e=ones(n_ipps,1);
del_xyz=xyz_ipp-e*xyz_igp;
dist2=sum(del_xyz'.^2)';

% find at least 30 IPPs between max and min radii
%  try max radius first
r=KRIG_RMAX;
idx=find(dist2 <= KRIG_RMAX^2);
n_fit=length(idx);
%  do we meet the minimum requirement?
if (n_fit < KRIG_N_MIN)
%  warning(['Only ', num2str(n_fit), ' IPPs fell within radius ',...
%          num2str(KRIG_RMAX/1e3), ' km of IGP']);
  return
end
%  can we use a smaller radius?
if (n_fit > KRIG_N_PTS)
  min_idx=find(dist2(idx) <= KRIG_RMIN^2);
  n_fit=length(min_idx);
%    check minimum radius
  if(n_fit >= KRIG_N_PTS)
    r=KRIG_RMIN;
    idx=idx(min_idx);
  else
    [temp fit_idx]=sort(dist2(idx));
    r=sqrt(temp(KRIG_N_PTS));
    idx=idx(fit_idx(1:KRIG_N_PTS));
    n_fit=KRIG_N_PTS;
  end
end





%Compute 8 neighbouring IGPs
igp_width=5;
latminc=lat_igp-igp_width;
latmaxc=lat_igp+igp_width;
lonminc=lon_igp-igp_width;
lonmaxc=lon_igp+igp_width;

%IGP grid



lat_igps=latminc:igp_width:latmaxc;
lon_igps=lonminc:igp_width:lonmaxc;

n_lat_igp=length(lat_igps);
n_lon_igp=length(lon_igps);
n_igp=n_lat_igp*n_lon_igp;
ll_igp=reshape(lat_igps'*ones(size(lon_igps)),n_igp,1);
ll_igp(:,2)=reshape((lon_igps'*ones(size(lat_igps)))',n_igp,1);
xyz_igp=llh2xyz([ll_igp(:,1) ll_igp(:,2) H_iono*ones(n_igp,1)]);

%compute matrix of distances:
%between IGPs and IPPs

dist_mat_igp_ipp=zeros(n_fit,n_igp);         
for  igp0=1:n_igp
    
    del_xyz_igp=(xyz_ipp(idx,:)-ones(n_fit,1)*xyz_igp(igp0,:));
    
    dist_mat_igp_ipp(1:n_fit,igp0)=sqrt(sum(del_xyz_igp'.^2))';
end
D_igp_ipp=dist_mat_igp_ipp;
D_igp_ipp;

D_ipp=dist_mat_ipp(idx,idx);

%localize coordinate of center IGP

%p=find((ll_igp(:,1)==pi/180*lat_igp)&(ll_igp(:,2)==pi/180*lon_igp));
p=5;
xyz2enu=findxyz2enu(pi/180*ll_igp(p,1),pi/180*ll_igp(p,2));


%compute ENU coordinates of the IGPs
del_xyz_igp=(xyz_igp-ones(n_igp,1)*xyz_igp(p,:))';
del_enu_igp=xyz2enu*del_xyz_igp/1e6;

if KRIG_ORDER==1
     G_igp=[ones(n_igp,1) del_enu_igp(1:2,:)'];
 else
     if KRIG_ORDER==0
     G_igp=ones(n_igp,1);
 end
end
%compute ENU coordinates of IPPs
del_xyz_ipp=(xyz_ipp(idx,:)-ones(n_fit,1)*xyz_igp(p,:))';
del_enu_ipp=xyz2enu*del_xyz_ipp/1e6;


if KRIG_ORDER==1
    G_ipp=[ones(n_fit,1) del_enu_ipp(1:2,:)'];
else
    if KRIG_ORDER==0
    G_ipp=ones(n_fit,1);
end
end
%compute measurement noise matrix
%N=diag(sig2_ipp(idx));
N=sig2_ipp(idx,idx);
%compute covariance of IPP measurement due to ionospheric structure
%C=KRIG_R2_IRREG(n_fit-3)*nom_vario(D_ipp);
C=nom_vario(D_ipp);
%C_igp=nom_vario(D_igp_ipp,nug,d2dble,ov);
%C_igp=KRIG_R2_IRREG(n_fit-3)*nom_vario(D_igp_ipp);
C_igp=nom_vario(D_igp_ipp);
%C_igp

W=inv(C+N);
Ge=inv(G_ipp'*W*G_ipp);
%Co=KRIG_R2_IRREG(n_fit-3)*nom_vario(0);
Co=nom_vario(0);

Q=W*G_ipp*Ge;
R=Q*G_ipp'*W;


t1=Co;

t2=([1 0 0]'-G_ipp'*W*C_igp(:,5))'*Ge*([1 0 0]'-G_ipp'*W*C_igp(:,5));
A=C_igp'*W*C_igp;
Ae1=A([1 2 4 5],[1 2 4 5]);
Ae2=A([2 3 5 6],[2 3 5 6]);
Ae3=A([4 5 7 8],[4 5 7 8]);
Ae4=A([5 6 8 9],[5 6 8 9]);

%bound term depending on user-IPP covariance (unknown to master station)
mu=(W-R)*C_igp(:,5)+Q*G_igp(5,:)';
s1=sum(mu(find(mu>0)));
s2=sum(mu(find(mu<0)));
%b=-KRIG_R2_IRREG(n_fit-3)*nom_vario(700000)+KRIG_R2_IRREG(n_fit-3)*nom_vario(.1);
b=-nom_vario(350000)+nom_vario(.1);
additional=-b*s2+s1*distfconc(700000);
%additional=-b*s2+s1*KRIG_R2_IRREG(n_fit-3)*distfconc(700000);
n_ipp=length(mu);



a0=[1 1 1 1]'/4;
t3_1=-2*a0'*Ae1*[0 0 0 1]'+a0'*Ae1*a0;
t3_2=-2*a0'*Ae2*[0 0 1 0]'+a0'*Ae2*a0;
t3_3=-2*a0'*Ae3*[0 1 0 0]'+a0'*Ae3*a0;
t3_4=-2*a0'*Ae4*[1 0 0 0]'+a0'*Ae4*a0;
t3=max([t3_1 t3_2 t3_3 t3_4]);

vargive=t1+t2+t3+additional;
%vargive=t1+t2-A(5,5);

%build the G and W matrices
%G=[e(idx) sum((del_xyz(idx,:).*(e(idx)*igp_en_hat(:,1:3)))')'*1e-6...
 %                sum((del_xyz(idx,:).*(e(idx)*igp_en_hat(:,4:6)))')'*1e-6];
Wp=e(idx)./diag(sig2_ipp(idx,idx));

%cov=inv(G'*diag(W)*G);

rcv=sum((del_xyz(idx,:).*[Wp Wp Wp]))'/sum(Wp);
rcm=sqrt(sum(rcv.^2))/r;

Wo=inv(C);
Geo=inv(G_ipp'*Wo*G_ipp);
Qo=Wo*G_ipp*Geo;
Ro=Qo*G_ipp'*Wo;

%t1=Co;
%t2=Ge(1,1); 
%t3=-C_igp(:,5)'*(W-R)*C_igp(:,5);
%t4=-2*[1 0 0]*Q'*C_igp(:,5);
%opt_var=sqrt(t1+t2+t3+t4);

if TRUTH_FLAG
%Compute the delay
     delay=mu'*Ivpp(idx);

%Compute the chi-square statistic
     chi2=Ivpp(idx)'*(Wo-Ro)*Ivpp(idx);
end

%Compute Rirreg

if RTR_FLAG 
    Rirreg2=RTR_MULT(n_ipp-1-KRIG_ORDER*2)*chi2;
else
    Rirreg2=KRIG_R2_IRREG(n_ipp-1-KRIG_ORDER*2);
end

Rirreg2=max(1,Rirreg2);
sig2=Rirreg2*vargive;
       
        
%Estimation variance at the grid point

