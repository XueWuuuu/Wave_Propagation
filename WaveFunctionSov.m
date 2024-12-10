function [u,v] = WaveFunctionSov(varargin)
% wave propagation function 
% Reference: Johanna R. Bernstein and James B. Spicer. Line source
% representation for laser-generated ultrasound in aluminum. 1999
% There are two way to run the example,
%   >>WaveFunctionSov
%   >>[u,v] = WaveFunctionSov

% parameters in : PAR1, PAR2, PAR3, PAR4, PAR5, PAR6
% PAR4: 'linear', 'l'
%           -> PAR1: linear parameters of position, such as: x = (-5:0.02:5)*1e-3; or theta = 0/360:2*pi/360:1*pi;
%           -> PAR2: linear parameters of position, such as: y = (0:0.02:5)*1e-3; or r0 = (0:0.01:5)*1e-3;
%           -> PAR3: linear parameters of time, such as: t=1e-9:10e-9:70*10e-9;
% PAR4: 'array','a'
%           -> PAR1, PAR2, PAR3: array parameters of position and time, such as: 
%                     x = (-5:0.02:5)*1e-3;
%                     y = (0:0.02:5)*1e-3;
%                     t=1e-9:10e-9:70*10e-9;
%                     [X,Y,T] = meshgrid(x,y,t);
%                 or 
%                     theta = 0/360:2*pi/360:1*pi;
%                     r0 = (0:0.01:5)*1e-3;
%                     t=1e-9:10e-9:70*10e-9;
%                     [Theta,R,T] = meshgrid(theta,r0,t);
% PAR4: 'xy-t','t','thetar-t'
%           -> PAR1, PAR2: linear parameters of position, PAR3 and linear parameters of time, such as:
%                     x = (-5:0.02:5)*1e-3;
%                     y = (0:0.02:5)*1e-3;
%                     t=1e-9:10e-9:70*10e-9;
%                     [X,Y] = meshgrid(x,y);
%                 or 
%                     theta = 0/360:2*pi/360:1*pi;
%                     r0 = (0:0.01:5)*1e-3;
%                     t=1e-9:10e-9:70*10e-9;
%                     [Theta,R] = meshgrid(theta,r0);
% PAR5: 'square', 's'
%           -> square area for x and y
% PAR5: 'circle','c'
%           -> polar coordinates area for theta and r0
% PAR6: 'WavePropagation','WP'
%           -> In the wave propagation process, the amplitude of acoustic 
%              wave is not affected by the grid.
% PAR6: 'SimulationProcess','SP'
%           -> In the simulation process, the grid's influence on amplitude
%              significantly impacts the wave propagation process.
%           -> When the propagating wavefront encounters grid nodes, the 
%              denominator tends to zero in a mathematical sense, resulting
%              in an infinite amplitude and causing the results to deviate.
%              For simplification when a value is approaching zero and becomes smaller 
%              than Replacement, I utilize Replacement2 to uniformly replace
%              the process of approaching zero, thus avoiding the gradual 
%              diminishment towards zero.
global gamT gamL A sT sL cL cT fHigh fHigh2 delt_t mui
u=[];v=[];
if nargin==0
    if nargout>0
        [u,v] = RunTheExample;
    else
        RunTheExampleCircle;
    end
    return
end
if ~(nargin >= 3 && nargin <=6)
    disp('WaveFunctionSov:InputsError');
    return
end

[reg, prop]=parseparams(varargin);
[x,y,t,theta,r]=default_set;

for i = 1:length(prop)
    switch prop{i}
        case {'linear', 'l'}
            [PAR1, PAR2, PAR3] = meshgrid(reg{1}, reg{2}, reg{3});
        case {'array','a'}
            PAR1 = reg{1}; PAR2 = reg{2}; PAR3 = reg{3};
        case {'xy-t','t','thetar-t'}
            if size(reg{1},1)==size(reg{2},1) && size(reg{1},2)==size(reg{2},2)
            [PAR1,~] = meshgrid(reg{1}, reg{3});
            [PAR2,PAR3] = meshgrid(reg{2}, reg{3});
            else
                disp('WaveFunctionSov:InputsSizeError');
            end
    end
end
for i = 1:length(prop)
    switch prop{i}
        case {'square', 's'}
            x = PAR1; y = PAR2; t = PAR3;
            Model = 'square';
        case {'circle','c'}
            theta = PAR1; r = PAR2; t = PAR3;
            Model = 'circle';
        case {'WavePropagation','WP'}
            WAVE_FUNCTION_SWITCH = 1;
        case {'SimulationProcess','SP'}
            WAVE_FUNCTION_SWITCH = 2;
%         otherwise
%             disp('WaveFunctionSov:PropTypeError')
    end
end
switch Model
    case 'square'
        theta = atan(y./x);
        r = sqrt(x.^2+y.^2);
        theta(theta<0)=-theta(theta<0);
        theta(theta>pi)=theta(theta>pi)-pi;
        theta(theta>pi/2)=pi-theta(theta>pi/2);

    case 'circle'
        theta(theta>pi)=theta(theta>pi)-pi;
        theta(theta>pi/2)=pi-theta(theta>pi/2);

