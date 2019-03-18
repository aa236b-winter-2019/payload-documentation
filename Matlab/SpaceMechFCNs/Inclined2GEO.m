function [ dv ] = Inclined2GEO( dia )
%[ dv ] = Inclined2GEO( dia ) 
%   Find the total delta v required to go from a 200 km altitude parking
%   orbit of 28.5 deg inclination to an equatorial geostationary orbit. 
%   INPUT: dia - amount of inclination taken out at first burn (deg)
%   OUTPUT: dv - the total delta v for the transfer
%   Function by
%       Shawn Swist ~2018

% Constants for parking orbit, geo orbit, earth
ra = 6578;
rb = 42164;
mu = 3.9860e+05;
i = 28.5;

dib = i-dia;

Vam = sqrt(mu/ra);
Vap = sqrt(2*mu*(1/ra - 1/(ra+rb)));
dva = sqrt(Vam^2 + Vap^2 - 2*Vam*Vap*cosd(dia));

Vbm = sqrt(2*mu*(1/rb - 1/(ra+rb)));
Vbp = sqrt(mu/rb);
dvb = sqrt(Vbm^2 + Vbp^2 - 2*Vbm*Vbp*cosd(dib));

dv = dva+dvb;




end

