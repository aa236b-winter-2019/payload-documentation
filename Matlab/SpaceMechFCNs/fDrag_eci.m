function [ fD ] = fDrag_eci( R, V, B )
% [ fD ] = fDrag_eci( R, V, B )
%   Determine the accleration due to drag using an exponential atmospheric
%   density function.
%   INPUTS
%       R - [3x1] ECI Position Vector (km)
%       V - [3x1] ECI Velocity Vector (km/s)
%       B - Ballistic Coefficient of Satellite
%   OUTPUT
%       fD - [3x1] Acceleration due to Drag in ECI frame
%   Function by
%       Shawn Swist ~ 2018

% Earth Parameters
rE = 6378;      % km
wE = [0; 0; 2*pi/86184]; % rad/s, about Z-axis (ECI frame)

% Exponential Atmospheric Density Function
rho_0 = 1.225;  % kg/m^3
h_0 = 0;        % km, sea level 
H = 10;         % km, characteristic height

% Drag Calculations
h = norm(R) - rE; % The height of the satellite
rho = rho_0*exp(-(h-h_0)/H); % Density at height, kg/m^3
vrel = V - cross(wE,R);      % Velocity relative to atmosphere, ECI frame

vrel = vrel*1000; % convert to m/s
unit_vec = vrel/norm(vrel);
fD = -(1/2)*B*rho*norm(vrel)^2*unit_vec;

end

