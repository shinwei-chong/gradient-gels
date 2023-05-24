% SUMMARY: Script file to perform curve fitting of the predicted
% temperature profile, to determine the temperature gradient

% INPUT:
% - Excel data file - estimated T vs. x profile 
% - Microscope scale calibration factor 
% - Data range to be analysed (defined by x-coordinates in pixels)

% OUTPUT: 
% - Temperature gradient from linear fit 


% Written by: SWC
% Version 1.0, 23-May-2023

%%%%%%%%%%%%%%%%%%
close all 

% Load the Excel spreadsheet
filename = '/Users/shinweichong/Library/CloudStorage/OneDrive-TheUniversityofSydney(Students)/PhD project/2. Temperature characterisation - RhoB/Exp_600-100_CHCHC_TempAlongLength.xlsx';

sheet = 'summary data'; % Sheet name

conv_fac = 0.62e3; % pix/mm

data = xlsread(filename, sheet);

% Define data range
dist = data(:,1);   % x-distance in pixels 
Tprof = data(:,18);  % T profile of interest 

x_start = 1650;      % Define region of interest 
x_end = 1900;

selected_x = [dist(x_start):dist(x_end)] ./ conv_fac;
selected_x = reshape(selected_x,1,[]);

selected_T = Tprof(x_start:x_end);
selected_T = reshape(selected_T,1,[]);

% Perform linear fit and calculate gradient
p = polyfit(selected_x, selected_T, 1);
grad = p(1)


% CURVE FIT 
%  Fit equation: 
%      Y = m*X + c
%  Data for curve fit:
%      X Input : distance (mm)
%      Y Output : temperature (degC)
%      g : intial guess
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.


% user-defined inputs
X = selected_x; 
Y = selected_T; 
g = [20 5]; %intial guess values 

% Prepare data
[xData, yData] = prepareCurveData( X, Y );

% Set up fittype and options.
ft = fittype( 'b*x + c', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Levenberg-Marquardt';
opts.Display = 'Off';
opts.MaxIter = 1000;
opts.StartPoint = g;
opts.TolFun = 1e-10;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
m = fitresult.b;
c = fitresult.c; 

% Fitted plot
XFit = selected_x;
YFit = m*XFit + c;

real_dist = dist ./ conv_fac;
scatter(real_dist, Tprof, SizeData=0.5);
hold on 
plot(XFit, YFit,'k',LineWidth=2);

xlabel("distance (mm)")
ylabel("Temperature (degC)")
title_str = sprintf("grad = %.1f degC/mm", m);
title(title_str)

gof


