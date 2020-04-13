function [sig2_uive, varargout]=grid2uive(ll_ipp, IGPmask, inv_IGPmask, ...
                                           givei, igds, degrad, rss_iono)
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
%GRID2UIVE      calculates UIVEs given a set of IPPs and GIVEs
%SIG2_UIVE=GRID2UIVE(LL_IPP, IGPMASK, INV_IGPMASK, GIVEI, IGDs, DEGRAD, RSS_IONO)
%   Given nIPPs of Ionospheric Pierce Point (IPP) latitudes (first column)
%   and longitudes (second column) in LL_IPP(nIPPs,2), an Ionospheric Grid
%   Point (IGP) mask containing nIGPs latitudes (first column) and longitudes
%   (second column) in IGPMASK(nIGPs,2), an inverse of the IGPMASK, and the
%   GIVE indices for each of the IGPs in GIVEI(nIGPs,1), and the corresponding 
%   degradation terms and the rss_iono flag, this function will
%   determine the variance for each IPP (SIG2_UIVE) according to the SBAS MOPS.
%   The user should check for negative return values which are flags for IPPs
%   that are not monitored in the current set of GIVEs (NOT_MONITORED) or are
%   not within the region defined by the mask (NOT_IN_MASK).  User Ionospheric
%   Vertical Errors (UIVEs) that were successfully interpolated will be
%   positive non-zero values.  Optionally calculates the interpolated delay
%   value if the user requests a second output and the input IGDs are not
%   empty
%
%   See also: FIND_INV_IGPMASK IGPFORIPPS INTRIANGLE CHECKIGPSQUARE 
%

%2001Feb28 Created by Todd Walter


global MOPS_NOT_IN_MASK MOPS_NOT_MONITORED MOPS_SIG2_GIVE;


%initialize return value
nIPPs=size(ll_ipp,1);
nIGPs=size(givei,1);
sig2_uive=repmat(MOPS_NOT_MONITORED,nIPPs,1);

