function [ phi, lamda, h ] = ecef2geocen(r_ecef)
%[ phi, lamda ] = ecef2geocen(r_ecef) 
%   Turn a position vector (in ECEF) into latitude and longitude
%   INPUT
%       r_ecef - 3x1 vector of position in ECEF frame
%   OUTPUTS
%       phi - latitude [degrees]
%       lamda - longitude [degrees]
%       h - Altitude [km]
%
%   Function by
%       Shawn Swist ~2018

r = norm(r_ecef);
rx = r_ecef(1);
ry = r_ecef(2);
rz = r_ecef(3);

rE = 6378; % km
h = r-rE;

phi = asin(rz/r);
lamda = atan2(ry,rx);

phi = phi*180/pi;
lamda = lamda*180/pi;

end

