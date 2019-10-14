function getIPP(obj)
% This function finds the latitude and longitude of the ionospheric pierce
% points. This code is from the original maast and will likely be changed
% or replaced in the future.

% Copyright 2019 Stanford University GPS Laboratory
%   This file is part of MAAST which is released under the MIT License.
%   See `LICENSE.txt` for full license details. Questions and comments
%   should be directed to the project at:
%   https://github.com/stanford-gps-lab/maast

% Handle empty input
if (isempty(obj.UserLL))
    return;
end

ll_usr = obj.UserLL';
maastConstants = maast.constants.MAASTConstants;
ionoRadius = maastConstants.IonoRadius;
earthConstants = sgt.constants.EarthConstants;
earthRadius = earthConstants.R;
el = obj.ElevationAngles(obj.SatellitesInViewMask);
az = obj.AzimuthAngles(obj.SatellitesInViewMask);


[n_los tmp]=size(el);
[n_usr tmp]=size(ll_usr);
n_sat=n_los/n_usr;

sat_idx=1:n_sat;

%convert to radians
ll_usr=ll_usr*pi/180;

%expand the user latitudes and longitudes to match the lines of sight
[t1 t2]=meshgrid(ll_usr(:,2),sat_idx);
latlon(:,2)=reshape(t1,n_los,1);

[t1 t2]=meshgrid(ll_usr(:,1),sat_idx);
latlon(:,1)=reshape(t1,n_los,1);

%calcualte earth angle
psi_pp=0.5*pi-el-asin(earthRadius*cos(el)/ionoRadius);
sin_psi_pp=sin(psi_pp);

%calulate IPP latitude
ll_ipp(:,1)=asin(sin(ll_usr(:,1)).*cos(psi_pp) +...
    cos(ll_usr(:,1)).*sin_psi_pp.*cos(az));

%calulate IPP longitude
ll_ipp(:,2)=ll_usr(:,2) + asin(sin_psi_pp.*sin(az)./cos(ll_ipp(:,1)));


%convert back to degrees
obj.IPP = ll_ipp*180/pi;