calc_delay=0;
%check if delay values are desired
if (nargout > 1) && (nargin > 4) && ~isempty(igds)
  calc_delay=1;
  user_delays = NaN(nIPPs,1);
  grid_delays = NaN(nIPPs,4);
  igds=[igds' NaN]';
end

W=zeros(nIPPs,4);
Wsize=size(W);
sig2_give=repmat(MOPS_NOT_MONITORED,nIPPs,4);
nBadgives=zeros(nIPPs,1);
IGPsig2_give=[MOPS_SIG2_GIVE(givei) MOPS_NOT_MONITORED]';

% add in degradation terms
if nargin > 6
    idx = IGPsig2_give > 0;
    if rss_iono
        IGPsig2_give(idx) = IGPsig2_give(idx) + degrad(idx).^2;
    else
        IGPsig2_give(idx) = (sqrt(IGPsig2_give(idx)) + degrad(idx)).^2;
    end
end
    
%create matrix to assist 3 point interpolation
%The MOPS equations are equivalent to adding the weight of the missing point
%To the adjacent IGPs and subtracting it from the opposite one
change2tri=[[0 1 -1 1]; [1 0 1 -1]; [-1 1 0 1]; [1 -1 1 0];];

%find the corresponding grid points
[IGPs, xyIPP, nBadIGPs] = igps4ipps(ll_ipp, IGPmask, inv_IGPmask);

%perform interpolation for ipps between -75 and 75 lat
idx=find(abs(ll_ipp(:,1))<=75.0);
if(~isempty(idx))
  %calculate the weights
  W(idx,1)=(1-xyIPP(idx,1)).*(1-xyIPP(idx,2));
  W(idx,2)=xyIPP(idx,1).*(1-xyIPP(idx,2));
  W(idx,3)=xyIPP(idx,1).*xyIPP(idx,2);
  W(idx,4)=(1-xyIPP(idx,1)).*xyIPP(idx,2);

  %are all 4 in the mask?
  mask4=find(nBadIGPs(idx)==0);
  if(~isempty(mask4))
    %assign GIVEs
    sig2_give(idx(mask4),1)=IGPsig2_give(IGPs(idx(mask4),1));
    sig2_give(idx(mask4),2)=IGPsig2_give(IGPs(idx(mask4),2));
    sig2_give(idx(mask4),3)=IGPsig2_give(IGPs(idx(mask4),3));
    sig2_give(idx(mask4),4)=IGPsig2_give(IGPs(idx(mask4),4));

    if calc_delay
      grid_delays(idx(mask4),1)=igds(IGPs(idx(mask4),1));
      grid_delays(idx(mask4),2)=igds(IGPs(idx(mask4),2));
      grid_delays(idx(mask4),3)=igds(IGPs(idx(mask4),3));
      grid_delays(idx(mask4),4)=igds(IGPs(idx(mask4),4));
    end
    %which IGPs are not activated
    [badcorner, badipp]=find(sig2_give(idx(mask4),:)'==MOPS_NOT_MONITORED);
    if(~isempty(badipp))
      %determine the number of bad GIVEs per IPP
      bad_idx=[1 find(diff(badipp))'+1];
      nBadgives(idx(mask4(badipp(bad_idx))))=diff([bad_idx length(badipp)+1]);
      
      %do we have at least 3 points?
      act3=find(nBadgives(idx(mask4))==1);
      if(~isempty(act3))
        %check to see if the point is in the triangle
        inv_badipp(badipp)=(1:length(badipp))';
        in=find(intriangle(xyIPP(idx(mask4(act3)),1),...
                     xyIPP(idx(mask4(act3)),2),badcorner(inv_badipp(act3))));
        if(~isempty(in))
          %perform 3 point interpolation

          %shorthand
          interp3=idx(mask4(act3(in)));
          badigp=badcorner(inv_badipp(act3(in)));

          %change weights for 3 point interpolation
          W(interp3,1)=W(interp3,1) + change2tri(badigp,1).*...
                                          W(sub2ind(Wsize,interp3,badigp));
          W(interp3,2)=W(interp3,2) + change2tri(badigp,2).*...
                                          W(sub2ind(Wsize,interp3,badigp));
          W(interp3,3)=W(interp3,3) + change2tri(badigp,3).*...
                                          W(sub2ind(Wsize,interp3,badigp));
          W(interp3,4)=W(interp3,4) + change2tri(badigp,4).*...
                                          W(sub2ind(Wsize,interp3,badigp));

          % zero out weight of missing IGP
          W(sub2ind(Wsize,interp3,badigp))=0;

          %interpolate to form uives
          sig2_uive(interp3)=sum((W(interp3,:).*sig2_give(interp3,:))')';
          if calc_delay
            %remove NaNs
            grid_delays(sub2ind(Wsize,interp3,badigp))=0;              
            user_delays(interp3)=sum((W(interp3,:).*grid_delays(interp3,:))')';
          end
        end
      end  
    end
    %find the ones with all 4 points
    act4=find(nBadgives(idx(mask4))==0);
    if(~isempty(act4))
      %perform 4 point interpolation
      sig2_uive(idx(mask4(act4)))=sum((W(idx(mask4(act4)),:).*...
                                   sig2_give(idx(mask4(act4)),:))')';
      if calc_delay
        user_delays(idx(mask4(act4)))=sum((W(idx(mask4(act4)),:).*...
                                   grid_delays(idx(mask4(act4)),:))')';
      end
    end
  end

  %are there 3 in the mask?
  mask3=find(nBadIGPs(idx)==1);
  if(~isempty(mask3))
    %which IGPs are not in the mask
    [badcorner, badipp]=find(IGPs(idx(mask3),:)'==MOPS_NOT_IN_MASK);

    %assign GIVEs
    tmpIGPs=IGPs(idx(mask3),:);
    tmpIGPs(sub2ind(size(tmpIGPs),badipp,badcorner))=nIGPs+1;
    sig2_give(idx(mask3),1)=IGPsig2_give(tmpIGPs(:,1));
    sig2_give(idx(mask3),2)=IGPsig2_give(tmpIGPs(:,2));
    sig2_give(idx(mask3),3)=IGPsig2_give(tmpIGPs(:,3));
    sig2_give(idx(mask3),4)=IGPsig2_give(tmpIGPs(:,4));

    if calc_delay
      grid_delays(idx(mask3),1)=igds(tmpIGPs(:,1));
      grid_delays(idx(mask3),2)=igds(tmpIGPs(:,2));
      grid_delays(idx(mask3),3)=igds(tmpIGPs(:,3));
      grid_delays(idx(mask3),4)=igds(tmpIGPs(:,4));
    end
    %which IGPs are not activated
    [~, badipp]=find(sig2_give(idx(mask3),:)'==MOPS_NOT_MONITORED);
    %determine the number of bad GIVEs per IPP
    bad_idx=[1 find(diff(badipp))'+1];
    nBadgives(idx(mask3(badipp(bad_idx))))=diff([bad_idx length(badipp)+1]);
      
    %do we have at least 3 points?
    act3=find(nBadgives(idx(mask3))==1);
    if(~isempty(act3))
      %perform 3 point interpolation

      %shorthand
      interp3=idx(mask3(act3));
      badigp=badcorner(act3);

      %change weights for 3 point interpolation
      W(interp3,1)=W(interp3,1) + change2tri(badigp,1).*...
                                          W(sub2ind(Wsize,interp3,badigp));
      W(interp3,2)=W(interp3,2) + change2tri(badigp,2).*...
                                          W(sub2ind(Wsize,interp3,badigp));
      W(interp3,3)=W(interp3,3) + change2tri(badigp,3).*...
                                          W(sub2ind(Wsize,interp3,badigp));
      W(interp3,4)=W(interp3,4) + change2tri(badigp,4).*...
                                          W(sub2ind(Wsize,interp3,badigp));

      % zero out weight of missing IGP
      W(sub2ind(Wsize,interp3,badigp))=0;

      %interpolate to form uives
      sig2_uive(interp3)=sum((W(interp3,:).*sig2_give(interp3,:))')';
      if calc_delay
        %remove NaNs
        grid_delays(sub2ind(Wsize,interp3,badigp))=0;
        user_delays(interp3)=sum((W(interp3,:).*grid_delays(interp3,:))')';
      end
    end
  end  
end

%perform interpolation for ipps between 75 and 85 lat
idx=find((ll_ipp(:,1) > 75.0) & (ll_ipp(:,1) <= 85.0));
if(~isempty(idx))
  %calculate the weights
  W(idx,1)=(1-xyIPP(idx,1)).*(1-xyIPP(idx,2));
  W(idx,2)=xyIPP(idx,1).*(1-xyIPP(idx,2));
  W(idx,3)=xyIPP(idx,1).*xyIPP(idx,2);
  W(idx,4)=(1-xyIPP(idx,1)).*xyIPP(idx,2);

  %are all 4 in the mask?
  mask4=find(nBadIGPs(idx)==0);
  if(~isempty(mask4))
    %assign GIVEs
    sig2_give(idx(mask4),1)=IGPsig2_give(IGPs(idx(mask4),1));
    sig2_give(idx(mask4),2)=IGPsig2_give(IGPs(idx(mask4),2));
    sig2_give(idx(mask4),3)=IGPsig2_give(IGPs(idx(mask4),3));
    sig2_give(idx(mask4),4)=IGPsig2_give(IGPs(idx(mask4),4));

    if calc_delay
      grid_delays(idx(mask4),1)=igds(IGPs(idx(mask4),1));
      grid_delays(idx(mask4),2)=igds(IGPs(idx(mask4),2));
      grid_delays(idx(mask4),3)=igds(IGPs(idx(mask4),3));
      grid_delays(idx(mask4),4)=igds(IGPs(idx(mask4),4));
    end
    %which IGPs are not activated
    [~, badipp]=find(sig2_give(idx(mask4),:)'==MOPS_NOT_MONITORED);
    if(~isempty(badipp))
      %determine the number of bad GIVEs per IPP
      bad_idx=[1 find(diff(badipp))'+1];
      nBadgives(idx(mask4(badipp(bad_idx))))=diff([bad_idx length(badipp)+1]);
    end      
    %find the ones with all 4 points
    act4=find(nBadgives(idx(mask4))==0);
    if(~isempty(act4))

      %short hand
      grid_lon(:,4)=IGPmask(IGPs(idx(mask4(act4)),4),2);
      grid_lon(:,1)=IGPmask(IGPs(idx(mask4(act4)),1),2);
      grid_lon(:,2)=IGPmask(IGPs(idx(mask4(act4)),2),2);
      grid_lon(:,3)=IGPmask(IGPs(idx(mask4(act4)),3),2);
      sep85=abs(grid_lon(:,3)-grid_lon(:,4));

      %form variances at Virtual Grid Points
      sig2_IGPp3 = abs(grid_lon(:,4) - grid_lon(:,2))... 
                             .*sig2_give(idx(mask4(act4)),3)./sep85 +...
                   abs(grid_lon(:,3) - grid_lon(:,2))...
                             .*sig2_give(idx(mask4(act4)),4)./sep85;
      sig2_IGPp4 = abs(grid_lon(:,4) - grid_lon(:,1))... 
                             .*sig2_give(idx(mask4(act4)),3)./sep85 +...
                   abs(grid_lon(:,3) - grid_lon(:,1))...
                             .*sig2_give(idx(mask4(act4)),4)./sep85;

      sig2_give(idx(mask4(act4)),3) = sig2_IGPp3;
      sig2_give(idx(mask4(act4)),4) = sig2_IGPp4;

      %perform 4 point interpolation
      sig2_uive(idx(mask4(act4)))=sum((W(idx(mask4(act4)),:).*...
                                   sig2_give(idx(mask4(act4)),:))')';
      if calc_delay
        %form variances at Virtual Grid Points
        delay_IGPp3 = abs(grid_lon(:,4) - grid_lon(:,2))... 
                             .*grid_delays(idx(mask4(act4)),3)./sep85 +...
                   abs(grid_lon(:,3) - grid_lon(:,2))...
                             .*grid_delays(idx(mask4(act4)),4)./sep85;
        delay_IGPp4 = abs(grid_lon(:,4) - grid_lon(:,1))... 
                             .*grid_delays(idx(mask4(act4)),3)./sep85 +...
                   abs(grid_lon(:,3) - grid_lon(:,1))...
                             .*grid_delays(idx(mask4(act4)),4)./sep85;

        grid_delays(idx(mask4(act4)),3) = delay_IGPp3;
        grid_delays(idx(mask4(act4)),4) = delay_IGPp4;

        %perform 4 point interpolation
        user_delays(idx(mask4(act4)))=sum((W(idx(mask4(act4)),:).*...
                                   grid_delays(idx(mask4(act4)),:))')';
      end
    end
  end
end

%perform interpolation for ipps above 85 lat
idx=find((ll_ipp(:,1) > 85.0));
if(~isempty(idx))
  %calculate the weights
  W(idx,1)=(1-xyIPP(idx,1)).*(1-xyIPP(idx,2));
  W(idx,2)=xyIPP(idx,1).*(1-xyIPP(idx,2));
  W(idx,3)=xyIPP(idx,1).*xyIPP(idx,2);
  W(idx,4)=(1-xyIPP(idx,1)).*xyIPP(idx,2);

  %are all 4 in the mask?
  mask4=find(nBadIGPs(idx)==0);
  if(~isempty(mask4))
    %assign GIVEs
    sig2_give(idx(mask4),1)=IGPsig2_give(IGPs(idx(mask4),1));
    sig2_give(idx(mask4),2)=IGPsig2_give(IGPs(idx(mask4),2));
    sig2_give(idx(mask4),3)=IGPsig2_give(IGPs(idx(mask4),3));
    sig2_give(idx(mask4),4)=IGPsig2_give(IGPs(idx(mask4),4));

    if calc_delay
      grid_delays(idx(mask4),1)=igds(IGPs(idx(mask4),1));
      grid_delays(idx(mask4),2)=igds(IGPs(idx(mask4),2));
      grid_delays(idx(mask4),3)=igds(IGPs(idx(mask4),3));
      grid_delays(idx(mask4),4)=igds(IGPs(idx(mask4),4));
    end
    %which IGPs are not activated
    [~, badipp]=find(sig2_give(idx(mask4),:)'==MOPS_NOT_MONITORED);
    if(~isempty(badipp))
      %determine the number of bad GIVEs per IPP
      bad_idx=[1 find(diff(badipp))'+1];
      nBadgives(idx(mask4(badipp(bad_idx))))=diff([bad_idx length(badipp)+1]);
    end      
    %find the ones with all 4 points
    act4=find(nBadgives(idx(mask4))==0);
    if(~isempty(act4))
      %perform 4 point interpolation
      sig2_uive(idx(mask4(act4)))=sum((W(idx(mask4(act4)),:).*...
                                   sig2_give(idx(mask4(act4)),:))')';
      if calc_delay
        user_delays(idx(mask4(act4)))=sum((W(idx(mask4(act4)),:).*...
                                   grid_delays(idx(mask4(act4)),:))')';
      end
    end
  end
end

if calc_delay
  varargout(1) = {user_delays};
end
%%%TODO Test interpolation in other parts of the world 
%                                      (only North America Tested so far)
%%%TODO add interpolation below -75 degrees



