end
switch WAVE_FUNCTION_SWITCH
    case 1
        % Singularities are not considered 
        WAVE_FUNCTION3;
    case 2
        % When (t.^2-sL.^2.*r.^2) goes to 0, singularities will occur.
        % To avoid these singularities, when (t.^2-sL.^2.*r.^2) -> Replacement, set (t.^2-sL.^2.*r.^2) = Replacement2.
        Replacement = 3e-7; % number small than Replacement will be replaced by Replacement2
        Replacement2 = 1e-9;% for SAFT simulation
        WAVE_FUNCTION4
end
end

function [regargs, proppairs]=parseparams(args)
%PARSEPARAMS Finds first string argument.
%   [REG, PROP]=PARSEPARAMS(ARGS) takes cell array ARGS and
%   separates it into two argument sets:
%      REG being all arguments up to, but excluding, the
%   first string argument encountered in ARGS.
%      PROP contains all other arguments after, and including,
%   the first string argument encountered.
%
%   PARSEPARAMS is intended to isolate possible property
%   value pairs in functions using VARARGIN as the input
%   argument.

%   Chris Portal 2-17-98
%   Copyright 1984-2002 The MathWorks, Inc. 

charsrch=[];

for i=1:length(args),
   charsrch=[charsrch ischar(args{i})];
end

charindx=find(charsrch);

if isempty(charindx),
   regargs=args;
   proppairs=args(1:0);
else
   regargs=args(1:charindx(1)-1);
   proppairs=args(charindx(1):end);
end
end

function [x,y,t,theta,r0] = default_set(varin)
% default set for x y t theta and r0. The x and y are linear set of 1*501
% and1*251 (in m) in Cartesian coordinate, and theta and r0 are angle (
% perpendicular to the surface) and distance in polar coordinates
global gamT gamL A sT sL cL cT fHigh fHigh2 delt_t mui cR cT cL
%cR=(3348.6559); % ParametersCalculation.m
%cT=(3101.1542);
%cL=(6173.5214);
A = 1;
mui = 1;
switch nargin
    case 1
        Num= 71;
        x = (-5:0.02:5)*1e-3;
        y = (0:0.02:5)*1e-3;
        t=1e-9:10e-9:Num*10e-9;
        r0 = (0:0.01:5)*1e-3;
        theta = 0/360:2*pi/360:1*pi;
    otherwise
    x = []; y = []; t = []; theta = []; r0 = [];
end
end

function [u,v] = RunTheExample
% cR,cT and cL are velocities of surface, shear and longitudinal wave of Al
% A is amplitude of wave.
global gamT gamL A sT sL cL cT fHigh fHigh2 delt_t mui
cR=(3348.6559); % ParametersCalculation.m
cT=(3101.1542);
cL=(6173.5214);
A = 1;
mui = 1;
sL = 1/cL;
sT = 1/cT;
[x,y,t,theta,r0] = default_set('example');
[u,v] = WaveFunctionSov(x,y,t,'square','linear','WavePropagation');

a =-1e3; b = 1e3;
h2 = figure;
h2.Color = 'white';
pic_num = 1;
time_dely = 1/30; %frame rate
h1 = gca;
cmax = max(v(:));
cmin = min(v(:));
for i = 1:70
    cx = v(:,:,i);
    times = 1.5;cx(cx>b*times|cx<a*times)=NaN;
%     cx(cx>b|cx<a)=NaN;
    ti = t(i);
    surf(x,y,cx);shading interp;
    h2.Position = [680 400 900 500];
    h1.Position = [0.05 0.1 0.9 0.85];
    times = 0.5;
    caxis([times*a times*b])
%     axis equal
    view(0,-90);
title(num2str(i));
drawnow;
end
end

function [u,v] = RunTheExampleCircle
global gamT gamL A sT sL cL cT fHigh fHigh2 delt_t mui
cR=(3348.6559); % ParametersCalculation.m
cT=(3101.1542);
cL=(6173.5214);
A = 1;
mui = 1;
sL = 1/cL;
sT = 1/cT;
[x,y,t,theta,r0] = default_set('example');
[u,v] = WaveFunctionSov(theta,r0,t,'circle','linear','WavePropagation');

a =-1e3; b = 1e3;
h2 = figure;
h2.Color = 'white';
pic_num = 1;
time_dely = 1/30; %frame rate
h1 = gca;
cmax = max(v(:));
cmin = min(v(:));
[Theta,R] = meshgrid(theta,r0);
X = R.*cos(Theta);
Y = R.*sin(Theta);
% [X,Y] = meshgrid(x,y); 
for i = 1:71
    cx = v(:,:,i);
    times = 1.5;cx(cx>b*times|cx<a*times)=NaN;
%     cx(cx>b|cx<a)=NaN;
    ti = t(i);
    surf(X,Y,cx);shading interp;
    h2.Position = [680 400 900 500];
    h1.Position = [0.05 0.1 0.9 0.85];
    times = 0.5;
    caxis([times*a times*b])
%     axis equal
    view(0,-90);
title([num2str(ti*1e6) '\mu s']);
xlabel('X/m')
ylabel('Y/m')
drawnow;
end
end

function Res = Reta(eta)
global gamT gamL sT
Res = 4*gamL.*gamT.*eta.^2+(sT^2-2*eta.^2).^2;
end
