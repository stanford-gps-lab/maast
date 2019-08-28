function obj = createReferenceStationGrid(varargin)
% createReferenceStationGrid    create a grid of SBAS reference stations.
%
%   maast.SBASReferenceStationGrid.createUserGrid(varargin) creates a grid 
%   of SBAS reference stations with parameters given in varargin.
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
%   previous UserGrid is being used.
%
%   Examples: The following are a number of common use cases for this
%   method.
%   ----- maast.SBASReferenceStationGrid.createUserGrid('NumUsers', numUsers)
%   This implementation creates a grid of users over the entire surface of
%   the globe and evenly distributes them.
%   ----- maast.SBASReferenceStationGrid.createUserGrid('NumUsers', numUsers,
%   'GridBoundary', [latMin, latMax, lonMin, lonMax])
%   This implementation creates a grid of users over the surface of the
%   globe specified by the 'GridBoundary'.
%   ----- maast.SBASReferenceStationGrid.createUserGrid('NumUsers', numUsers,
%   'PolygonFile', polyfile)
%   This implementation creates a 'GridBoundary' from the input
%   'PolygonFile' file and evenly distributes the number of specified users
%   throughout the geographic boundary. The users created in this scenario
%   will also have the property 'InBound' determined from the same
%   polyfile.
%   ----- maast.SBASReferenceStationGrid.createUserGrid('PolygonFile', polyfile,
%   'GridStep', [latStep, lonStep])
%   This implementation creates a 'GridBoundary' using the specified
%   polyfile and distributes the users throughout the geographic region
%   using the specified 'GridStep'.
%   ----- maast.SBASReferenceStationGrid.createUserGrid('GridStep',
%   [latStep, lonStep])
%   This implementation distributes users throughout the globe with spacing
%   specified by [latStep, lonStep].
%   ----- maast.SBASReferenceStationGrid.createUserGrid('GridStep',
%   [latStep, lonStep], 'GridBoundary', [latMin, latMax, lonMin, lonMax])
%   This implementation distributes throughout the geographic region
%   specified by 'GridBoundary' using the specified 'GridStep'.
%   ----- maast.SBASReferenceStationGrid.createUserGrid('LLHFile', LLHFilename)
%   This implementation generates a user grid based on the LLH provided in
%   LLHFilename.
%   ----- maast.SBASReferenceStationGrid.createUserGrid('LLHFile', LLHFilename,
%   'PolygonFile', polyfile)
%   This implementation generates a user grid based on the LLH provided in
%   LLHFilename. It also incorporates the polygon saved in polyfile.
%
%   See also: maast.SBASReferenceStationGrid, maasta.SBASReferenceStation,
%   sgt.UserGrid.createUserGrid

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% handle the null argument
if nargin < 1
    obj = maast.SBASReferenceStationGrid();
    return;
end

% Parse inputs
res = parseInput(varargin{:});
numFields = numel(fieldnames(res));

% Generates an array where 1 represents a field that is populated
inputLogic = [(~isempty(res.NumUsers)), (~isempty(res.PolygonFile)),...
    (~isempty(res.GridStep)), (~isempty(res.GridBoundary)),...
    (~isempty(res.LLHFile))];
% [(1)NumUsers, (2)PolygonFile, (3)GridStep, (4)GridBoundary, (5)LLHFile]

% Conditional cases for different uses of the method
if (sum(inputLogic == [1 0 0 0 0]) == numFields)  % NumUsers
    sqrtNumUsers = sqrt(res.NumUsers);
    % define the bounds for the grid
    latMin = -90;
    latMax = 90;
    lonMin = 0;
    lonMax = 360;
    
    % Define latStep and lonStep
    latStep = ceil((latMax - latMin)/sqrtNumUsers);
    lonStep = ceil((lonMax - lonMin)/sqrtNumUsers);
    
    % create the lat/lon points that define the grid
    gridLat = latMin:latStep:latMax;
    gridLon = lonMin:lonStep:lonMax;
    [latMesh, lonMesh] = meshgrid(gridLat, gridLon);
    posLLH = [latMesh(:), lonMesh(:), zeros(length(latMesh(:)), 1)];
    % Check for redundant users
    posLLH = checkRedundantUsers(posLLH);
    % Shift longitude
    posLLH(:,2) = sgt.tools.lonShift(posLLH(:,2));
    
    % create the users (the IDs will just be sequential)
    obj = maast.SBASReferenceStationGrid(posLLH);
    return;
    
