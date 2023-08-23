%% initialization
clear all
% close all
tic;

%% Bscan simulation
%%
global gamT gamL A sT sL cL cT fHigh fHigh2 delt_t
cR=(3348.6559); % ParametersCalculation.m
cT=(3101.1542); % shear wave velocity
cL=(6173.5214); % longitudinal wave velocity

sL = 1/cL; % slowness of cL
sT = 1/cT; % slowness of cT
step_x = 0.05; % scanning step of x
delt_x = 2; % the distance between detection and excitation
delt_t = 5e-9; % time interval

fHigh = [2e6 20e6]; % bandpass filter
fHigh2= [1e6 40e6]; % 20-40 MHz
Rp = 3;
Rs = 12;

%% mesh field
xD = 0:step_x:20; % xD:Detection position of simulated x
zD = zeros(size(xD));
xG = xD+delt_x; % xG:Excitation position of simulated x
zG = zeros(size(xG));
t = 5e-9:delt_t:7000e-9; % t:simulation time

x = 0:0.05:20; % x;imaged x range
y = 0:0.05:10; % y:imaged y range

%% defect definition
crack_circle = [10, 4]; % crack center
crack_R = 0.25; % Radius of crack
circle_part = 720; % parts of crack
circle_part = 1:circle_part;
circle_x =  crack_circle(1)+crack_R*sind(circle_part); % x position of crack
circle_y =  crack_circle(2)+crack_R*cosd(circle_part); % y position of crack

%% calculation of mesh field
adG = [];
adD = [];
d_all = [];
d_E = [];
d_D = [];
for o = 1:size(xD,2)
dG = sqrt((xG(o)-circle_x).^2+circle_y.^2); % distance between generation and crack
dD = sqrt((xD(o)-circle_x).^2+circle_y.^2); % distance between crack and detection
[dall,dindx] = min(dG+dD); % the min total progation distance, in mm
ad_G= (acos(circle_y(dindx)/dG(dindx))); % the angle of generation to crack, in radian
ad_D= (acos(circle_y(dindx)/dD(dindx))); % the angle of detection to crack, in radian
adG = [adG;ad_G]; % array of the angle of generation to crack
adD = [adD;ad_D]; % array of the angle of detection to crack
d_E = [d_E;dG(dindx)];
d_D = [d_D;dD(dindx)];
d_all = [d_all;dall]; % array of total progation distance
end
theta = (pi/2-adG)'; % the angle of generation to normal
r = d_all'*1e-3; % in m
Dtheta = repmat((pi/2-adD),1,length(t)); % map of angle of detection to normal
[u,v] = WaveFunctionSov(theta,r,t,'circle','thetar-t','SimulationProcess');
% v = v'.*sin(Dtheta);
v = v';
vf = LPF_row(v,t,fHigh,fHigh2,Rp,Rs);
figure;mesh(t,xD,vf);view(0,90);colormap(hsv);