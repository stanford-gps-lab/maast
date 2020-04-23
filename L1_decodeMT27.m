function svdata = L1_decodeMT27(time, msg, svdata)
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
% Decodes Message Type 27 
%   per DO-229E
%
% SEE ALSO: L1_decode_messages

%created 13 April, 2020 by Todd Walter

global MOPS_MT27_PATIMEOUT

idx = 15;
iods = bin2dec(msg(idx:(idx+2))); %IODS
idx = idx + 3;
n_mt_27_msgs = bin2dec(msg(idx:(idx+2))) + 1; %Number of service messages
idx = idx + 3;
mdx = 5*bin2dec(msg(idx:(idx+2))); %Service message number converted to region counter
idx = idx + 3;
sdx_max = bin2dec(msg(idx:(idx+2))); %Number of regions in message
idx = idx + 3;
priority = bin2dec(msg(idx:(idx+1))); %priority code
idx = idx + 2;
dudrei_in = bin2dec(msg(idx:(idx+3))); %delta_UDREI inside
idx = idx + 4;
dudrei_out = bin2dec(msg(idx:(idx+3))); %delta_UDREI outside
idx = idx + 4;

for sdx = 1:sdx_max
                                        %IODS  # of MT27s    MT27#  
    svdata.mt27_msg_poly{sdx + mdx, 1} = [iods n_mt_27_msgs (mdx/5+1) priority dudrei_in dudrei_out];
    lat1 = twos2dec(msg(idx:(idx+7))); %Coordinate 1 Latitude
    idx = idx + 8;        
    lon1 = twos2dec(msg(idx:(idx+8))); %Coordinate 1 Longitude
    idx = idx + 9;
    lat2 = twos2dec(msg(idx:(idx+7))); %Coordinate 2 Latitude
    idx = idx + 8;        
    lon2 = twos2dec(msg(idx:(idx+8))); %Coordinate 2 Longitude
    idx = idx + 9;
    issquare = bin2dec(msg(idx));         %Region Shape
    idx = idx + 1;
    svdata.mt27_time(sdx + mdx) = time;

    if issquare
        svdata.mt27_msg_poly{sdx + mdx, 2} = [[lat1 lon1]; [lat2 lon1]; ...
                             [lat2 lon2]; [lat1 lon2]; [lat1 lon1];];
    else
        svdata.mt27_msg_poly{sdx + mdx, 2} = [[lat1 lon1]; [lat2 lon1]; ...
                             [lat2 lon2]; [lat1 lon1];];
    end
end

%check for complete MT 27 set

%initialize final polygon data
svdata.mt27_polygon = [];

%remove messages that have timed out
dt27 = time - svdata.mt27_time;
idx = dt27 > MOPS_MT27_PATIMEOUT;
if any(idx)
    svdata.mt27_msg_poly(idx,:) = [];
    svdata.mt27_time(idx) = [];
end
%make sure some data remains
if ~all(idx)
    dt27 = time - svdata.mt27_time;
    % check for different IODSs, # of messages, and outside d_udre value
    mt27data = cell2mat(svdata.mt27_msg_poly(:,1));
    mt27sets = unique(mt27data(:,[1 2 6]),'rows');

    % loop over all sets and check if all polynomials are present
    for sdx = 1:size(mt27sets,1)
        idx = mt27data(:,1) == mt27sets(sdx,1) & ...
               mt27data(:,2) == mt27sets(sdx,2);
        eval_data = mt27data(idx,:);
        % have all messages been received
        if isequal(unique(eval_data(:,3)), 1:eval_data(1,2))
            %check for existing complet set
            if isempty(svdata.mt27_polygon)
                svdata.mt27_polygon = svdata.mt27_msg_poly(idx,:);
                svdata.mt27_polytime = max(svdata.mt27_time(idx));
                mean_age = mean(dt27(idx));
            elseif mean(dt27(idx)) < mean_age
                svdata.mt27_polygon = svdata.mt27_msg_poly(idx,:);
                svdata.mt27_polytime = max(svdata.mt27_time(idx));
                mean_age = mean(dt27(idx));
            end
        end
    end
end
