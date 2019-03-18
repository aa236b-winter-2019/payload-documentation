% Shawn Swist
% AA 290 - Manchester
%

% Note: This takes ~5 min to run (40kHz sample rate data for ~12 mins)
% =============== Constants ===============
filename = "doppler_curve_test"; % Output bin file name

% Earth Parameters 
rE = 6378;          % [km]       Earth radius
mu = 3.986e5;       % [km^3/s^2] Earth gravational parameter
seed = rng(1);      % Keep the seed the same for randn

% Frequency of tag
f0 = 400;           % [MHz]      Frequency
Fs = 40000;         % [Hz]       Sample frequency (40kHz)
dt = 1/Fs;          % [s]        Time step
c = 299792458;      % [m/s]      Speed of light

% Time
epoch = 58398;      % [MJD] 10/7/2018
dt_mjd = dt/86400;
tvec = .0215:dt_mjd:.03; % UNITS... dt = sec tvec = MJD ...
t_sec = 0:dt:1;

% Ground Station
GClat = 37.426622;
GClong = -122.173355;
% TURN THESE INTO GEODETIC LAT/LONG! ????
GC_phi = 37.6123;
GC_phi = GClat;
GC_lam = GClong;

% Define satellite orbiatl elements
a = rE + 500;   % [km]  Semi-major axis
e = 0.01;       %  []   Eccentricity
i = 89;         % [deg] Inclination
Om = 90;        % [deg]    RAAN
w = 0;          % [deg] Argument of Periapsis
nu = deg2rad(0);         % [deg->rad] True anomaly
M = E2M(anom2E(nu,e),e);  % [rad] Mean anomaly
M = rad2deg(M);         % [deg] Redifine mean anomaly in degrees

% Note: E2M, anom2E fcns. use radians, SatProp uses degrees.
oe = [a; e; i; Om; w; M];

% Simulate Satellite motion
[r_ecef,v_ecef,r_enu,AZ,EL,Rgs] = SatellitePropagator(oe,epoch,mu,tvec+epoch,rE,GC_lam,GC_phi);

%%
% Find When Satellite is visible
viz = find(EL>15);
h = zeros(length(r_ecef),1);
for jj = 1:length(r_enu)
    X = r_ecef(:,jj);
    V = v_ecef(:,jj);
    R = X-Rgs;
    h(jj) = (X-Rgs)'/sqrt((X-Rgs)'*(X-Rgs))*V;
end

% Measurement function
X = r_ecef(:,viz);
V = v_ecef(:,viz);
H = @(P) diag((X-P)'*V)./sqrt(diag((X-P)'*(X-P)));
H2 = @(P) f0*(1+-(1000*H(P))/c);  % convert velocity from km/s to m/s

% Doppler Shift
f0 = 400;
freq = f0*(1+-(1000*h(viz))/c);
f_out = freq - f0;
f_out_hz = f_out*1000000; % MHz -> Hz
% figure;
% plot(tvec(viz)*24*60,f_out_hz)

%% Use CPFSK to get frequency output
new_time = (tvec(viz)-tvec(viz(1)))*86400;
figure; plot(new_time,f_out_hz/1000); 
xlabel('Time during pass (sec)')
ylabel('\Delta F (kHz)');
title('Doppler Curve')

% Set f0 to maximum of shifted frequency
max_f = max(f_out_hz);
min_f = min(f_out_hz);
f0 = max_f + abs(min_f);
new_f = f_out_hz - max_f;

figure;
plot(new_time,new_f + f0);
xlabel('Time');ylabel('Freq');title('What we should get from GNU')

% Calculate the phase shift for CPFSK
phase = cumtrapz(new_time,2*pi*new_f);

% Build the frequency curve
C = cos(2*pi*f0*new_time' + phase); % Time is a row vector while f is a column
S = sin(2*pi*f0*new_time' + phase);

% Write the binary file
filename = "doppler_curve_test_2"; % Output bin file name
write_complex_binary(C+1i*S,filename+".bin");

%% Continuous-phase frequency-shift keying
filename = "specified_freq_shift";

fs = 40000;
T = 1/fs;
L = fs*50;
t = (0:L-1)*T;
f = 1000;

% Desired frequency shift
del_f = 17000; % Hz
f_shift = linspace(0,del_f,length(t));

% phase = 1000*t.^2;
phase = cumtrapz(t,2*pi*f_shift);
figure; plot(t,phase);

C = cos(2*pi*f*t + phase);
S = sin(2*pi*f*t + phase); th = .1;
% figure;
% [pks,dep,pidx,didx] = peakdet(S,th);% perform peak-dep detection
% plot(t(1:1000),S(1:1000),'k'); hold on;             % plot signal
% plot(t(pidx(1:25)),pks(1:25),'go');

int_F = diff(phase)./diff(t);
figure;
plot(t(1:end-1),int_F);
hold on; 
plot(t,f_shift)

% stem(t(pidx),pks,'g')               % plot peaks
% stem(t(didx),dep,'r')               % plot depressions
% line([t(1) t(end)],[th th], ...     % plot thresholds
%     'LineStyle','--','color','m');
% line([t(1) t(end)],[-th -th],'LineStyle','--','color','m');

write_complex_binary(C+i*S,filename+".bin");


