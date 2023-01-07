function [fitresult, gof] = createFit(X, Y)
%CREATEFIT(X,Y)
%  Function to create a fit to estimate the characteristic time for thermophoresis
%  experiments.
%
%  Fit equation:
%      Y = a - b*exp(-X/c)
%
%  Data for curve fit:
%      X Input : time (s)
%      Y Output : intensity gradient wrt distance across sample channel (dc/dx)
%      g : intial guess
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

% Adapted from: MATLAB curveFitter tool auto-generated code
% Project: thermophoretic approach for gradient patterning of substrate
% Version 1.0, 18-Aug-2022


%% curve fitting

% User-defined inputs
X = t_arr(1:end-5); % time 
Y = grad_arr(1:end-5); % gradient 
g = [0.3 0.3 2000]; %intial guess values 

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
YFit = a-b.*exp(-xData./c);

% Plot fit with data.
% figure( 'Name', 'fitted curve' );
plot(t_arr, grad_arr, 'bo');
hold on
plot(xData, YFit)

% h = plot( fitresult, xData, yData );
% legend( h, 'grad_arr vs. t_arr', 'fitted', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'time (s)', 'Interpreter', 'none' );
ylabel( 'dc/dx (mm-1)', 'Interpreter', 'none' );
% grid on 


