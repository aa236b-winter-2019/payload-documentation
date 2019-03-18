function [ MJD ] = UT12MJD( m, d, y, h, min, s )
%[ MJD ] = UT12MJD( m, d, y, h, min, s ) Date to Modified Julian Date
%   INPUTS
%       m/d/y - The date (month/day/year)
%       h:min:s - The time (24hour clock)
%
%   OUTPUT
%       MJD - Modified Julian Date
%   
%   Function by:
%       Shawn Swist ~2018

if m <= 2
    Y = y-1;
    M = m+12;
else
    Y = y;
    M = m;
end

D = d + h/24 + min/1440 + s/86400;

B = Y/400 - Y/100 + Y/4;

MJD = 365*Y - 679004 + floor(B) + floor(30.6001*(M+1)) + D;

end

