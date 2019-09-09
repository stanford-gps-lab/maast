function [] = uiveVariance(obj, givei, igpData)
% This function calculates the user ionosphere vertical error variance
% given an sbas user observation, the satellite grid ionosphere vertical
% error indicators and ionosphere grid point data.
%
% This function is taken mostly from the form presented in the original
% maast. The functionality of this code may change over time.

% Get WAAS MOPS Constants
waasMOPSConstants = maast.constants.WAASMOPSConstants;

% Allocate variables to be used in this function
ll_ipp = obj.IPP;
IGPmask = igpData.IGPMask;
inv_IGPmask = igpData.InvIGPMask;
MOPS_NOT_MONITORED = waasMOPSConstants.NotMonitored;
MOPS_NOT_IN_MASK = waasMOPSConstants.NotInMask;

%initialize return value
nIPPs=size(ll_ipp,1);
nIGPs=size(givei,1);
sig2_uive=repmat(waasMOPSConstants.NotMonitored,nIPPs,1);

calc_delay=0;

W=zeros(nIPPs,4);
Wsize=size(W);
sig2_give=repmat(waasMOPSConstants.NotMonitored,nIPPs,4);
nBadgives=zeros(nIPPs,1);
IGPsig2_give=[waasMOPSConstants.Sig2GIVE(givei) waasMOPSConstants.NotMonitored]';
%IGPsig2_give=[givei' MOPS_NOT_MONITORED]';  % replaces line above for test

%create matrix to assist 3 point interpolation
%The MOPS equations are equivalent to adding the weight of the missing point
%To the adjacent IGPs and subtracting it from the opposite one
change2tri=[[0 1 -1 1]; [1 0 1 -1]; [-1 1 0 1]; [1 -1 1 0];];

%find the corresponding grid points
[IGPs, xyIPP, nBadIGPs] = igps4ipps(ll_ipp, IGPmask, inv_IGPmask, waasMOPSConstants);

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
        [badcorner badipp]=find(sig2_give(idx(mask4),:)'==MOPS_NOT_MONITORED);
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
        [badcorner badipp]=find(IGPs(idx(mask3),:)'==MOPS_NOT_IN_MASK);
        
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
        [temp badipp]=find(sig2_give(idx(mask3),:)'==MOPS_NOT_MONITORED);
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
            grid_delay(idx(mask4),1)=igds(IGPs(idx(mask4),1));
            grid_delay(idx(mask4),2)=igds(IGPs(idx(mask4),2));
            grid_delay(idx(mask4),3)=igds(IGPs(idx(mask4),3));
            grid_delay(idx(mask4),4)=igds(IGPs(idx(mask4),4));
        end
        %which IGPs are not activated
        [badcorner badipp]=find(sig2_give(idx(mask4),:)'==MOPS_NOT_MONITORED);
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
                
                grid_delays(idx(mask4(act4)),3) = sig2_IGPp3;
                grid_delays(idx(mask4(act4)),4) = sig2_IGPp4;
                
                %perform 4 point interpolation
                user_delays(idx(mask4(act4)))=sum((W(idx(mask4(act4)),:).*...
                    grid_delays(idx(mask4(act4)),:))')';
            end
        end
    end
end

if calc_delay
    varargout(1) = {user_delays};
end

% Allocate properties
obj.Sig2UIVE = NaN(length(obj.SatellitesInViewMask), 1);
obj.Sig2UIVE(obj.SatellitesInViewMask) = sig2_uive;

%%%TODO Test interpolation in other parts of the world
%                                      (only North America Tested so far)
%%%TODO add interpolation above 85 degrees and below -75 degrees
end

function [IGPs, xyIPP, nBadIGPs]=igps4ipps(ll_ipp, IGPmask, inv_IGPmask, waasMOPSConstants)

MOPS_NOT_IN_MASK = waasMOPSConstants.NotInMask;
IGPmask_min_lat=-85;
IGPmask_max_lat=85;

IGPmask_min_lon=0;
IGPmask_max_lon=355;

IGPmask_increment=5;

%initialize return values
[nIPPs temp]=size(ll_ipp);
IGPs=ones(nIPPs,4)*MOPS_NOT_IN_MASK;
xyIPP=zeros(nIPPs,2);
nBadIGPs=ones(nIPPs,1)*4;

%make sure the longitudes run 0 to 360 degrees
ll_ipp(:,2)=mod(ll_ipp(:,2)+360,360);

%convert the latitudes and longitues to 5 degree integer values for SW corner
mask_idx=floor(ll_ipp/IGPmask_increment);
mask_idx(:,2)=mod(mask_idx(:,2),360/IGPmask_increment)+1;

% adjust the latitude indicies to run from 1 to N
mask_idx(:,1)=mask_idx(:,1)-IGPmask_min_lat/IGPmask_increment + 1;

%compute for 5x5 region
idx=find(abs(ll_ipp(:,1))<=60.0);
if(~isempty(idx))
    
    %Start with 5x5 interpolation
    [IGPs(idx,:) xyIPP(idx,:) nBadIGPs(idx)]=check_igpsquare(ll_ipp(idx,:),...
        mask_idx(idx,:), inv_IGPmask, 5, 5, 0, 0, waasMOPSConstants);
    
    % are there points that were not in 5x5 masking, if yes look for 10x10
    bad_idx=find(nBadIGPs(idx)>1);
    
    if(~isempty(bad_idx))
        bad_idx=idx(bad_idx);
        %Try 10x10 interpolation with odd latitude and even longitude
        tmp_mask_idx=mask_idx(bad_idx,:);
        evenlat=find(~mod(tmp_mask_idx(:,1),2));
        if(~isempty(evenlat))
            tmp_mask_idx(evenlat,1)=tmp_mask_idx(evenlat,1)-1;
        end
        oddlon=find(~mod(tmp_mask_idx(:,2),2));
        if(~isempty(oddlon))
            tmp_mask_idx(oddlon,2)=tmp_mask_idx(oddlon,2)-1;
        end
        [IGPs(bad_idx,:) xyIPP(bad_idx,:) nBadIGPs(bad_idx)]=check_igpsquare(...
            ll_ipp(bad_idx,:), tmp_mask_idx, inv_IGPmask, 10, 10, 5, 0, waasMOPSConstants);
    end
    
    %TODO add other combinations
end

%compute for 5x10 region
idx=find(abs(ll_ipp(:,1)) > 60.0 & abs(ll_ipp(:,1))<75.0);
if(~isempty(idx))
    
    %Start with 5x10 interpolation
    oddlon=find(~mod(mask_idx(idx,2),2));
    if(~isempty(oddlon))
        mask_idx(idx(oddlon),2)=mask_idx(idx(oddlon),2)-1;
    end
    [IGPs(idx,:) xyIPP(idx,:) nBadIGPs(idx)]=check_igpsquare(ll_ipp(idx,:),...
        mask_idx(idx,:), inv_IGPmask, 5, 10, 0, 0, waasMOPSConstants);
    
    % are there points that were not in 5x10 masking, if yes look for 10x10
    bad_idx=find(nBadIGPs(idx)>1);
    
    if(~isempty(bad_idx))
        bad_idx=idx(bad_idx);
        %Use 10x10 interpolation with odd latitude and even longitude
        tmp_mask_idx=mask_idx(bad_idx,:);
        evenlat=find(~mod(tmp_mask_idx(:,1),2));
        if(~isempty(evenlat))
            tmp_mask_idx(evenlat,1)=tmp_mask_idx(evenlat,1)-1;
        end
        [IGPs(bad_idx,:) xyIPP(bad_idx,:) nBadIGPs(bad_idx)]=check_igpsquare(...
            ll_ipp(bad_idx,:), tmp_mask_idx, inv_IGPmask, 10, 10, 5, 0, waasMOPSConstants);
    end
end


%compute for 75 to 85 region
idx=find(ll_ipp(:,1) >= 75.0 & ll_ipp(:,1)<85.0);
if(~isempty(idx))
    
    %Start with 10x30 box
    oddlon=find(~mod(mask_idx(idx,2),2));
    if(~isempty(oddlon))
        mask_idx(idx(oddlon),2)=mask_idx(idx(oddlon),2)-1;
    end
    evenlat=find(~mod(mask_idx(idx,1),2));
    if(~isempty(evenlat))
        mask_idx(idx(evenlat),1)=mask_idx(idx(evenlat),1)-1;
    end
    
    %find 30 degree longitude separations
    mask30_idx=floor(ll_ipp(idx,2)/30)*6 + 1;
    
    mask_size=size(inv_IGPmask);
    %specify the SW, SE, NE and then NW corners
    IGPs(idx,1)=inv_IGPmask(sub2ind(mask_size,mask_idx(idx,1),mask_idx(idx,2)));
    IGPs(idx,2)=inv_IGPmask(sub2ind(mask_size,mask_idx(idx,1),...
        mask_idx(idx,2) + 2));
    IGPs(idx,3)=inv_IGPmask(sub2ind(mask_size,mask_idx(idx,1) + 2,...
        mod(mask30_idx + 6, 72)));
    IGPs(idx,4)=inv_IGPmask(sub2ind(mask_size,mask_idx(idx,1) + 2,...
        mask30_idx));
    
    % calculate the x and y for the SW corner
    xyIPP(idx,2)=rem(360+ll_ipp(idx,1)-5, 10)/10;
    xyIPP(idx,1)=rem(360+ll_ipp(idx,2), 10)/10;
    
    % check for bad IGPs
    nBadIGPs(idx)=0;
    [badcorner badipp]=find(IGPs(idx,:)'==MOPS_NOT_IN_MASK);
    if(~isempty(badipp))
        %determine the number of bad IGPs per IPP
        bad_idx=[1 find(diff(badipp))'+1];
        nBadIGPs(idx(badipp(bad_idx)))=diff([bad_idx length(badipp)+1]);
    end
    
    %if not 4 points look for 90 degree separation
    mask08=find(nBadIGPs(idx) > 0);
    if(~isempty(mask08))
        %find 90 degree longitude separations
        mask90_idx=floor(ll_ipp(idx(mask08),2)/90)*18 + 1;
        
        %specify the SW, SE, NE and then NW corners
        IGPs(idx(mask08),1)=inv_IGPmask(...
            sub2ind(mask_size,mask_idx(idx(mask08),1),mask_idx(idx(mask08),2)));
        IGPs(idx(mask08),2)=inv_IGPmask(...
            sub2ind(mask_size,mask_idx(idx(mask08),1), mask_idx(idx(mask08),2) + 2));
        IGPs(idx(mask08),3)=inv_IGPmask(...
            sub2ind(mask_size,mask_idx(idx(mask08),1) + 2, mod(mask90_idx + 18, 72)));
        IGPs(idx(mask08),4)=inv_IGPmask(...
            sub2ind(mask_size,mask_idx(idx(mask08),1) + 2, mask90_idx));
        
        % calculate the x and y for the SW corner
        xyIPP(idx(mask08),2)=rem(360+ll_ipp(idx(mask08),1)-5, 10)/10;
        xyIPP(idx(mask08),1)=rem(360+ll_ipp(idx(mask08),2), 10)/10;
        
        % check for bad IGPs
        nBadIGPs(idx(mask08))=0;
        [badcorner badipp]=find(IGPs(idx(mask08),:)'==MOPS_NOT_IN_MASK);
        if(~isempty(badipp))
            %determine the number of bad IGPs per IPP
            bad_idx=[1 find(diff(badipp))'+1];
            nBadIGPs(idx(mask08(badipp(bad_idx))))=diff([bad_idx length(badipp)+1]);
        end
    end
end

%TODO add calculation for -75 to -85

%TODO finish calculation for beyond 85 region

%compute for 85 degrees and above
i=find(ll_ipp(:,1)>85.0);
if(~isempty(i))
    
    %specify the 4 IGPs
    lat_idx=85/IGPmask_increment - IGPmask_min_lat/IGPmask_increment + 1;
    IGPs(i,1)=inv_IGPmask(lat_idx,180/IGPmask_increment + 1);
    IGPs(i,2)=inv_IGPmask(lat_idx,270/IGPmask_increment + 1);
    IGPs(i,3)=inv_IGPmask(lat_idx,0/IGPmask_increment + 1);
    IGPs(i,4)=inv_IGPmask(lat_idx,90/IGPmask_increment + 1);
end

%compute for -85 degrees and below
i=find(ll_ipp(:,1)>85.0);
if(~isempty(i))
    
    %specify the 4 IGPs
    lat_idx=-85/IGPmask_increment - IGPmask_min_lat/IGPmask_increment + 1;
    IGPs(i,1)=inv_IGPmask(lat_idx,220/IGPmask_increment + 1);
    IGPs(i,2)=inv_IGPmask(lat_idx,310/IGPmask_increment + 1);
    IGPs(i,3)=inv_IGPmask(lat_idx,40/IGPmask_increment + 1);
    IGPs(i,4)=inv_IGPmask(lat_idx,130/IGPmask_increment + 1);
end
end

function [IGPs, xyIPP, nBadIGPs]=check_igpsquare(ll_ipp, mask_idx, inv_IGPmask, lat_spacing, lon_spacing, lat_base, lon_base, waasMOPSConstants)

MOPS_NOT_IN_MASK = waasMOPSConstants.NotInMask;

%initialize return values
[nIPPs temp]=size(ll_ipp);
IGPs=repmat(MOPS_NOT_IN_MASK,nIPPs,4);
xyIPP=zeros(nIPPs,2);
nBadIGPs=zeros(nIPPs,1);

mask_size=size(inv_IGPmask);

%specify the SW, SE, NE and then NW corners
IGPs(:,1)=inv_IGPmask(sub2ind(mask_size,mask_idx(:,1),mask_idx(:,2)));
IGPs(:,2)=inv_IGPmask(sub2ind(mask_size,mask_idx(:,1),...
                                        mask_idx(:,2) + lon_spacing/5));
IGPs(:,3)=inv_IGPmask(sub2ind(mask_size,mask_idx(:,1) + lat_spacing/5,...
                                        mask_idx(:,2) + lon_spacing/5));
IGPs(:,4)=inv_IGPmask(sub2ind(mask_size,mask_idx(:,1) + lat_spacing/5,...
                                        mask_idx(:,2)));

% calculate the x and y for the SW corner
xyIPP(:,2)=rem(360+ll_ipp(:,1)-lat_base,lat_spacing)/lat_spacing;
xyIPP(:,1)=rem(360+ll_ipp(:,2)-lon_base,lon_spacing)/lon_spacing;

% check for at least 3 in the mask 
%[badcorner badipp]=find(IGPs'==MOPS_NOT_IN_MASK);
[badcorner badipp]=find(IGPs'==MOPS_NOT_IN_MASK);
if(~isempty(badipp))
  %determine the number of bad IGPs per IPP
  bad_idx=[1 find(diff(badipp))'+1];
  nBadIGPs(badipp(bad_idx))=diff([bad_idx length(badipp)+1]);

  %if just one bad IPP try triangular interpolation
  mask3=find(nBadIGPs==1);
  if(~isempty(mask3))
    inv_badipp(badipp)=(1:length(badipp))';
    out=find(~intriangle(xyIPP(mask3,1),xyIPP(mask3,2),...
                                        badcorner(inv_badipp(mask3))));
    if(~isempty(out))
        nBadIGPs(mask3(out))=2;
    end
  end
end

end

function result=intriangle(x,y,corner)

result=zeros(size(corner));

idx=find(corner==1);
if(~isempty(idx))
  result(idx)=(y(idx)>=1-x(idx));
end
idx=find(corner==2);
if(~isempty(idx))
  result(idx)=(y(idx)>=x(idx));
end
idx=find(corner==3);
if(~isempty(idx))
  result(idx)=(y(idx)<=1-x(idx));
end
idx=find(corner==4);
if(~isempty(idx))
  result(idx)=(y(idx)<=x(idx));
end

end
