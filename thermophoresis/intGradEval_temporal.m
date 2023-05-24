% SUMMARY: Script file to perform curve fitting on the normalised pixel
% intensity profile, to determine the change in intensity gradient (di/dx)
% over time

% INPUT:
% - Excel data file - normalised I vs. x profile 
% - Microscope scale calibration factor 
% - Data range to be analysed (defined by x-coordinates in pixels)

% OUTPUT: 
% - Temperature gradient from linear fit 

% WORKFOW: 
% - 


% Written by: SWC
% Version 2.0, 24-May-2023

%%%%%%%%%%%%%%%%%%


close all

% Load the Excel spreadsheet
filename = '/Users/shinweichong/Library/CloudStorage/OneDrive-TheUniversityofSydney(Students)/PhD project/1. Thermophoresis - fluor NPs/Exp_600-100_fluorPS+Triton_analyseddata.xlsx';

sheet = '1.3A-2 (ref against min1)'; % Sheet name

conv_fac = 0.62e3; % pix/mm

data = xlsread(filename, sheet);

dist = [1:size(data,2)]./ conv_fac;

% Define range of data
x_start = 1700; 
x_end = 1900;  
x = [x_start:x_end] ./ conv_fac;

% Select the range of columns
selected_data = data(:, x_start:x_end); % Adjust the column indices as needed

t= 1:size(selected_data,1);

% Calculate the gradient of the linear fit for each row
grad = zeros(size(selected_data, 1), 1);

for i = 1:size(selected_data, 1)
    
    y = selected_data(i, :);
    
    % Perform linear fit and calculate gradient
    p = polyfit(x, y, 1);
    grad(i) = p(1);
    
    scatter(dist, data(i,:), SizeData=0.5);
    hold on 
    YFit = polyval(p, x);
    plot(x, YFit,'k',LineWidth=2)
    pause(0.6)
    close 
end

% Display the gradients
figure
scatter(t,grad);
xlabel('time (mins)')
ylabel('dI/dx (mm-1)')

hold on 

% CURVE FIT - ESTIMATING THERMOPHORESIS CHARACTERISTIC TIME 
%  Fit equation: 
%      Y = a - b*exp(-X/c)
%  Data for curve fit:
%      X Input : time (mins)
%      Y Output : intensity gradient wrt distance across sample channel (dc/dx)
%      g : intial guess
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.


% user-defined inputs
X = t; % time 
Y = grad; % gradient 
g = [-0.8 -0.8 100]; %intial guess values 

% Prepare data
[xData, yData] = prepareCurveData( X, Y );

% Set up fittype and options.
ft = fittype( 'a-b*exp(-x/c)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Levenberg-Marquardt';
opts.Display = 'Off';
opts.MaxIter = 1000;
opts.StartPoint = g;
opts.TolFun = 1e-10;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts )
a = fitresult.a;
b = fitresult.b; 
c = fitresult.c;

% Fitted plot
XFit = 0:max(X); 
YFit = a-b.*exp(-XFit./c);

plot(XFit, YFit,'k')

