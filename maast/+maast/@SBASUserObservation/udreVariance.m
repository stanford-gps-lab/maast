function [] = udreVariance(obj, udrei)
% This function allocates the udre variance according to the UDREI values
% received from the master station.

% Handle empty observations
if (isempty(obj.UserLL))
    return;
end

% Get WAAS MOPS Constants
waasMOPSConstants = maast.constants.WAASMOPSConstants;

obj.Sig2UDRE = waasMOPSConstants.Sig2UDRE(udrei)';