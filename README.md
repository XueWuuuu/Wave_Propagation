# Introduction of Wave Propagation Function
This project is for a line source laser ultrasonic generation for a transient line load on a half-space. 

The corresponding calculation process can be found in Reference "J. R. Bernstein, J. B. Spicer, Line source representation for lasergenerated ultrasound in aluminum, Tech. rep. (2000)."

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


---
# Use WaveFunctionSov to get a Wave Propagation map
Type the following content into the MATLAB command window:

`>>WaveFunctionSov`

`>>[u,v] = WaveFunctionSov`

It may have the error of no defined function of "Reta", you can open the WaveFunctionSov function and find the "Reta" at the bottom. You can copy the function and save it as a m file.

Here is a Wave Propagation map at time = 70 $\mu$ s
![pic](https://github.com/XueWuuuu/img_folder/blob/main/FigA1.png)   

Here is the gif of the wave propagation process:
![pic](https://github.com/XueWuuuu/img_folder/blob/main/test.gif)
---
# Huygens–Fresnel principle to calculate the B-scan
