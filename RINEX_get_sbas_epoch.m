function [time, datee, prn, band, tow] = RINEX_get_sbas_epoch(fid)

% SYNTAX:
%   [time, datee, num_sat, sat, sat_types, tow] = RINEX_get_epoch(fid);
%
% INPUT:
%   fid = pointer to the observation RINEX file
%
% OUTPUT:
%   time = observation GPS time (continuous)
%   datee = date (year,month,day,hour,minute,second)
%   num_sat = number of available satellites (NOTE: RINEX v3.xx does not output 'sat' and 'sat_types')
%   sat = list of all visible satellites
%   sat_types = ordered list of satellite types ('G' = GPS, 'R' = GLONASS, 'S' = SBAS)
%   tow = observation GPS time (seconds-of-week)
%
% DESCRIPTION:
%   Scan the first line of each epoch (RINEX) and return
%   the information it contains.

%----------------------------------------------------------------------------------------------
%                           goGPS v0.4.3
%
% Copyright (C) 2009-2014 Mirko Reguzzoni, Eugenio Realini.
%
% Portions of code contributed by Damiano Triglione (2012).
% Portions of code contributed by Andrea Gatti (2013).
%
% Partially based on FEPOCH_0.M (EASY suite) by Kai Borre
%----------------------------------------------------------------------------------------------
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%----------------------------------------------------------------------------------------------

%variable initialization
time = NaN;
prn = [];
band = [];
datee=[NaN NaN NaN NaN NaN NaN]; %Preallocation not useful (see last line of code)
eof = 0;
tow = NaN;
if (nargout > 3)
    datee_RequestedInOutputFlag = true;
else
    datee_RequestedInOutputFlag = false;
end% if

%search data
while (eof==0)
    %read the string
    lin = fgets(fid);
        
    %check if it is a string that should be analyzed
    if strcmp(lin(1),'1')
        %get prn nd confirm that it is a geo PRN #
        prn = str2double(lin(1:3));
        if prn < 120 || prn > 158
            error(['Invalid prn ' lin(1:3)])
        end            

        %save time information
        data   = textscan(lin(5:23),'%f%f%f%f%f%f');
        year   = data{1};
        month  = data{2};
        day    = data{3};
        hour   = data{4};
        minute = data{5};
        second = data{6};

        if length([year month day hour minute second]) ~= 6
            error('Invalid date')
        end

        %computation of the GPS time in weeks and seconds of week
        if year > 80
            year = year+1900;
        else
            year = year+2000;
        end

        [week,sowDay] = jd2gps(cal2jd(year,month,day));
        tow = sowDay+60*60*hour+60*minute+second;
        time = week*86400*7+tow;

        %Band L1 or L5
        band = lin(26:27);

        eof = 1;

    end
end

if datee_RequestedInOutputFlag
    datee = [year month day hour minute second];
end %if
