function igpmask = mt18bandnum2ll(bandnum)
%*************************************************************************
%*     Copyright c 2020 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%function igpmask = mt18bandnum2ll(bandnum)
%Converts SBAS MOPS MT18 iono mask band number and IGP number to latitude
%and logitude.  See SBAS MOPS - RTCA DO-229E
%
% BANDNUM contains two columns of the iono mask Band number and the IGP
% (Ionospheric Grid Point) number within the Band
%
% IGPMASK is the same size as BANDNUM and contains the latitude and
% longitude of the IGP

% created by Todd Walter March 25, 2020

%Bands 0 - 8
lats_even = [-75.0 -65.0 -55.0 -50.0 -45.0 -40.0 -35.0 -30.0 -25.0 ...
             -20.0 -15.0 -10.0  -5.0   0.0   5.0  10.0  15.0  20.0  ...
              25.0  30.0  35.0  40.0  45.0  50.0  55.0  65.0  75.0];
lats_odd  = [-55.0 -50.0 -45.0 -40.0 -35.0 -30.0 -25.0 -20.0 -15.0 ...
             -10.0  -5.0   0.0   5.0  10.0  15.0  20.0  25.0  30.0 ...
              35.0  40.0  45.0  50.0  55.0];
lons_even = ones(size(lats_even));
lons_odd = ones(size(lats_odd));

%Band 0
lats(1,:) = [lats_even 85 lats_odd lats_even lats_odd lats_even lats_odd lats_even lats_odd];
lons(1,:) = [180*lons_even 180 -175*lons_odd -170*lons_even -165*lons_odd ...
            -160*lons_even     -155*lons_odd -150*lons_even -145*lons_odd];
       
%Band 1
lats(2,:) = [-85 lats_even lats_odd lats_even lats_odd lats_even lats_odd lats_even lats_odd];
lons(2,:) = [-140 -140*lons_even -135*lons_odd -130*lons_even -125*lons_odd ...
                  -120*lons_even -115*lons_odd -110*lons_even -105*lons_odd];

%Band 2
lats(3,:) = [lats_even lats_odd lats_even 85 lats_odd lats_even lats_odd lats_even lats_odd];
lons(3,:) = [-100*lons_even -95*lons_odd -90*lons_even -90 -85*lons_odd ...
             -80*lons_even -75*lons_odd -70*lons_even     -65*lons_odd];
       
%Band 3
lats(4,:) = [lats_even lats_odd -85 lats_even lats_odd lats_even lats_odd lats_even lats_odd];
lons(4,:) = [-60*lons_even -55*lons_odd -50 -50*lons_even -45*lons_odd ...
             -40*lons_even -35*lons_odd     -30*lons_even -25*lons_odd];
       
%Band 4
lats(5,:) = [lats_even lats_odd lats_even lats_odd lats_even 85 lats_odd lats_even lats_odd];
lons(5,:) = [-20*lons_even -15*lons_odd -10*lons_even -5*lons_odd ...
               0*lons_even 0 5*lons_odd  10*lons_even 15*lons_odd];
       
%Band 5
lats(6,:) = [lats_even lats_odd lats_even lats_odd -85 lats_even lats_odd lats_even lats_odd];
lons(6,:) = [20*lons_even 25*lons_odd 30*lons_even 35*lons_odd  40 ...
             40*lons_even 45*lons_odd 50*lons_even 55*lons_odd];
       
%Band 6
lats(7,:) = [lats_even lats_odd lats_even lats_odd lats_even lats_odd lats_even 85 lats_odd];
lons(7,:) = [60*lons_even 65*lons_odd 70*lons_even    75*lons_odd ...
             80*lons_even 85*lons_odd 90*lons_even 90 95*lons_odd];
       
%Band 7
lats(8,:) = [lats_even lats_odd lats_even lats_odd lats_even lats_odd -85 lats_even lats_odd];
lons(8,:) = [100*lons_even 105*lons_odd     110*lons_even 115*lons_odd ...
             120*lons_even 125*lons_odd 130 130*lons_even 135*lons_odd];
       
%Band 8
lats(9,:) = [lats_even lats_odd lats_even lats_odd lats_even lats_odd lats_even lats_odd NaN];
lons(9,:) = [140*lons_even 145*lons_odd 150*lons_even 155*lons_odd ...
             160*lons_even 165*lons_odd 170*lons_even 175*lons_odd NaN];
         
%Band 9
lats(10,:) = [60*ones(1,72) 65*ones(1,36) 70*ones(1,36)  75*ones(1,36)  85*ones(1,12) NaN(1,9)];
lons(10,:) = [(-180):5:175 (-180):10:170  (-180):10:170  (-180):10:170  (-180):30:150 NaN(1,9)];
         
%Band 10
lats(11,:) = [-60*ones(1,72) -65*ones(1,36) -70*ones(1,36) -75*ones(1,36) -85*ones(1,12) NaN(1,9)];
lons(11,:) = [(-180):5:175   (-180):10:170  (-180):10:170  (-180):10:170  (-170):30:160  NaN(1,9)];


igpmask = [lats(sub2ind([11 201], bandnum(:,1)+1, bandnum(:,2))) ...
           lons(sub2ind([11 201], bandnum(:,1)+1, bandnum(:,2)))];
       
       
% I forget why but maast prefers positive values for longitude
igpmask(igpmask(:,2) < 0, 2) = igpmask(igpmask(:,2) < 0, 2) + 360;
