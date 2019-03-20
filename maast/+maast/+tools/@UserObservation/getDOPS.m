function [varargout] = getDOPS(obj)
% getDOPS   get the DOP information of a given observation.
%   NOTE: this does not currently work on a list of user observations
%   
%   DOPs = uo.getDOPS() gets the DOPS (diagonal of the H matrix) for a
%   given instance of a user observation.
%
%   [GDOP, PDOP, TDOP, HDOP, VDOP] = uo.getDOPS() returns the full set of
%   DOP information for a given instance of a user observation.
%
% Example:
%   TODO: add example
%
% See Also: maast.tools.UserObservation


% TODO: right now this only works on a single observation, need to get it
% to be able to work on a list of observations (?)

% build the G matrix in the ENU frame
inview = obj.SatellitesInViewMask;  % need an in view mask
Genu = [obj.LOSenu(inview,:) ones(obj.NumSatellitesInView, 1)];

% compute H = inv(Genu'Genu)
H = inv(Genu' * Genu);

% extract the diag of H for all the dop calculations
DOPs = diag(H);

if nargout == 1  % just want dops
    varargout{1} = DOPs;
elseif nargout == 5
    varargout{1} = sqrt(sum(DOPs));         % Compute GDOP.
    varargout{2} = sqrt(sum(DOPs(1:3)));    % Compute PDOP.
    varargout{3} = sqrt(DOPs(4));           % Compute TDOP.
    varargout{4} = sqrt(sum(DOPs(1:2)));    % Compute HDOP.
    varargout{5} = sqrt(DOPs(3));           % Compute VDOP.
else
    error('invalid number of output arguments');
end
