function [week,sec] = utc2gps(UTC_date)
%% DESCRIPTION
%
%  This function takes a gps time based date and converts it into its
%  equivalent utc date by finding the appropriate number of leap seconds to
%  subtract from the gps date.
%
%% OUTPUT
%
%  week = GPS week number
%
%  sec  = second of GPS week (0<t<24*7*3600 = 604800)
%
%% INPUTS
%
%  UTC_date = UTC date vector in the form [yyyy mm dd HH MM SS.FFF]
%
%% IMPLEMENTATION

% define the 1st epoch, Jan 6 1980 00:00:00 
epoch1 = datenum([1980 01 06 00 00 00]);

% UTC serial date
epoch = datenum(UTC_date);

% determine the number of leap seconds which correspond to the given date
leap_dates = [...
    'Jan 6 1980'
    'Jul 1 1981'
    'Jul 1 1982'
    'Jul 1 1983'
    'Jul 1 1985'
    'Jan 1 1988'
    'Jan 1 1990'
    'Jan 1 1991'
    'Jul 1 1992'
    'Jul 1 1993'
    'Jul 1 1994'
    'Jan 1 1996'
    'Jul 1 1997'
    'Jan 1 1999'
    'Jan 1 2006'
    'Jan 1 2009'
    'Jul 1 2012'
    ];

% compute leap dates to serial date form
serial_leap = datenum(leap_dates);

% find number of leap seconds corresponding to UTC date and subtract off
leapsec = 0;
for i = 2:length(serial_leap)
    if epoch >= serial_leap(i)
        leapsec = leapsec + 1;
    end
end

% find total number of seconds from 1st epoch in GPS time
total_secs = (epoch-epoch1)*24*3600+leapsec;

% find GPS week
week = floor(total_secs/24/3600/7);

% find GPS second of week
sec = round(total_secs-week*7*3600*24);