elseif (sum(inputLogic == [1 0 0 1 0]) == numFields)  % NumUsers + GridBoundary
    sqrtNumUsers = sqrt(res.NumUsers);
    % define the bounds for the grid
    latMin = res.GridBoundary(1);
    latMax = res.GridBoundary(2);
    lonMin = res.GridBoundary(3);
    lonMax = res.GridBoundary(4);
    
    % Define latStep and lonStep
    latStep = ceil((latMax - latMin)/sqrtNumUsers);
    lonStep = ceil((lonMax - lonMin)/sqrtNumUsers);
    
    % create the lat/lon points that define the grid
    gridLat = latMin:latStep:latMax;
    gridLon = lonMin:lonStep:lonMax;
    [latMesh, lonMesh] = meshgrid(gridLat, gridLon);
    posLLH = [latMesh(:), lonMesh(:), zeros(length(latMesh(:)), 1)];
    % Check for redundant users
    posLLH = checkRedundantUsers(posLLH);
    % Shift longitude
    posLLH(:,2) = sgt.tools.lonShift(posLLH(:,2));
    
    % create the users (the IDs will just be sequential)
    obj = maast.SBASReferenceStationGrid(posLLH);
    return;
    
elseif (sum(inputLogic == [1 1 0 0 0]) == numFields)  % NumUsers + PolygonFile
    sqrtNumUsers = sqrt(res.NumUsers);
    
    % load in the polygon file
    poly = load(res.PolygonFile);
    
    % define the bounds for the grid
    latMin = max(floor(min(poly(:,1))), -90);
    latMax = min(ceil(max(poly(:,1))), 90);
    lonMin = floor(min(poly(:,2)));
    lonMax = ceil(max(poly(:,2)));
    
    % Define latStep and lonStep
    latStep = ceil((latMax - latMin)/sqrtNumUsers);
    lonStep = ceil((lonMax - lonMin)/sqrtNumUsers);
    
    % create the lat/lon points that define the grid
    gridLat = latMin:latStep:latMax;
    gridLon = lonMin:lonStep:lonMax;
    [latMesh, lonMesh] = meshgrid(gridLat, gridLon);
    posLLH = [latMesh(:), lonMesh(:), zeros(length(latMesh(:)), 1)];
    % Check for redundant users
    posLLH = checkRedundantUsers(posLLH);
    % Shift longitude
    posLLH(:,2) = sgt.tools.lonShift(posLLH(:,2));
    
    % create the users (the IDs will just be sequential)
    obj = maast.SBASReferenceStationGrid(posLLH, 'PolygonFile', res.PolygonFile);
    return;
    
elseif (sum(inputLogic == [0 1 1 0 0]) == numFields)  % PolygonFile + GridStep
    % load in the polygon file
    poly = load(res.PolygonFile);
    
    % Define latStep and lonStep
    latStep = res.GridStep(1);
    if (length(res.GridStep) == 1)
        lonStep = latStep;
    else
        lonStep = res.GridStep(2);
    end
    
    % define the bounds for the grid
    latMin = max(floor(min(poly(:,1))/latStep)*latStep, -90);
    latMax = min(ceil(max(poly(:,1))/latStep)*latStep, 90-latStep);
    lonMin = floor(min(poly(:,2))/lonStep) * lonStep;
    lonMax = ceil(max(poly(:,2))/lonStep) * lonStep;
    
    % create the lat/lon points that define the grid
    gridLat = latMin:latStep:latMax;
    gridLon = lonMin:lonStep:lonMax;
    [latMesh, lonMesh] = meshgrid(gridLat, gridLon);
    posLLH = [latMesh(:), lonMesh(:), zeros(length(latMesh(:)), 1)];
    % Check for redundant users
    posLLH = checkRedundantUsers(posLLH);
    % Shift longitude
    posLLH(:,2) = sgt.tools.lonShift(posLLH(:,2));
    
    % create the users (the IDs will just be sequential) and flag whether or
    % not they are within the polygon
    obj = maast.SBASReferenceStationGrid(posLLH, 'PolygonFile', res.PolygonFile);
    return;
    
