function [r_ecef,v_ecef,r_enu,AZ,EL,Rgs] = SatellitePropagator(oe,epoch,mu,t_vec,rCB,GClong,GClat)
%[r_ecef,r_enu,AZ,EL] = SatPropagator(oe,epoch,mu,t_vec,rCB,GClong,GClat)
%Propagate a satellite's orbit for a given period of time. Provides
%Earth-Centered, Earth-Fixed coordinates, and from the ground station, the
%East, North, Zenith coordinates as well as the Elevation angle and Azimuth
%angle.
%   INPUTS
%          oe - Orbital elements [6x1]
%               a - Semimajor Axis          [km]
%               e - Eccentricity            []
%               i - Inclination             [deg]
%               Om - R.A.A.N                [deg]
%               w - Arg. Perigee            [deg]
%               M - Mean Anomaly            [deg]
%       epoch - Satellite epoch             [MJD] 
%          mu - Gravitational Parameter     [km^2/s^3]
%       t_vec - Simulation time vector      [MJD]   [1xn]
%         rCB - Center Body Radius          [km]
%      GClong - Ground Station Longititude  [deg]
%       GClat - Ground Station Latitude     [deg]
%
% OUTPUTS
%      r_ecef - Earth Centered/Fixed Coord. [km]    [3xn]
%      v_ecef - Earth Centered/Fixed vel.   [km/s]  [3xn]
%       r_enu - East,North,Zenith coord     [km]    [3xn]
%          EL - Elevation angle             [deg]   [1xn]
%          AZ - Azumituh angle              [deg]   [1xn]
%         Rgs - Ground station positioin    [km]    [3xn]
%
%   Function by:
%       Shawn Swist ~2018
%       Stanford University

% Extract the orbital elements
a = oe(1); e = oe(2); i = oe(3); Om = oe(4); w = oe(5); M0 = oe(6);
n = sqrt(mu/a^3);

% Greenwich Mean Siderial Time during simulation
GMST = MJD2GMST(t_vec); % Greenwich time [rad]
GMST = rad2deg(GMST);   % Greenwich time [deg]

% Propagate Mean Motion of Satellite
dt = t_vec - epoch; % dt vec for propagating mean anomaly
M = deg2rad(M0) + n*dt*86400;   % Mean Anomaly [rad]
M = mod(M,2*pi);                % Mean Anomaly [rad 0:2pi]

% Ground Station and Rotation Matrix
Ehat = [-sind(GClong);cosd(GClong);0];
Nhat = [-sind(GClat)*cosd(GClong);-sind(GClat)*sind(GClong);cosd(GClat)];
Uhat = [cosd(GClat)*cosd(GClong);cosd(GClat)*sind(GClong);sind(GClat)];

Rxyzenu = [Ehat Nhat Uhat]';
Rgs = rCB*[cosd(GClat)*cosd(GClong);cosd(GClat)*sind(GClong);sind(GClat)];

% Initilize matricies
r_ecef = zeros(3,length(t_vec));
v_ecef = zeros(3,length(t_vec));
r_enu = zeros(3,length(t_vec)); 
EL = zeros(1,length(t_vec));
AZ = zeros(1,length(t_vec));


% Find ECEF/elevation/azimuth angles during simulation time
for ii = 1:length(t_vec)
    E = M2E(M(ii),e,1e-10);     % Eccentric Anomaly [rad]
    anom = E2anom(E,e);         % True Anomaly [rad]
    anom = rad2deg(anom);       % True Anomaly [deg]
    [r_eci, v_eci] = OE2ECI(a, e, i, Om, w, anom, mu);
    r_ecef(:,ii) = rotz(-GMST(ii))*r_eci;
    v_ecef(:,ii) = rotz(-GMST(ii))*v_eci;
    Rsat = Rxyzenu*(r_ecef(:,ii)-Rgs);
    re = Rsat(1,:);
    rn = Rsat(2,:);
    ru = Rsat(3,:);
    r_enu(:,ii) = [re;rn;ru];
%     r_enu(:,ii) = Rxyzenu*(r_ecef(:,ii)-Rgs);%works but use enu for altaz
    EL(ii) = rad2deg(atan2(ru,(sqrt(re^2+rn^2))));
    AZ(ii) = rad2deg(atan2(re,rn));
end


end

