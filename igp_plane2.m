function [cov, r, rcm, idx, delay, chi2] = igp_plane2(xyz_igp, igp_en_hat, ...
                                                      xyz_ipp, sig2_ipp, Ivpp)
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
%IGP_PLANE returns the covariance matrix for a planar fit centered on the IGPs
%
%  [COV, R, RCM, IDX] = IGP_PLANE(XYZ_IGP, IGP_EN_HAT, XYZ_IPP, SIG2_IPP)
%  XYZ_IGP are the XYZ ECEF coordinates of the IGP
%  IGP_EN_HAT are the unit vectors in the east and north directions (the east
%             vector is in the first 3 columns and the north vector is in 
%             columns 4 through 6
%
%  XYZ_IPP are the XYZ ECEF coordinates of all the IPPs
%  SIG2_IPP are the variances of the the IPPs used to weight the fit
%  The return values are:
%  COV is the covariance matrix for the IGP delay and slopes in east and north
%  R is the radius used for the fit
%  RCM is the relative centroid (weighted average of IPP positions / R)
%  IDX are the indices of the IPPs used in the fit
%
%   See also: GIVE_ADD INIT_GIVE_OSP

%   TWalter 21 Mar 00
%modified 05 Nov 2001 by Todd Walter

global MOPS_NOT_MONITORED;
global GIVE_N_MIN GIVE_N_PTS GIVE_RMAX GIVE_RMIN GIVE_SIG2_DECORR


%initialize values
cov=MOPS_NOT_MONITORED*eye(3);
rcm=1;
delay=NaN;
chi2=NaN;

[n_ipps temp]=size(xyz_ipp);

%calculate distance to each IPP
e=ones(n_ipps,1);
del_xyz=xyz_ipp-e*xyz_igp;
dist2=sum(del_xyz'.^2)';

% find at least 30 IPPs between max and min radii
%  try max radius first
r=GIVE_RMAX;
idx=find(dist2 <= GIVE_RMAX^2);
n_fit=length(idx);
%  do we meet the minimum requirement?
if (n_fit < GIVE_N_MIN)
%  warning(['Only ', num2str(n_fit), ' IPPs fell within radius ',...
%          num2str(GIVE_RMAX/1e3), ' km of IGP']);
  return
end
%  can we use a smaller radius?
if (n_fit > GIVE_N_PTS)
  min_idx=find(dist2(idx) <= GIVE_RMIN^2);
  n_fit=length(min_idx);
%    check minimum radius
  if(n_fit >= GIVE_N_PTS)
    r=GIVE_RMIN;
    idx=idx(min_idx);
  else
    [temp fit_idx]=sort(dist2(idx));
    r=sqrt(temp(GIVE_N_PTS));
    idx=idx(fit_idx(1:GIVE_N_PTS));
    n_fit=GIVE_N_PTS;
  end
end

%build the G and W matrices
G=[e(idx) sum((del_xyz(idx,:).*(e(idx)*igp_en_hat(:,1:3)))')'*1e-6...
                 sum((del_xyz(idx,:).*(e(idx)*igp_en_hat(:,4:6)))')'*1e-6];
We=e(idx)./diag(sig2_ipp(idx,idx));
%W=inv(sig2_ipp(idx,idx));

%cov=inv(G'*diag(W)*G);
%cov=inv(G'*W*G);

rcv=sum((del_xyz(idx,:).*[We We We]))'/sum(We);
rcm=sqrt(sum(rcv.^2))/r;

%supertruth data is essentially noiseless
%W=diag(e(idx)./((sig2_ipp(idx) + GIVE_SIG2_DECORR)/2));
%W = diag(e(idx)./(sig2_ipp(idx) + GIVE_SIG2_DECORR));

%Modification meant to test dependency of GIVE on CNMP
Knoise=1;%how much we overestimate the measurement noise

C=(Knoise^2)*sig2_ipp(idx,idx)+GIVE_SIG2_DECORR*eye(length(idx));
W=inv(C);
%W=diag(e(idx)/GIVE_SIG2_DECORR);


%Measurement noise simulation:
%ratio
% alpha=.5;
% Ciono=sig2_ipp(idx,idx);
% noise=alpha*sqrtm(Ciono)*randn(n_fit,1);


%calculate vertical delay
cov=inv(G'*W*G);
a=cov*G'*W*(Ivpp(idx)+noise);
  
delay=a(1);
  
%calculate chi-square value
Wo=inv(GIVE_SIG2_DECORR*eye(length(idx)));
covo=inv(G'*Wo*G);
ao=covo*G'*Wo*Ivpp(idx);
chi2=Ivpp(idx)'*Wo*(Ivpp(idx)-G*ao);

%


%chi2=(Ivpp(idx)+noise)'*W*(Ivpp(idx)+noise-G*a);