elseif (sum(inputLogic == [0 0 1 0 0]) == numFields)  % GridStep
    
    % Define latStep and lonStep
    latStep = res.GridStep(1);
    if (length(res.GridStep) == 1)
        lonStep = latStep;
    else
        lonStep = res.GridStep(2);
    end
    
    % define the bounds for the grid
    latMin = -90;
    latMax = 90;
    lonMin = 0;
    lonMax = 360;
    
    % create the lat/lon points that define the grid
    gridLat = latMin:latStep:latMax;
    gridLon = lonMin:lonStep:lonMax;
    [latMesh, lonMesh] = meshgrid(gridLat, gridLon);
    posLLH = [latMesh(:), lonMesh(:), zeros(length(latMesh(:)), 1)];
    % Check for redundant users
    posLLH = checkRedundantUsers(posLLH);
    % Shift longitude
    posLLH(:,2) = sgt.tools.lonShift(posLLH(:,2));
    
    % create the users (the IDs will just be sequential)
    obj = maast.SBASReferenceStationGrid(posLLH);
    return;
    
elseif (sum(inputLogic == [0 0 1 1 0]) == numFields)  % GridStep + GridBoundary
    % Define latStep and lonStep
    latStep = res.GridStep(1);
    if (length(res.GridStep) == 1)
        lonStep = latStep;
    else
        lonStep = res.GridStep(2);
    end
    
    % define the bounds for the grid
    latMin = res.GridBoundary(1);
    latMax = res.GridBoundary(2);
    lonMin = res.GridBoundary(3);
    lonMax = res.GridBoundary(4);
    
    % create the lat/lon points that define the grid
    gridLat = latMin:latStep:latMax;
    gridLon = lonMin:lonStep:lonMax;
    [latMesh, lonMesh] = meshgrid(gridLat, gridLon);
    posLLH = [latMesh(:), lonMesh(:), zeros(length(latMesh(:)), 1)];
    % Check for redundant users
    posLLH = checkRedundantUsers(posLLH);
    % Shift longitude
    posLLH(:,2) = sgt.tools.lonShift(posLLH(:,2));
    
    % create the users (the IDs will just be sequential)
    obj = maast.SBASReferenceStationGrid(posLLH);
    return;
    
elseif (sum(inputLogic == [0 0 0 0 1]) == numFields)    % LLHFile
    % Load LLHFile
    temp = load(res.LLHFile);
    posLLH = temp(:,2:4);
    % Shift longitude
    posLLH(:,2) = sgt.tools.lonShift(posLLH(:,2));
    
    % Create the users (the IDs will just be sequential)
    obj = maast.SBASReferenceStationGrid(posLLH);
    return;
    
elseif (sum(inputLogic == [0 1 0 0 1]) == numFields)    % PolygonFile + LLHFile
    % Load LLHFile
    temp = load(res.LLHFile);
    posLLH = temp(:,2:4);
    % Shift longitude
    posLLH(:,2) = sgt.tools.lonShift(posLLH(:,2));
    
    % create the users (the IDs will just be sequential) and flag whether or
    % not they are within the polygon
    obj = maast.SBASReferenceStationGrid(posLLH, 'PolygonFile', res.PolygonFile);
    return;
    
else
    error('Invalid inputs. Check input arguments.')
end
end

% Parse varargin
function res = parseInput(varargin)
% Initialize parser
parser = inputParser;

% NumUsers
validNumUsersFn = @(x) (isnumeric(x));
parser.addParameter('NumUsers', [], validNumUsersFn)

% PolygonFile
validPolygonFileFn = @(x) (ischar(x));
parser.addParameter('PolygonFile', [], validPolygonFileFn)

% GridStep
validGridStepFn = @(x) (isnumeric(x));
parser.addParameter('GridStep', [], validGridStepFn)

% GridBoundary
validGridBoundaryFn = @(x) (isnumeric(x)) && (x(2) > x(1)) && (x(4) > x(3));
parser.addParameter('GridBoundary', [], validGridBoundaryFn)

% GridBoundary
validLLHFileFn = @(x) (ischar(x));
parser.addParameter('LLHFile', [], validLLHFileFn)

% Run parser and set results
parser.parse(varargin{:})
res = parser.Results;

end

% Function to get rid of redundant users
function posLLH = checkRedundantUsers(posLLH)
% Don't double count the poles
latMinInd = find(posLLH(:,1) ~= -90);
if latMinInd(1) ~= 1
    posLLH = [-90, 0, 0;...
        posLLH(latMinInd(1):end, :)];
end
latMaxInd = find(posLLH(:,1) == 90);
if ~isempty(latMaxInd)
    posLLH = [posLLH(1:latMaxInd(1)-1, :);...
        90, 0, 0];
end
% Don't double count the prime meridian
if any(posLLH(:,2) == 0) && any(posLLH(:,2) == 360)
    lonMaxInd = (posLLH(:,2) == 360);
    posLLH(lonMaxInd, :) = [];
end
end