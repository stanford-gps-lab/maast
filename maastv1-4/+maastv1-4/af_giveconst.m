function igpdata = af_giveconst(t, igpdata, wrsdata, satdata, wrs2satdata,truth_data)
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
%
%GIVE_const returns the give variancs for each IGP


%   Created 19 Jun 2001 by Todd Walter

%get constant parameters
global GIVEI_CONST
global COL_IGP_GIVEI COL_IGP_UPMGIVEI COL_IGP_MINMON

n_igp = size(igpdata,1);

%return values
%all IGPs meet the minimum monitoring requirements (used for histogram)
igpdata(:,COL_IGP_MINMON)=repmat(1,n_igp,1);

igpdata(:,[COL_IGP_GIVEI COL_IGP_UPMGIVEI])=repmat(GIVEI_CONST,n_igp,2);

