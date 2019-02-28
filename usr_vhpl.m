function vhpl=usr_vhpl(los_xyzb, usr_idx, sig2_i, prn, pa_mode)

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
%USR_VHPL calculates user vertical and horizontal protection levels (vpl & hpl)
%
%VHPL=USR_VHPL(LOS_XYZB, USR_IDX, SIG2_I, PRN, PA_MODE)
%   Given n_los of user lines of sight vectors in ECEF WGS-84 coordinates 
%   (X in first column, Y in second column ...) in LOS_XYZB(nlos,4), the
%   corresponding user identification numbers in USR_IDX (n_los,1), and the
%   variances for each los in SIG2_I (n_los,1), this function will determine
%   the vertical protection limit (VPL) and horizontal protection limit (HPL)
%   according to the WAAS MOPS.  The user should only include los vectors that
%   are above the mask angle and have valid UDREs and UIREs.  The user should
%   also  check for negative return values which are flags for position
%   solutions with 3 or fewer valid satellites in view.  VPLs and HPLs that
%   were successfully calculated will be positive non-zero values.
%
%   See also: UDRE2FLT GRID2UIVE

%2001Mar15 Created by Todd Walter

%Modified Todd Walter June 28, 2007 to include PA vs. NPA mode

global MOPS_NOT_MONITORED MOPS_KV_PA MOPS_KH_PA MOPS_KH_NPA MOPS_MIN_GEOPRN;
global TRUTH_FLAG;

%initialize return value
n_usr=max(usr_idx);
[n_los temp]=size(los_xyzb);
vhpl=repmat(MOPS_NOT_MONITORED,n_usr,2);
e=ones(50,1);

for usr=1:n_usr
  sv_idx=find(usr_idx==usr);
  n_view=length(sv_idx);
  %check for minimum in view and geo visibility
  if((n_view>3 & sum(floor(prn(sv_idx)/MOPS_MIN_GEOPRN))) | (TRUTH_FLAG == 1 & n_view > 3))
    G=los_xyzb(sv_idx,:);
    W=diag(e(1:n_view)./sig2_i(sv_idx));
    Cov=inv(G'*W*G);
    vhpl(usr,1)=MOPS_KV_PA*sqrt(Cov(3,3));
    if(pa_mode)
        vhpl(usr,2)=MOPS_KH_PA*sqrt(0.5*(Cov(1,1) + Cov(2,2)) +...
                               sqrt(0.25*(Cov(1,1) - Cov(2,2))^2 +...
                                    Cov(1,2)*Cov(2,1)));
    else
        vhpl(usr,2)=MOPS_KH_NPA*sqrt(0.5*(Cov(1,1) + Cov(2,2)) +...
                               sqrt(0.25*(Cov(1,1) - Cov(2,2))^2 +...
                                    Cov(1,2)*Cov(2,1)));                            
    end
  end
end






