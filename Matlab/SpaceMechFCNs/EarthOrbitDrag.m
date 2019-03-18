function [ dx ] = EarthOrbitDrag( t, x )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

r_vec = x(1:3);
v_vec = x(4:6);
dx = zeros(6,1);

r = norm(r_vec);

% Satellite Parameters
CD = 2.3;
A = 20;%*(1/1000)^2;
m = 1500;
B = A*CD/m;

% Earth Parameters
rE = 6378.137;   % km
mu = 3.9860e+05; % km^3/s^2
wE = [0; 0; 0*pi/86184]; % rad/s, about Z-axis (ECI frame)

% Exponential Atmospheric Density Function
rho_0 = 1.225;  % kg/m^3
h_0 = 0;        % km, sea level 
H = 10;         % km, characteristic height

% Drag Calculations
R = r_vec;
h = norm(R) - rE; % The height of the satellite
rho = rho_0*exp(-(h-h_0)/H); % Density at height, kg/m^3
vrel = v_vec - cross(wE,R);      % Velocity relative to atmosphere, ECI frame

vrel = vrel*1000; % convert to m/s
unit_vec = vrel/norm(vrel);
fD = -(1/2)*B*rho*norm(vrel)^2*unit_vec;
% Update state vector
agrav = -mu*r_vec/r^3;
adrag = fD/1000;

dx(1:3) = v_vec;
dx(4:6) = agrav+adrag;



end

