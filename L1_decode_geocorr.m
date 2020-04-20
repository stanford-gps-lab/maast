function svdata = L1_decode_geocorr(time, svdata, mt10)
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
%
% L1_DECODE_GEOCORR finds the position and degradation factor for the GEOs.
%    Only needs to be performed on ranging GEOs
%
% svdata = L1_decode_geocorr(time, svdata, mt10)
%
% Inputs:
%   time    -   time when the signal left the geo (unique per geo)
%   svdata  -   structure with satellite correction data decoded from the messages
%   mt10    -   structure with degradation parameters from MT10
%
%Outputs:
%   svdata  - structure with interpreted geo position and degradation with
%                     MT 9 and MT 17 timeouts checked
%    .geo_prn - PRN as determined by matching the MT 9 and MT 17
%
%    .geo_xyzb - delta XYZ and clock 
%    .geo_deg - geo degradation term
%
%See also: INIT_SVDATA INIT_MT10DATA L1_DECODE_GEOCORR L1_DECODE_MESSAGES 
%          L1_DECODEMT1 L1_DECODEMT7 L1_DECODEMT9  L1_DECODEMT10 

%Created March 30, 2020 by Todd Walter

C = 299792458.0; % speed of light,  m/sec

global MOPS_MT9_PATIMEOUT MOPS_MT10_PATIMEOUT MOPS_MT17_PATIMEOUT

%loop over all of the geo data channels
ngeos = length(svdata);

for mdx = 1:ngeos

    %Initialize satellite correction data
    svdata(mdx).geo_xyzb = NaN(size(svdata(mdx).geo_xyzb)); 
    svdata(mdx).geo_deg = NaN(size(svdata(mdx).geo_deg));

    %Must have valid MT 9 message in order to have valid posiiton
    if svdata(mdx).mt9_time >= (time - MOPS_MT9_PATIMEOUT)

        %find the geo position
        tmt0 = time - svdata(mdx).mt9_t0;
        tmt0 = tmt0 - svdata(mdx).mt9_af0 - svdata(mdx).mt9_af1*tmt0;
        svdata(mdx).geo_xyzb(mdx,1:3) = svdata(mdx).mt9_xyz + ...
                                    svdata(mdx).mt9_xyz_dot*tmt0 + ...
                                    svdata(mdx).mt9_xyz_dot_dot*(tmt0^2)/2;

        %put in the GEO clock  !!!!!NOT REALLY SURE THIS IS CORRECT!!!!!
        svdata(mdx).geo_xyzb(mdx, 4) = C*(svdata(mdx).mt9_af0 + ...
                                     svdata(mdx).mt9_af1*tmt0);
                                 
        %Must also have valid MT 10 messages in order to have valid correction degradations
        if mt10(mdx).time >= (time - MOPS_MT10_PATIMEOUT)
            %find the geo long-term correction degradation factor
            if tmt0 > 0 && tmt0 < mt10(mdx).igeo
                svdata(mdx).geo_deg(mdx) = 0;
            else
                svdata(mdx).geo_deg(mdx) = mt10(mdx).cgeo_lsb + ...
                           mt10(mdx).cgeo_v*max([0 -tmt0 tmt0 ...
                                                 (tmt0 - mt10(mdx).iltc_v1)]);
            end
        end
        
        %Must have valid MT 17 messages in order to have valid PRN and service provider ID
        % compare position to the different almanacs
        adx = 1;
        while adx <= length(svdata(mdx).mt17_prn) && isnan(svdata(mdx).geo_prn)
            %make sure MT 17 data  has not timed out
            if svdata(mdx).mt17_time(adx) >= (time - MOPS_MT17_PATIMEOUT)

                %find the almanac position
                tmt0 = time - svdata(mdx).mt17_t0(adx);
                alm_xyz = svdata(mdx).mt17_xyz(adx,:) + svdata(mdx).mt17_xyz_dot(adx,:)*tmt0; 

                %check that positions match within 200 km
                if sum((svdata(mdx).geo_xyzb(mdx,1:3) - alm_xyz).^2) <= 4e10
                    % if so, set PRN SPID and flags
                    svdata(mdx).geo_prn = svdata(mdx).mt17_prn(adx);
                    flags = dec2bin(svdata(mdx).mt17_health(adx),8);
                    svdata(mdx).geo_spid = bin2dec(flags(5:8)); 
                    svdata(mdx).geo_flags = flags(1:4) - 48; % convert from ascii '0' = 48
                    svdata(mdx).geo_prn_time = svdata(mdx).mt17_time(adx);
                    
                    %if geo is not for ranging then don't calculate the degradation
                    % flags are for information only and carry no requirements
%                     if svdata(mdx).geo_flags(1) > 0
%                         svdata(mdx).geo_deg(mdx) = NaN;
%                     end
                end
            end
            adx = adx + 1;
        end        
    end
    %time out old data %%evidently this is not actually done
%     if time - svdata(mdx).geo_prn_time > MOPS_MT17_PATIMEOUT
%         svdata(mdx).geo_prn = NaN;
%         svdata(mdx).geo_spid = NaN; % Service provider ID
%         svdata(mdx).geo_flags = NaN; % [ranging, precise corr, basic corr, reserved] [0: on / 1: off] 
%     end
end

%load position and degradation factor into the other streams data
%assumes that the masks are all the same and in the same order as the geo data stream
for mdx = 1:ngeos 
    idx = setdiff(1:ngeos, mdx);
    for i = idx
        svdata(mdx).geo_xyzb(i,:) = svdata(i).geo_xyzb(i,:);
        svdata(mdx).geo_deg(i) = svdata(i).geo_deg(i);
    end
end