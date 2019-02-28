function [sig2_igp, mu_igp, sig2_upm, r, rcm, idx, delay, chi2] ...
                            = igp_plane1(xyz_igp, igp_en_hat, igp_cornerden, ...
                                         xyz_ipp, mu_me, M, Ivpp)
%*************************************************************************
%*     Copyright c 2007 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%IGP_PLANE1 returns the covariance matrix for a planar fit centered on the IGPs
%
%  [SIG2_IGP, MU_IGP, SIG2_UPM, R, RCM, IDX, DELAY, CHI2] = 
%                              IGP_PLANE(XYZ_IGP, IGP_EN_HAT, XYZ_IPP, M, IVPP)
%  XYZ_IGP are the XYZ ECEF coordinates of the IGP
%  IGP_EN_HAT are the unit vectors in the east and north directions (the east
%             vector is in the first 3 columns and the north vector is in 
%             columns 4 through 6
%  IGP_CORNERDEN are the corners for evaluating the projected antenna bias
%  XYZ_IPP are the XYZ ECEF coordinates of all the IPPs
%  MU_ME is maximum antenna bias on each line of sight in meters
%  M is the covariance matrix of the the IPPs used to form the fit
%  IVPP are the vertical delay for the IPPs (used for truth processing)
%  The return values are:
%  SIG2_IGP is the variance for the IGP delay fit
%  MU_IGP is the maximum antenna bias effect on the fit
%  SIG2_UPM is teh UPM variance from the fit, used for GEO UDRE
%  R is the radius used for the fit
%  RCM is the relative centroid (weighted average of IPP positions / R)
%  IDX are the indices of the IPPs used in the fit
%  DELAY is the vertical delay estimate for the IGP (truth only)
%  CHI2 is the chi-squared value for the fit (truth only)
%
%   See also: GIVE_ADD1 INIT_GIVEADD1_OSP

%   created 18 May 2004 by Todd Walter
%   updated 29 June 2006 by Todd Walter: added antenna bias term

global MOPS_NOT_MONITORED
global GIVE1_N_MIN GIVE1_N_PTS GIVE1_RMAX GIVE1_RMIN GIVE1_SIG2_DECORR ...
       GIVE1_CHI2_LOWER GIVE1_CHI2_LWR_UPM GIVE1_CHI2_NOM GIVE1_RIRREG2_FLOOR
global TRUTH_FLAG

%initialize values
sig2_igp = MOPS_NOT_MONITORED;
mu_igp = 0;
sig2_upm = MOPS_NOT_MONITORED;
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
r=GIVE1_RMAX;
idx=find(dist2 <= GIVE1_RMAX^2);
n_fit=length(idx);
%  do we meet the minimum requirement?
if (n_fit < GIVE1_N_MIN)
%  warning(['Only ', num2str(n_fit), ' IPPs fell within radius ',...
%          num2str(GIVE_RMAX/1e3), ' km of IGP']);
  return
end
%  can we use a smaller radius?
if (n_fit > GIVE1_N_PTS)
  min_idx=find(dist2(idx) <= GIVE1_RMIN^2);
  n_fit=length(min_idx);
%    check minimum radius
  if(n_fit >= GIVE1_N_PTS)
    r=GIVE1_RMIN;
    idx=idx(min_idx);
  else
    [temp fit_idx]=sort(dist2(idx));
    r=sqrt(temp(GIVE1_N_PTS));
    idx=idx(fit_idx(1:GIVE1_N_PTS));
    n_fit=GIVE1_N_PTS;
  end
end

%build the G and W matrices
G=[e(idx) sum((del_xyz(idx,:).*(e(idx)*igp_en_hat(:,1:3)))')'*1e-6...
                 sum((del_xyz(idx,:).*(e(idx)*igp_en_hat(:,4:6)))')'*1e-6];

W=inv(M(idx,idx)+GIVE1_SIG2_DECORR*eye(length(idx)));
  
%calculate nominal covariance
cov0=inv(G'*W*G);


if TRUTH_FLAG
    %calculate vertical delay value
    a = cov0*G'*W*Ivpp(idx); 
    delay = a(1);

    %calculate chi-square value of noiseless supertruth
    Wo=inv(GIVE1_SIG2_DECORR*eye(length(idx)));
    covo=inv(G'*Wo*G);
    ao=covo*G'*Wo*Ivpp(idx);
    chi2_raw=Ivpp(idx)'*Wo*(Ivpp(idx)-G*ao);
    Rnoise = 1;
else
    Rnoise = prod(1+diag(M(idx,idx))/GIVE1_SIG2_DECORR)^(1/n_fit);
    chi2_raw = GIVE1_CHI2_NOM(n_fit-3)/Rnoise;
end

chi2 = chi2_raw*Rnoise;

Rirreg2=chi2/GIVE1_CHI2_LOWER(n_fit-3);
Rirreg2=max(GIVE1_RIRREG2_FLOOR,Rirreg2);
cov = cov0*G'*W*(Rirreg2*GIVE1_SIG2_DECORR*eye(length(idx)) + ...
                  M(idx,idx))*W*G*cov0;

sig2_igp = cov(1,1) + Rirreg2*GIVE1_SIG2_DECORR;

%calculate antenna bias term
mu_igp = max(abs(igp_cornerden*cov0*G'*W)*mu_me(idx));

%calculate UPM GIVE value for GEO UDRE
Rirreg_realistic2 = chi2/GIVE1_CHI2_LWR_UPM(n_fit-3);
Rirreg_realistic2 = max(GIVE1_RIRREG2_FLOOR,Rirreg_realistic2);
cov_realistic = cov0*G'*W*(Rirreg_realistic2*GIVE1_SIG2_DECORR*eye(length(idx)) ...
                   + M(idx,idx))*W*G*cov0;
sig2_upm = cov_realistic(1,1) + Rirreg_realistic2*GIVE1_SIG2_DECORR;

%calculate Relative Centroid Metric
We=e(idx)./(diag(M(idx,idx)) + GIVE1_SIG2_DECORR);

rcv=sum((del_xyz(idx,:).*[We We We]))'/sum(We);
rcm=sqrt(sum(rcv.^2))/r;


       
       
