function svdata = L5_decode_geocorr(time, svdata)
%*************************************************************************
%*     Copyright c 2021 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%
% L5_DECODE_GEOCORR finds the position and degradation factor for the GEOs.
%    Only needs to be performed on ranging GEOs
%
% svdata = L5_decode_geocorr(time, svdata)
%
% Inputs:
%   time    -   time when the signal left the geo (unique per geo)
%   svdata  -   structure with satellite correction data decoded from the messages
%
%Outputs:
%   svdata  - structure with interpreted geo position and degradation with
%                     MT 39/40 and MT 37 timeouts checked
%    .geo_prn - PRN as determined by decoding the MT 39 or MT 47 slot delta
%
%    .geo_xyzb - delta XYZ and clock 
%    .geo_deg - geo degradation term
%
%See also: INIT_L5SVDATA L5_DECODE_MESSAGES READ_IN_SBAS_L5MESSAGES 
%          L5_DECODEMT39 L5_DECODEMT40 L5_DECODEMT37  L5_DECODEMT47 

%Created December 29, 2020 by Todd Walter

global L5MOPS_MT37_PATIMEOUT

%loop over all of the geo data channels
ngeos = length(svdata);

for gdx = 1:ngeos

    %Initialize satellite correction data
    svdata(gdx).geo_xyzb = NaN(size(svdata(gdx).geo_xyzb)); 

    %Must have valid MT 37 message in order to have valid position
    mdx37 = find(([svdata(gdx).mt37.time] >= (time - L5MOPS_MT37_PATIMEOUT)) & ...
              svdata(gdx).auth_pass([svdata(gdx).mt37.msg_idx]));
    if ~isempty(mdx37)
        mdx37 = mdx37(1); %use the most recent one

        % find the most recent authenticated MT 39 and MT 40 messages
        mdx39 = (reshape([svdata(gdx).mt39.time], size(svdata(gdx).mt39)) ...
                                 >= (time - svdata(gdx).mt37(mdx37).Ivalid3940)) & ...
                  svdata(gdx).auth_pass(reshape([svdata(gdx).mt39.msg_idx], size(svdata(gdx).mt39)));
        mdx40 = (reshape([svdata(gdx).mt40.time], size(svdata(gdx).mt40)) ...
                                 >= (time - svdata(gdx).mt37(mdx37).Ivalid3940)) & ...
                  svdata(gdx).auth_pass(reshape([svdata(gdx).mt40.msg_idx], size(svdata(gdx).mt40)));

        mdx3940 = any(mdx39')' & any(mdx40')'; % find those with matching  IODGs
        if any(mdx3940)
            mdx3940 = find(mdx3940);
            for jdx = 1:length(mdx3940)
                iodg = mdx3940(jdx);
                kdx39 = find(mdx39(iodg, :));
                kdx39 = kdx39(1);
                kdx40 = find(mdx40(iodg, :));
                kdx40 = kdx40(1);
                %set the prn and SPID values
                if isnan(svdata(gdx).geo_prn_time) || ...
                         svdata(gdx).mt39(iodg, kdx39).time > svdata(gdx).geo_prn_time
                    svdata(gdx).geo_prn = svdata(gdx).mt39(iodg, kdx39).prn;
                    svdata(gdx).geo_channel = gdx;
                    svdata(gdx).geo_spid = svdata(gdx).mt39(iodg, kdx39).spid;
                    svdata(gdx).geo_prn_time = svdata(gdx).mt39(iodg, kdx39).time;
                end

                %find the geo position
                svdata(gdx).mt3940(iodg, gdx).xyzb(1:3) = sbas_geoeph2satpos(time, ...
                                    svdata(gdx).mt39(iodg, kdx39), svdata(gdx).mt40(iodg, kdx40));

                %put in the GEO clock  !!!!!NOT REALLY SURE THIS IS CORRECT!!!!
                tmt0 = time - svdata(gdx).mt40(iodg, kdx40).te;
                svdata(gdx).mt3940(iodg, gdx).xyzb(4) = svdata(gdx).mt39(iodg, kdx39).agf0 + ...
                                         svdata(gdx).mt39(iodg, kdx39).agf1*tmt0;
                svdata(gdx).mt3940(iodg, gdx).time = max([svdata(gdx).mt39(iodg, kdx39).time ...
                                              svdata(gdx).mt40(iodg, kdx40).time]);
                                          
                %keep track of PRN and which MT40 was used
                svdata(gdx).mt3940(iodg, gdx).prn = svdata(gdx).geo_prn;
                svdata(gdx).mt3940(iodg, gdx).kdx40 = kdx40;
            end
        end
    end
    
    %process the almanac messages
    idx47 = find([svdata(gdx).mt47alm.time] >= (time - 3600*24*7));
    %prn data might also be found in almanac data  %%%%TODO check that it
    %%%%%%isn't there more than once or contradicts ephemeris prn/spid
    if ~isempty(idx47)
        for i = 1:length(idx47)
            %set the PRN value if authenticated and no MT 39 or not already set
            if svdata(gdx).auth_pass(svdata(gdx).mt47alm(idx47(i)).msg_idx) ...
                          && svdata(gdx).mt47alm(idx47(i)).brid
                if isnan(svdata(gdx).geo_prn_time) || ...
                     svdata(gdx).mt47alm(idx47(i)).time > svdata(gdx).geo_prn_time
                    svdata(gdx).geo_prn = svdata(gdx).mt47alm(idx47(i)).prn;
                    svdata(gdx).geo_channel = gdx;
                    svdata(gdx).geo_spid = svdata(gdx).mt47alm(idx47(i)).spid;
                    svdata(gdx).geo_prn_time = svdata(gdx).mt47alm(idx47(i)).time;
                end
            end
            %set the GEO position (may be overwritten later by MT39/40 content
            for cdx = 1:ngeos
                if svdata(gdx).mt47alm(idx47(i)).prn == svdata(cdx).geo_prn
                    svdata(gdx).geo_xyzb(cdx,1:3) = sbas_geoalm2satpos(time, ...
                                    svdata(gdx).mt47alm(idx47(i)));
                end
            end
        end
    end  
end

%load position and degradation factor into the other streams data
%assumes that the masks are all the same and in the same order as the geo data stream
for gdx = 1:ngeos 
    idx = setdiff(1:ngeos, gdx);
    for i = idx
        for iodg = 1:4
            svdata(gdx).mt3940(iodg, i).prn = svdata(i).mt3940(iodg, i).prn;
            svdata(gdx).mt3940(iodg, i).xyzb = svdata(i).mt3940(iodg, i).xyzb;
            svdata(gdx).mt3940(iodg, i).time = svdata(i).mt3940(iodg, i).time;
            svdata(gdx).mt3940(iodg, i).kdx40 = svdata(i).mt3940(iodg, i).kdx40;
        end
    end
end