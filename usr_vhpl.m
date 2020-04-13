function vhpl=usr_vhpl(los_xyzb, usr_idx, sig2_i, prn, pa_mode)

%*************************************************************************
%*     Copyright c 2013 The board of trustees of the Leland Stanford     *
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
%Modified Todd Walter Sept. 4, 2013 to include multi-constellation &
%                                      non-ranging geos

global MOPS_NOT_MONITORED MOPS_KV_PA MOPS_KH_PA MOPS_KH_NPA
global MOPS_MIN_GPSPRN MOPS_MAX_GPSPRN MOPS_MIN_GLOPRN MOPS_MAX_GLOPRN 
global MOPS_MIN_GALPRN MOPS_MAX_GALPRN MOPS_MIN_GEOPRN MOPS_MAX_GEOPRN
global MOPS_MIN_BDUPRN MOPS_MAX_BDUPRN
global TRUTH_FLAG

%initialize return value
n_usr=max(usr_idx);
vhpl=repmat(MOPS_NOT_MONITORED,n_usr,2);
e=ones(50,1);

for usr=1:n_usr
  sv_idx=find(usr_idx==usr);
  n_view=0;
  % determine which satellites and constellations are in view
  sgps=find(prn(sv_idx) >= MOPS_MIN_GPSPRN & ...
            prn(sv_idx) <= MOPS_MAX_GPSPRN);
  sglo=find(prn(sv_idx) >= MOPS_MIN_GLOPRN & ...
            prn(sv_idx) <= MOPS_MAX_GLOPRN);
  sgal=find(prn(sv_idx) >= MOPS_MIN_GALPRN & ...
            prn(sv_idx) <= MOPS_MAX_GALPRN);
  sbdu=find(prn(sv_idx) >= MOPS_MIN_BDUPRN & ...
            prn(sv_idx) <= MOPS_MAX_BDUPRN);
%   sgnss =[sgps; sglo; sgal; sbdu];

  sgeo=find(prn(sv_idx) >= MOPS_MIN_GEOPRN & ...
            prn(sv_idx) <= MOPS_MAX_GEOPRN);
  n_gps = length(sgps);
  n_glo = length(sglo);
  n_gal = length(sgal);
  n_bdu = length(sbdu);
%  n_gnss = length(sgnss);
  n_geo = length(sgeo);  
  
  % build the G matrix
  n_const = 0;
  G=[];
  sview = [];
  if n_gps
      n_const = n_const+1;
      n_view = n_view + n_gps;
      G=los_xyzb(sv_idx(sgps),:);
      sview = sv_idx(sgps);
  end
  if n_glo
      n_const = n_const+1;
      n_view = n_view + n_glo;
      if isempty(G)
          G=los_xyzb(sv_idx(sglo),:);
      sview = sv_idx(sglo);          
      else
          G=[[G zeros(size(G,1),1)]; [los_xyzb(sv_idx(sglo),1:3) ...
                         zeros(n_glo,1) los_xyzb(sv_idx(sglo),4)]];
          sview = [sview; sv_idx(sglo)];
      end
  end
  if n_gal
      n_const = n_const+1;
      n_view = n_view + n_gal;
      if isempty(G)
          G=los_xyzb(sv_idx(sgal),:);
      sview = sv_idx(sgal);
      
      else
          G=[[G zeros(size(G,1),1)]; [los_xyzb(sv_idx(sgal),1:3) ...
                         zeros(n_gal,n_const-1) los_xyzb(sv_idx(sgal),4)]];
          sview = [sview; sv_idx(sgal)];
      end
  end
  if n_bdu
      n_const = n_const+1;
      n_view = n_view + n_bdu;      
      if isempty(G)
          G=los_xyzb(sv_idx(sbdu),:);
      sview = sv_idx(sbdu);
      else
          G=[[G zeros(size(G,1),1)]; [los_xyzb(sv_idx(sbdu),1:3) ...
                         zeros(n_bdu,n_const-1) los_xyzb(sv_idx(sbdu),4)]];
          sview = [sview; sv_idx(sbdu)];
      end
  end
  % add in GEOs with clock state corresponding to the first constellation
  %  if they are ranging geos (sigma is not NaN)
  if n_geo
      s_good_geo = find(sig2_i(sv_idx(sgeo)) > 0.0);
      n_good_geo = length(s_good_geo);
      n_view = n_view + n_good_geo;
      G=[G; [los_xyzb(sv_idx(sgeo(s_good_geo)),:) ...
                                   zeros(n_good_geo,n_const-1)]];
      sview = [sview; sv_idx(sgeo(s_good_geo))];      
  end  
  %check for minimum in view and geo visibility
  if((n_view>2+n_const && n_geo) || (TRUTH_FLAG == 1 && n_view > 3))
    W=diag(e(1:n_view)./sig2_i(sview));
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






