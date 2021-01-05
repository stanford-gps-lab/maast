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

for mdx = 1:ngeos

    %Initialize satellite correction data
    svdata(mdx).geo_xyzb = NaN(size(svdata(mdx).geo_xyzb)); 

    %Must have valid MT 37 message in order to have valid position
    if svdata(mdx).mt37(1).time >= (time - L5MOPS_MT37_PATIMEOUT)


        %loop over all possible IODG values
        for idx = 1:4
            %Initialize satellite correction data
            svdata(mdx).mt3940(idx).xyzb = NaN(size(svdata(mdx).mt3940(idx).xyzb));
            
            %Must have valid and matching MT 39 & 40 messages
            if svdata(mdx).mt39(idx).time >= (time - svdata(mdx).mt37(1).Ivalid3940) && ...
                svdata(mdx).mt40(idx).time >= (time - svdata(mdx).mt37(1).Ivalid3940) && ...
                 svdata(mdx).mt39(idx).iodg == svdata(mdx).mt40(idx).iodg

                %set the prn and SPID values
                if isnan(svdata(mdx).geo_prn_time) || ...
                         svdata(mdx).mt39(idx).time > svdata(mdx).geo_prn_time
                    svdata(mdx).geo_prn = svdata(mdx).mt39(idx).prn;
                    svdata(mdx).geo_spid = svdata(mdx).mt39(idx).spid;
                    svdata(mdx).geo_prn_time = svdata(mdx).mt39(idx).time;
                end

                %find the geo position
                tmt0 = time - svdata(mdx).mt40(idx).te;
                tmt0 = tmt0 - svdata(mdx).mt39(idx).agf0 - svdata(mdx).mt39(idx).agf1*tmt0;
                svdata(mdx).mt3940(idx).xyzb(1:3) = sbas_geoeph2satpos(time, ...
                                    svdata(mdx).mt39(idx), svdata(mdx).mt40(idx));

                %put in the GEO clock  !!!!!NOT REALLY SURE THIS IS CORRECT!!!!
                svdata(mdx).mt3940(idx).xyzb(4) = svdata(mdx).mt39(idx).agf0 + ...
                                         svdata(mdx).mt39(idx).agf1*tmt0;
            end
        end
    end
    
    %process the almanac messages
    for i = length(svdata(mdx).mt47alm):-1:1
        mt47time(i) = svdata(mdx).mt47alm(i).time;
    end
    idx = find(mt47time >= (time - 3600*24*7));
    %prn data might also be found in almanac data  %%%%TODO check that it
    %%%%%%isn't there more than once or contradicts ephemeris prn/spid
    if ~isempty(idx)
        for i = 1:length(idx)
            if svdata(mdx).mt47alm(idx(i)).brid
                if isnan(svdata(mdx).geo_prn_time) || ...
                     svdata(mdx).mt47alm(idx(i)).time > svdata(mdx).geo_prn_time
                    svdata(mdx).geo_prn = svdata(mdx).mt47alm(idx(i)).prn;
                    svdata(mdx).geo_spid = svdata(mdx).mt47alm(idx(i)).spid;
                    svdata(mdx).geo_prn_time = svdata(mdx).mt47alm(idx(i)).time;
                end
            end
        end
    end  
end

%load position and degradation factor into the other streams data
%assumes that the masks are all the same and in the same order as the geo data stream
for mdx = 1:ngeos 
    idx = setdiff(1:ngeos, mdx);
    for i = idx
        svdata(mdx).geo_xyzb(i,:) = svdata(i).geo_xyzb(i,:);
    end
end