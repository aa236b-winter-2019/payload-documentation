function [ dt ] = ToF_ra( nu0, nuf, k, e, ra, mu )
%ToF_ra( nu0, nuf, k, e, ra, mu ) Given radius at apoapsis, determine the time
%of flight to reach desired true anomaly. If no gravitonal parameter is
%attributed the Earth will be used as a center body
%   INPUTS
%       nu0 - Initial true anomaly (deg)
%       nuf - Desired true anomaly (deg)
%       k - Number of orbits       (integer)
%       e - Eccentricity of orbit  (0:1)
%       ra - Radius at apoapsis    (km)
%       mu - Gravational Parameter (km^3/s^2)
%
%   OUTPUT 
%       dt - Time (in sec) until desired true anomaly is reached
%
%   Function by
%       Shawn Swist ~ 2018
%       For use in Stanford University AA 279A

if nargin < 6        % No value for mu was input
    mu = 3.986e5;    % km^3/s^2 (Earth)
end

% Semi-major axis
a = ra/(1+e);   % km
% Mean motion
n = sqrt(mu/a^3);

% Find M0,Mf (use radians)
nu0r = nu0*pi/180;
E0r = acos((e+cos(nu0r))/(1+e*cos(nu0r)));
M0r = E0r - e*sin(E0r);

nufr = nuf*pi/180;
Efr = acos((e+cos(nufr))/(1+e*cos(nufr)));
Mfr = Efr - e*sin(Efr);

% Time of Flight
dt = 1/n*(Mfr-M0r+2*pi*k);  % seconds

end

