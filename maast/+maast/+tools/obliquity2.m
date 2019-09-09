function ob2 = obliquity2(el)
% This function takes the elevation angle in radians and returns the square
% of the ionospheric obliquity function.

maastConstants = maast.constants.MAASTConstants;
earthConstants = sgt.constants.EarthConstants;

ob2=ones(size(el))./(1-(earthConstants.R*cos(el)/maastConstants.IonoRadius).^2);
end