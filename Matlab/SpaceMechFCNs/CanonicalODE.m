function [ dx ] = CanonicalODE( t, x )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

mu = 1; % Canonical units

dx = zeros(6,1);

r_vec = x(1:3);
v_vec = x(4:6);

r = norm(r_vec);

dx(1:3) = v_vec;
dx(4:6) = -mu*r_vec/r^3; % dvdt = -mu/r^2 * r_vec/r


end

