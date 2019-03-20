function m3d = reshape2Dto3D(m2d, r, c)
% reshape2Dto3D     reshape a 2D matrix that contains a concatenation of
% smaller 2D matrices into a 3D matrix with the depth indexing the
% different 2D matrices.
%   For a 2D matrix that can be viewed as a concatenation of a series of 2D
%   matrixes (m2d = [m1 r2 m3] or m2d = [m1; m2; m3]) this function
%   converts that 2D matrix to a 3D representation of the data with each
%   sub-matrix as a depth entry (e.g. m3d(:,:,1) = m1, m(3d(:,:,n) = mn).
%
%   m3d = maast.tools.reshape2Dto3D(m2d, r, c)  reshapes the 3D matrix,
%   m3d, into a RxCxN 3D matrix.
%
% See Also: maast.tools.reshape3Dto2D

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details.
%   Questions and comments should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

[mr, mc] = size(m2d);

if (mr == r)  % horizontal matrix
    % internal rehsape function works no problem
    d = mc/c;
    if round(d) ~= d
        error('invalid column dimension');
    end
    
    m3d = reshape(m2d, r, c, d);
    
elseif (mc == c)  % vertical matrix
    % reshape and then permutation is required
    d = mr/r;
    if round(d) ~= d
        error('invalid row dimension');
    end
    m3dp = reshape(m2d, r, d, c);
    m3d = permute(m3dp, [1 3 2]);

else
    error('resulting dimensions are not possible');
end