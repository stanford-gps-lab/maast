function usrs = createUserGrid(polyfile, latstep, lonstep)
% createUserGrid    create a regular grid of users within a given polygon
%
%   usrs = maast.tools.User.createUserGrid(polyfile, latstep, lonstep)
%   creates a list of users that lie within a box that bounds the polygon
%   specified in the polyfile.  The grid latitude and longitude step sizes
%   as specified as latstep and lonstep, respectively.
%
%

% load in the polygon file
poly = load(polyfile);

% define the bounds for the grid
latmin = max(floor(min(poly(:,1))/latstep)*latstep, -90);
latmax = min(ceil(max(poly(:,1))/latstep)*latstep, 90-latstep);
lonmin = floor(min(poly(:,2))/lonstep) * lonstep;
lonmax = ceil(max(poly(:,2))/lonstep) * lonstep;

% create the lat/lon points that define the grid
gridLat = latmin:latstep:latmax;
gridLon = lonmin:lonstep:lonmax;
[latmesh, lonmesh] = meshgrid(gridLat, gridLon);
posllh = [latmesh(:), lonmesh(:), zeros(length(latmesh(:)), 1)];

% create the users (the IDs will just be sequential) and flag whether or
% not they are within the polygon
usrs = maast.tools.User(posllh, 'Polygon', poly);