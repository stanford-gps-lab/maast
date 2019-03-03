function sats = fromYuma(filename)
% fromYuma  reads in a yuma almanac file and creates a list of Satellites
% based on the almanac parameters.
%   sats = maast.tools.Satellite.fromYuma(filename) creates the satellite
%   list from the yuma almanac file given in filename.  Filename can be
%   either a single filename of a cell array of filenames.  If the input is
%   a cell array of length N, the sats output will be a cell array of
%   length N of satellite lists.
%
% See Also: maast.tools.Satellite.fromAlmMatrix, maast.tools.Satellite

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details.
%   Questions and comments should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% error checking on inputs
if nargin < 1
	error('you must specify a filename');
end

% if it's a cell array, loop through each file and create the output
% accordingly
if iscell(filename)
    
    % loop through all the files
    sats = cell(1, length(filename));
    for fi = 1:length(filename)
        % parse the file
        [prn, e, toa, inc, rora, sqrta, raan, w, m0, af0, af1] = parseFile(filename{fi});

        % create the satellite list and add to the output array
        sats{fi} = maast.tools.Satellite(prn, e, toa, inc, rora, ...
            sqrta, raan, w, m0, af0, af1);
    end
    
else

    % parse the file
    [prn, e, toa, inc, rora, sqrta, raan, w, m0, af0, af1] = parseFile(filename);
    
    % create the satellite list
    sats = maast.tools.Satellite(prn, e, toa, inc, rora, ...
        sqrta, raan, w, m0, af0, af1);
end



function [prn, e, toa, inc, rora, sqrta, raan, w, m0, af0, af1] = parseFile(filename)
% parseFile     helper function to parse all the almanac data in a file

% open the file
fid = fopen(filename);

% preallocate arrays to a larger value that will need
[prn, e, toa, inc, rora, sqrta, raan, w, m0, af0, af1] = deal(zeros(64,1));

% TODO: if let the class properties be private instead of immutable, can
% directly create the satellite list here

% loop through the lines in the file
ind = 1;
while fgets(fid) ~= -1  % NOTE: the first list is not needed
    
    % populate all the data into the lists
    prn(ind) = readLineParameter(fgets(fid));   % prn number
    fgets(fid);     % read the health line (not used)
    e(ind) = readLineParameter(fgets(fid));     % eccentricity
    toa(ind) = readLineParameter(fgets(fid));   % time of applicability
	inc(ind) = readLineParameter(fgets(fid));   % inclination angle
	rora(ind) = readLineParameter(fgets(fid));  % rate of right ascention
	sqrta(ind) = readLineParameter(fgets(fid)); % square root of semi-major axis
	raan(ind) = readLineParameter(fgets(fid));  % right ascention
	w(ind) = readLineParameter(fgets(fid));     % argument of perigee
	m0(ind) = readLineParameter(fgets(fid));    % mean anomaly
	af0(ind) = readLineParameter(fgets(fid));   % Af0
	af1(ind) = readLineParameter(fgets(fid));   % Af1
    fgets(fid);     % week number (not used currently)
    fgets(fid);     % empty line

    % increment the index
    ind = ind + 1;
end

% trim all the matricies
% all preallocated larger than needed, so trim them
prn = prn(1:ind-1);
e = e(1:ind-1);
toa = toa(1:ind-1);
inc = inc(1:ind-1);
rora = rora(1:ind-1);
sqrta = sqrta(1:ind-1);
raan = raan(1:ind-1);
w = w(1:ind-1);
m0 = m0(1:ind-1);
af0 = af0(1:ind-1);
af1 = af1(1:ind-1);

% close the file
fclose(fid);



function val = readLineParameter(str)
% readLineParameter     read the value of the parameter from this line
%   val = readLineParameter(str) retrieves the value of the parameter (as a
%   number) for the provided line from an almanac file.

% an almanac file has the parameter starting at index 28 on each line
val = str2num(str(28:end));
