function [ GMST ] = MJD2GMST( MJD )
%[ GMST ] = MJD2GMST( MJD ) Convert Modifided Julian Date to Greenwhich
%Mean Siderial Time
%   INPUT
%       MJD - Modified Julian Date
%   OUTPUT
%       GMST - Greenwhich Mean Sidereal Time
%
%   Function by:
%       Shawn Swist ~2018

GMST = 280.4606 + 360.9856473*(MJD-51544.5);
GMST = GMST*pi/180;
GMST = wrapTo2Pi(GMST);

end

