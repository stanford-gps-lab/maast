function [a, e, i, lan, omega, M0] = geolon2kepler(gps_abs_time, geo_lon_deg)

global CONST_H_GEO CONST_MU_E CONST_OMEGA_E;

% get the geo position in ECEF
x_ecef = llh2xyz([0 geo_lon_deg CONST_H_GEO])';

%calculate the Greenwich mean sidereal time and covert to radians
jd = gps2jd(floor(gps_abs_time/(7*24*3600)),mod(gps_abs_time, 7*24*3600));
ut1 = (jd - 2451545.0)/36525;
theta_g = 67310.54841 + (876600*8640184.812866)*ut1+0.093104*ut1^2 - (6.2e-6)*ut1^3;
theta_g = mod(theta_g*pi/(240*180), 2*pi);

% get the geo position and velocity in ECI at epoch time
x_eci = [[cos(theta_g) -sin(theta_g) 0]; [sin(theta_g) cos(theta_g) 0]; [0 0 1]]*x_ecef;
v_eci = cross([0 0 CONST_OMEGA_E]', x_eci);
r = sqrt(x_eci'*x_eci);
v = sqrt(v_eci'*v_eci);

% compute the orbital angular momentum vector
h = cross(x_eci, v_eci);
hmag = sqrt(h'*h);

% compute the line of nodes vector
n = cross([0 0 1]', h);
nmag = sqrt(n'*n);

% compute the specific mechanical energy
eps = (v^2)/2 - CONST_MU_E/r;

% compute the eccentricity vector & eccentricity
e_vec = ((v^2 - CONST_MU_E/r)*x_eci - (x_eci'*v_eci)*v_eci)/CONST_MU_E;
e = sqrt(e_vec'*e_vec);

% compute the semi-major axis
a = -CONST_MU_E/(2*eps);

%%%%%%% sub in these values specifically for geostationary  %%%%%%%%
a = nthroot(CONST_MU_E/(CONST_OMEGA_E^2),3);
e = 0;


% compute the inclination
i = acos(h(3)/hmag);

% if eccentricity and inclination are too small then LAN, omega amd M0 are
% undefined and need to be calculated differently
if i + e < 0.01
    % compute the true longitude
    lon_t = acos(x_eci(1)/r);
    if x_eci(2) < 0
        lon_t = 2*pi - lon_t;
    end
    raan = lon_t;
    omega = 0;
    M0 = 0;
    lan = raan - theta_g;
    if lan < -pi
        lan = lan + 2*pi;
    elseif lan > pi
        lan = lan - 2*pi;
    end
else
    % compute the right ascension of the ascending node and the longitude of
    % ascending node
    raan = acos(n(1)/nmag);
    if n(2) < 0
        raan = 2*pi - raan;
    end
    lan = raan - theta_g;

    % compute the argument of perigee
    omega = acos(n'*e_vec/(e*nmag));
    if e_vec(3) < 0
        omega = 2*pi - omega;
    end

    % compute the true anomaly
    f = acos(e_vec'*x_eci/(e*r));
    if x_eci'*v_eci < 0
        f = 2*pi - f;
    end

    % compute the eccentric anomaly
    E = atan2(sqrt(1 - e^2)*sin(f)/(1+e*cos(f)), (e + cos(f))/(1 + e*cos(f)));

    % compute the mean anomaly
    M0 = E - e*sin(E);
end