function obj = createUserGrid(varargin)
% createUserGrid    create a grid of SBAS users.
%
%   maast.SBASUserGrid.createUserGrid(varargin) creates a grid of SBAS
%   users with parameters given in varargin.
%
%   varargin:
%   -----
%   'NumUsers' - numerical value that states how many users there are in
%   the specified grid. NOTICE: The number of users that are generated
%   are not necessarily equal to the value NumUsers. This is done in order
%   to evenly distribute users throughout the grid space. If this is the
%   only input, the grid will be assumed over the entire earth.
%   -----
%   'GridBoundary' - array of length 4 specifying the boundary of the user
%   grid. Example: [minLat, maxLat, minLon, maxLon] in [deg]. Default value
%   of 'GridBoundary' is [-90, 90, 0, 360].
%   -----
%   'GridStep' - array of length 1 or 2. Length 1 specifies the same grid
%   step size over lattitude and longitude. Length 2 specifies different
%   lattitude and longitude spacings. Examples: (1) [latStep, lonStep] in
%   [deg], (2) [gridStep] in [deg]. If 'GridStep' is not specified, then it
%   is calculated from other arguments and is assumed to be the same for
%   lattitude and longitude.
%   -----
%   'PolygonFile' - a polygon file that is used to specify a geographic
%   boundary. This boundary is used to determine whether created users are
%   within the geographic boundary, and in some cases defines the
%   'GridBoundary' as shown in an example below.
%   -----
%   'LLHFile' - a file containing LLH positions of all users. These are
%   then directly used to create a user grid. If the LLH positions of a
%   previous UserGrid is being used, these files are typically denoted as
%   *.userLocation.
%
%   Examples: The following are a number of common use cases for this
%   method.
%   ----- maast.SBASUserGrid.createUserGrid('NumUsers', numUsers)
%   This implementation creates a grid of users over the entire surface of
%   the globe and evenly distributes them.
%   ----- maast.SBASUserGrid.createUserGrid('NumUsers', numUsers,
%   'GridBoundary', [latMin, latMax, lonMin, lonMax])
%   This implementation creates a grid of users over the surface of the
%   globe specified by the 'GridBoundary'.
%   ----- maast.SBASUserGrid.createUserGrid('NumUsers', numUsers,
%   'PolygonFile', polyfile)
%   This implementation creates a 'GridBoundary' from the input
%   'PolygonFile' file and evenly distributes the number of specified users
%   throughout the geographic boundary. The users created in this scenario
%   will also have the property 'InBound' determined from the same
%   polyfile.
%   ----- maast.SBASUserGrid.createUserGrid('PolygonFile', polyfile,
%   'GridStep', [latStep, lonStep])
%   This implementation creates a 'GridBoundary' using the specified
%   polyfile and distributes the users throughout the geographic region
%   using the specified 'GridStep'.
%   ----- maast.SBASUserGrid.createUserGrid('GridStep',
%   [latStep, lonStep])
%   This implementation distributes users throughout the globe with spacing
%   specified by [latStep, lonStep].
%   ----- maast.SBASUserGrid.createUserGrid('GridStep',
%   [latStep, lonStep], 'GridBoundary', [latMin, latMax, lonMin, lonMax])
%   This implementation distributes throughout the geographic region
%   specified by 'GridBoundary' using the specified 'GridStep'.
%   ----- maast.SBASUserGrid.createUserGrid('LLHFile', LLHFilename)
%   This implementation generates a user grid based on the LLH provided in
%   LLHFilename.
%   ----- maast.SBASUserGrid.createUserGrid('LLHFile', LLHFilename,
%   'PolygonFile', polyfile)
%   This implementation generates a user grid based on the LLH provided in
%   LLHFilename. It also incorporates the polygon saved in polyfile.
%
%   See also: maast.SBASUserGrid, maasta.SBASUser,
%   sgt.UserGrid.createUserGrid

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Create a user grid
userGrid = sgt.UserGrid.createUserGrid(varargin{:});

% Create an SBAS user grid
obj = maast.SBASUserGrid.fromsgtUserGrid(userGrid);

end