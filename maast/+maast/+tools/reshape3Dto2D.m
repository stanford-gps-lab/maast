function m = reshape3Dto2D(m3d, direction)
% reshape3Dto2D     reshape a 3D matrix to concatenate all 2D matrices
% vertically or hortizontally.
%   For 3D matrices that can be viewed as a deck of cards with the depth
%   representing different 2D matrices, this function helps with reshaping
%   the 3D matrix to effectively concatenate the 2D matrices in either the
%   vertical direction or horizontal direction.
%
%   m = maast.tools.reshape3Dto2D(m3d) vertically concatenates the 2D
%   matrices such that the result m = [m3d(:,:,1); ...; m3d(:,:,n)].
%
%   m = maast.tools.reshape3Dto2D(m3d, direction) specifies the direction
%   for the reshaping:
%       - 'vertical': vertically concatenates the 2D matrices and creates
%       m = [m3d(:,:,1); ...; m3d(:,:,n)]
%       - 'horizontal': horizontally concatenates the 2D matrices and
%       creates [m3d(:,:,1) ... m3d(:,:,n)]
%
% See Also: maast.tools.reshape2Dto3D

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details.
%   Questions and comments should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% default to returning a vertical 2D matrix
if nargin < 2
    direction = 'vertical';
end

% get the dimensions of the 3d matrix
[r, c, d] = size(m3d);

switch lower(direction)
    
    case 'horizontal'
        % for horizontal the default reshape function works fine
        m = reshape(m3d, r, c*d);

    case 'vertical'
        % for vertical need to permute and then reshape
        m3dp = permute(m3d, [1 3 2]);
        m = reshape(m3dp, r*d, c);

    otherwise
        error('unknown direction');
end