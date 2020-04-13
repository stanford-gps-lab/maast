function sig_flt = udre2flt(los_xyzb, prn, sig_udre, mt28_cov, mt28_sf)

%*************************************************************************
%*     Copyright c 2020 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%UDRE2FLT      calculates fast/long-term variance given UDREs and MT28 info
%
%SIG_FLT=UDRE2FLT(LOS_XYZB, PRN, SIG2UDRE, MT28_COV, MT28_SF)
%   Given n_los of user lines of sight vectors in ECEF WGS-84 coordinates 
%   (X in first column, Y in second column ...) in LOS_XYZ(nlos,4), the
%   corresponding satellite PRN numbers in PRN (n_los,1), the UDREs as
%   variances in SIG2_UDRE (n_prn,1), the Message Type 28 discretized,
%   normalized covariance matrices in MT28_COV (4,4,n_prn) and the
%   corresponding scale factors in MT28_SF (n_prn,1)), this function will
%   determine the variance for each line of sight (SIG2_FLT) according to the
%   WAAS MOPS.  The user should only include los vectors that are above the
%   mask angle and have valid UDREs.  The user should also  check for negative
%   return values which are flags for LOSs that are not monitored in the
%   current set of UDREs (NOT_MONITORED).  SIG2FLTs that were successfully
%   calculated will be positive non-zero values.
%
%   See also: GRID2UIVE

%2001Mar12 Created by Todd Walter
%2020Apr10 Modified by Todd Walter to return sigma instead of sigma^2

global MOPS_NOT_MONITORED MOPS_C_COVARIANCE;

%initialize return value
[n_los , ~]=size(los_xyzb);
sig_flt=repmat(MOPS_NOT_MONITORED,n_los,1);


for ipair=1:n_los
  dUDRE=sqrt(los_xyzb(ipair,:)*mt28_cov(:,:,prn(ipair))*los_xyzb(ipair,:)')...
                    + MOPS_C_COVARIANCE*mt28_sf(prn(ipair));

  sig_flt(ipair) = sig_udre(prn(ipair))*dUDRE;

end






