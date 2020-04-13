function geo_prn = RINEX_parse_sbas_hdr(file)

% SYNTAX:
%   [geo_prn] = RINEX_parse_sbas_hdr(file);
%
% INPUT:
%   file = pointer to RINEX observation file
%
% OUTPUT:
%   PRN of the GEO file
%
% DESCRIPTION:
%   RINEX observation file header analysis.

%----------------------------------------------------------------------------------------------
%                           goGPS v0.4.3
%
% Copyright (C) Kai Borre
% Kai Borre 09-23-97
%
% Adapted by Mirko Reguzzoni, Eugenio Realini, 2009
% Portions of code contributed by Damiano Triglione, 2012
% Adapted from RINEX_parse_hdr to read SBAS files produced by CNES by Todd Walter 2020
%----------------------------------------------------------------------------------------------


%parse first line
line = fgetl(file);

%check if the end of the header or the end of the file has been reached
while ~contains(line,'END OF HEADER') && ischar(line)
    %NOTE: ischar is better than checking if line is the number -1.
    
    if contains(line,'SBAS consolidation file for PRN')
        k = strfind(line, 'PRN');
        geo_prn = str2double(line((1:3)+k+3));
    end

    %parse next line
    line = fgetl(file);
end
