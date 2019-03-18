function [ a, e, i, Om, w, nu ] = ECI2OE( R, V )
%[ a, e, i, Om, w, nu ] = ECI2OE( R, V ) Turn position and velocity into
%Orbital Elements
%   INPUTS
%       R - I,J,K components of position
%       V - I,J,K components of velocity
%   OUTPUTS
%       a - semi-major axis
%       e - eccentricity
%       i - inclination
%       Om - RAAN
%       w - Arguement of Periapsis
%       nu - true anomaly
%   
%   Function by
%       Shawn Swist ~ 2018
if nargin < 3
    mu = 3.986e5;
end

r = norm(R);
v = norm(V);

H = cross(R,V);
h = norm(H);

N = cross([0;0;1],H);
n = norm(N);
e_vec = 1/mu*((v^2-mu/r).*R-dot(R,V).*V);
e = norm(e_vec);

P = h^2/mu;
a = -P/(e^2-1);

% Orbital Inclination (always less than 180 deg)
i = acos(H(3)/h);

% Rignt Ascension of Ascending Node
Om = acos(N(1)/n);
if N(2) < 0             % If Nj is greater than 0 Om is less than 180
    Om = 2*pi - Om; 
end

% Argument of periapsis
w = acos(dot(N,e_vec)/(n*e));
if e_vec(3) < 0  % If e(k) is greater than 0 w is less than 180
   w = 2*pi - w;
end

% True anomaly
nu = acos(dot(e_vec,R)/(e*r));
if dot(R,V) < 0     % If R dot V is greater than zero nu is less than 180
    nu = 2*pi - nu;
end

% Convert angles to degres
i = i*180/pi;
Om = Om*180/pi;
w = w*180/pi;
nu = nu*180/pi;


end

