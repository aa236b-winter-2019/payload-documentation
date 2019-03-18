function [ phi, lamda, h ] = ecef2geod( r_ecef, tol )
%[ phi, lamda ] = ecef2geocen(r_ecef, tol) 
%   Turn a position vector (in ECEF) into latitude and longitude. This
%   function assumes Earth as the center body and uses a radius of rE =
%   6378 km and an eccentricity of 0.0818.
%   INPUTs
%       r_ecef - 3x1 vector of position in ECEF frame
%       tol - A tolerance for solving, if omitted 1e-6 is used
%   OUTPUTS
%       phi - latitude [degrees]
%       lamda - longitude [degrees]
%       h - Altitude [km]
%
%   Function by
%       Shawn Swist ~2018


if nargin < 2
    tol = 1e-6;
end

Re = 6378;
eE = 0.0818;

r = norm(r_ecef);
rx = r_ecef(1);
ry = r_ecef(2);
rz = r_ecef(3);


phi0 = asin(rz/r);
lamda = atan2(ry,rx);
N = Re/sqrt(1-eE^2*sin(phi0)^2);
dz = N*eE^2*sin(phi0);
phi = atan2((rz+dz),sqrt(rx^2+ry^2));
while abs(phi-phi0) > tol
    phi0 = phi;
    N = Re/sqrt(1-eE^2*sin(phi0)^2);
    dz = N*eE^2*sin(phi0);
    phi = atan2((rz+dz),sqrt(rx^2+ry^2));
end

h = sqrt(rx^2+ry^2)/cos(phi)-N;

lamda = lamda*180/pi;
phi = phi*180/pi;


end

