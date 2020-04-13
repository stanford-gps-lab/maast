function alm_param=read_tle(filename)
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
%FUNCTION ALM_PARAM=READ_TLE(FILENAME) reads in a two-line element set file
%  and stores the results in a matlab matrix, alm_param.
%   FILENAME contains the name of the file with TLE almanac parameters
%   ALM_PARAM is a matrix whose rows correspond to satellites with columns:
%    1    2    3    4     5    6       7       8          9     10  11 
%   PRN ECCEN TOA INCLIN RORA SQRT_A R_ACEN ARG_PERIG MEAN_ANOM AF0 AF1
%    -    -   sec  rad    r/s m^(1/2) rad     rad        rad     s  s/s
%
% NOTE: RORA, AF0, and AF1 are not filled in for TLE
%
% see also ALM2SATPOSVEL

%based on yuma code by Jon Nichols and TLE code by Tyler Reid
%last modification January 15, 2013 Todd Walter

global CONST_MU_E CONST_OMEGA_E

alm_param=zeros(212,11);

if nargin < 1
  error('you must specify a filename or week number')
end
 
i=1;
while i<=size(filename,2)
    if iscell(filename)
        fid=fopen(filename{i});
        if fid==-1
            error(['no such file ' filename{i}]);
        end       
    else
        fid=fopen(filename);
        i = size(filename,2);
        if fid==-1
            error(['no such file ' filename]);
        end    
    end

  
    txt_data = textscan(fid,'%s %s %s %s %s %s %s %s %s');  
    
    % find the total number of satellites in the file
    numSV = length(txt_data{1})/3;
    
    line_num = 1;
    
    for idx = 1:numSV  
        
        %identify satellite type and PRN
        sat_type = txt_data{1}(line_num);        
        if strcmp(sat_type,'GPS') == 1
            tmp = txt_data{4}(line_num);
            prn = str2double(tmp{1}(1:2));
            svn = prn;
            
        elseif strcmp(sat_type,'COSMOS') == 1
                tmp = txt_data{3}(line_num);
                svn = str2double(tmp{1}(2:4));
                prn = svn - 700 +37;
                
        elseif strcmp(sat_type,'BEIDOU') == 1
            tmp = txt_data{2}(line_num);
            if tmp{1}(1) == 'G'
                svn = str2double(tmp{1}(2:end))+300;
                prn = svn - 300 +111;
            elseif tmp{1}(1) == 'M'
                svn = str2double(tmp{1}(2:end))+400;
                prn = svn - 400 +173;
            elseif tmp{1}(1) == 'I'
                tmp = txt_data{3}(line_num);
                svn = str2double(tmp{1})+500;
                prn = svn - 500 +158;
            else
                svn = [];
                prn = []; 
            end
                    
        end

        if ~isempty(svn)
            alm_param(prn,1) = svn;

            %get eccentricity
            alm_param(prn,2) = str2double(txt_data{1,5}{line_num+2})*1e-7;

            %get time of applicability
            tmp = txt_data{1,4}{line_num+1};                % date [yyddd.dddd]

            % compute the UTC date / time
            yy                = str2double(tmp(1:2));
            yyyy              = 2000 + yy;
            start             = datenum([yyyy-1 12 31 00 00 00]); % this is day 0 for tle
            secs              = (str2double(tmp(3:length(tmp))))*24*3600;
            date1             = datevec(addtodate(start,floor(secs),'second'));
            remainder         = [0 0 0 0 0 mod(secs,1)];
            UTC_date          = date1+remainder;

            %tmp = str2double(tmp(3:length(tmp)))*24*3600; % seconds of year
            %alm_param(prn,3) = tmp;        

            % convert UTC to GPS time (absolute seconds since 1980)
            [GPSweek,GPSsec] = utc2gps(UTC_date);       
            alm_param(prn,3) = GPSsec+GPSweek*3600*7*24;

            %get inclination angle
            alm_param(prn,4) = str2double(txt_data{1,3}{line_num+2})*pi/180;

            %get square root of semi-major axis
            tmp = str2double(txt_data{1,8}{line_num+2});      % [rev/day]
            tmp = tmp*2*pi/24/60/60;                          % [rad/s]
            alm_param(prn,6) = (CONST_MU_E / tmp^2 )^(1/6);   % [m]

            %get right ascention (RAAN)
            raan = str2double(txt_data{1,4}{line_num+2})*pi/180;

            %get Longitude of the ascending node (LAAN)
            gmst = utc2gmst(UTC_date);   % sidereal time [rad]
            alm_param(prn,7) = raan-gmst+CONST_OMEGA_E*mod(alm_param(prn,3),604800); % [rad]

            %get argument of perigee
            alm_param(prn,8) = str2double(txt_data{1,6}{line_num+2})*pi/180;

            %get mean anomaly
            alm_param(prn,9) = str2double(txt_data{1,7}{line_num+2})*pi/180;
        end
        line_num = line_num + 3;

    end;

    fclose(fid);
    i = i+1;
end

%save only nonzero rows
i = find(alm_param(:,1));
alm_param = alm_param(i,:);

% first_day = floor(min(alm_param(:,3))/(24*3600))*24*3600;
% alm_param(:,3) = alm_param(:,3) - first_day;
