function [ E, iter ] = OrbitPrediction( M, e, tol )
%[ E, iter ] = OrbitPrediction( M, e, tol ) Predict the location of an
%orbiting body. Use Newton-Rhapson method to determine the Eccentric Anomaly
%   INPUTS
%       M - Mean anomaly        (deg)
%       e - Orbit eccentricity  (0:1)
%       tol - Tolerance         (~10e-8)
%
%   OUTPUT
%       E - Eccentric anomaly   (deg)
%       iter - The number of iterations taken to solve 
%
%   Function by
%       Shawn Swist ~ 2018
%       For use in Stanford University AA 279A

%M = M*pi/180; % Radians
% Make an initial guess for the Eccentric anomaly
E = M;
error = 1;
iter = 0; % Keep track of the number of iterations

while error > tol
    iter = iter + 1; 
    del = -(E - e*sin(E) - M)/(1-e*cos(E));
    E = E + del;
    error = abs(del);
%     disp(error)
end
%E = E*180/pi; % Degrees


end

