function get_sbas_broadcast_from_rinex()

%Read in the last 10 minutes of the previous day's file and concatenate it
%with the current day's data.  Find all available geo PRNs and combine into
%a single matlab file containing:
% 1. PRN #
% 2. week #
% 3. day #
% 4. date (year, month, day)
% 5. time stamps for first bits of the message (abolute GPS seconds WN*7*86400 + tow
% 6. messages as 32 array of uint8's
% 7. Band (L1 or L5) (L5 not yet available)


year = 2020;
doy = 1;

directoryname = '~/Desktop/Ephemeris/rinex/';

sbas.n_geos = 0;

for pdx = 120:158
    
    %see if a file exists for the PRN #
    filename = sprintf('%s%4d/%03d/M%3d%03d0.%02db', directoryname, ...
                        year, doy, pdx, doy, mod(year,100)); 
    if exist(filename, 'file')
 
        % read in day's data
        [msg, time, prn, band] = read_sbas_rinex(filename);  

        %check that data is valid
        if ~isempty(msg) && ~isempty(time) && prn == pdx && strcmp(band, 'L1')
            sbas.n_geos = sbas.n_geos + 1;
            sbas.prns(sbas.n_geos) = prn;
            sbas.week(sbas.n_geos) = floor(time(1)/604800.0);
            sbas.doy(sbas.n_geos) = doy;
            [x, y, z] = jd2cal(gps2jd(sbas.week(sbas.n_geos),mod(time(1), 604800)));
            sbas.date(sbas.n_geos,:) = [x y z];
            sbas.band(sbas.n_geos,:) = band;

            %see if a file exists for the day before
            if doy > 1
                dayb4fname = sprintf('%s%4d/%03d/M%3d%03d0.%02db', directoryname, ...
                            year, doy-1, pdx, doy-1, mod(year,100));
            else
                %make sure it works for leap years
                [tmp_doy, tmp_year] = jd2doy(doy2jd(year, doy-1));
                
                dayb4fname = sprintf('%s%4d/%03d/M%3d%03d0.%02db', directoryname, ...
                            tmp_year, tmp_doy, pdx, tmp_doy, mod(tmp_year,100));
            end

            if exist(dayb4fname, 'file')
                
                % read in day before's data
                [b4msg, b4time, b4prn, b4band] = read_sbas_rinex(dayb4fname);
                
                idx = mod(b4time, 86400) > 85799; %within ten minutes of the end of the day    
                
                %check that data is valid
                if ~isempty(msg) && any(idx) && b4prn == pdx && strcmp(b4band, 'L1')
                    
                    %put data before current day's data
                    msg = [b4msg(idx,:); msg];
                    time = [b4time(idx,:); time]; 
                    clearvars b4msg b4time                    
                end
            end
            sbas_msgs{sbas.n_geos} = msg;
            sbas_msg_time{sbas.n_geos} = time;
            clearvars msg time
        end
    end
end

eval(sprintf('save sbas_messages_%4d_%03d sbas sbas_msgs sbas_msg_time', year, doy));
