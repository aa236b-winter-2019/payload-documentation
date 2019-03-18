function [ dx ] = InnerSolarSysSim( t,x )
%[ dx ] = InnerSolarSysSim( t,x )
%   A simulation of the inner solar system (Sun, Mercury, Venus, Earth,
%   Moon)
%   Used with ODE113 for numerical integration.
%   INPUTS
%       t - the current time
%       x - a [35x1] vector containing information about the bodies
%   OUTPUT
%       dx - the time derivative of vector x
%   Function by
%       Shawn Swist ~ 2018

% Initialize the deribative of the state vector
dx = zeros(length(x),1);

% Set dmu/dt = 0 for all bodies, this keeps mu body constant
musun = x(1);       % Mu Sun
mumerc = x(8);      % Mu Mercury
muvenus = x(15);    % Mu Venus
muearth = x(22);    % Mu Earh
mumoon = x(29);     % Mu Moon

dx(1) = 0;          % dmu/dt Sun
dx(8) = 0;          % dmu/dt Mercury
dx(15) = 0;         % dmu/dt Venus
dx(22) = 0;         % dmu/dt Earth
dx(29) = 0;         % du/dt Moon

% The position and velocity vectors for all bodies
rsun = x(2:4);      % Position of Sun       
vsun = x(5:7);      % Velocity of Sun 
rmerc = x(9:11);    % Position of Mercury 
vmerc = x(12:14);   % Velocity of Mercury 
rvenus = x(16:18);  % Position of Venus 
vvenus = x(19:21);  % Velocity of Venus 
rearth = x(23:25);  % Position of Earh 
vearth = x(26:28);  % Velocity of Earth 
rmoon = x(30:32);   % Position of Moon 
vmoon = x(33:35);   % Velocity of Moon 

% dr/dt is velocity for all bodies
dx(2:4) = vsun;     % drdt for Sun
dx(9:11) = vmerc;   % drdt for Mercury
dx(16:18) = vvenus; % drdt for Venus
dx(23:25) = vearth; % drdt for Earth
dx(30:32) = vmoon;  % drdt for Moon

% Initialize the accelerations
asun = zeros(3,1);  % Acceleration of Sun
amerc = zeros(3,1); % Acceleration of Mercury
avenus = zeros(3,1);% Acceleration of Venus    
aearth = zeros(3,1);% Acceleration of Earth
amoon = zeros(3,1); % Acceleration of Moon

% The acceleration effects will have this general form
% aB = -muCB*(rB-rCB)/norm(rB-rCB)^3

% The acceleration on each body due to the Sun
asun = asun + zeros(3,1);       % no effect on itself!
amerc = amerc + -musun*(rmerc-rsun)/norm(rmerc-rsun)^3;
avenus = avenus + -musun*(rvenus-rsun)/norm(rvenus-rsun)^3;
aearth = aearth + -musun*(rearth-rsun)/norm(rearth-rsun)^3;
amoon = amoon + -musun*(rmoon-rsun)/norm(rmoon-rsun)^3;

% The acceleration on each body due to Mercury
asun = asun + -mumerc*(rsun-rmerc)/norm(rsun-rmerc)^3;
amerc = amerc + zeros(3,1);     % no effect on itself!
avenus = avenus + -mumerc*(rvenus-rmerc)/norm(rvenus-rmerc)^3;
aearth = aearth + -mumerc*(rearth-rmerc)/norm(rearth-rmerc)^3;
amoon = amoon + -mumerc*(rmoon-rmerc)/norm(rmoon-rmerc)^3;

% The acceleration on each body due to Venus
asun = asun + -muvenus*(rsun-rvenus)/norm(rsun-rvenus)^3;
amerc = amerc + -muvenus*(rmerc-rvenus)/norm(rmerc-rvenus)^3;
avenus = avenus + zeros(3,1);   % no effect on itself!
aearth = aearth + -muvenus*(rearth-rvenus)/norm(rearth-rvenus)^3;
amoon = amoon + -muvenus*(rmoon-rvenus)/norm(rmoon-rvenus)^3;

% The acceleration on each body due to Earth
asun = asun + -muearth*(rsun-rearth)/norm(rsun-rearth)^3;
amerc = amerc + -muearth*(rmerc-rearth)/norm(rmerc-rearth)^3;
avenus = avenus + -muearth*(rvenus-rearth)/norm(rvenus-rearth)^3;
aearth = aearth + zeros(3,1);   % no effect on itself!
amoon = amoon + -muearth*(rmoon-rearth)/norm(rmoon-rearth)^3;

% The acceleration on each body due to the Moon
asun = asun + -mumoon*(rsun-rmoon)/norm(rsun-rmoon)^3;
amerc = amerc + -mumoon*(rmerc-rmoon)/norm(rmerc-rmoon)^3;
avenus = avenus + -mumoon*(rvenus-rmoon)/norm(rvenus-rmoon)^3;
aearth = aearth + -mumoon*(rearth-rmoon)/norm(rearth-rmoon)^3;
amoon = amoon + zeros(3,1);     % no effect on itself!


% Update the state derivative vector with the accelerations
dx(5:7) = asun;         % dv/dt of Sun
dx(12:14) = amerc;      % dv/dt of Mercury
dx(19:21) = avenus;     % dv/dt of Venus
dx(26:28) = aearth;     % dv/dt of Earth
dx(33:35) = amoon;      % dv/dt of Moon

end

