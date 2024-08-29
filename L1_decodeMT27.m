function svdata = L1_decodeMT27(time, msg, svdata)
%*************************************************************************
%*     Copyright c 2024 The board of trustees of the Leland Stanford     *
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
%modified 27 August, 2024 by Todd Walter

% copy older messages over
svdata.mt27(2:end) = svdata.mt27(1:(end-1));

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
    svdata.mt27(1).msg_poly{sdx + mdx, 1} = [iods n_mt_27_msgs (mdx/5+1) priority dudrei_in dudrei_out];
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
    svdata.mt27(1).time(sdx + mdx) = time;

    if issquare
        svdata.mt27(1).msg_poly{sdx + mdx, 2} = [[lat1 lon1]; [lat2 lon1]; ...
                             [lat2 lon2]; [lat1 lon2]; [lat1 lon1];];
    else
        svdata.mt27(1).msg_poly{sdx + mdx, 2} = [[lat1 lon1]; [lat2 lon1]; ...
                             [lat2 lon2]; [lat1 lon1];];
    end
end

