% script file to calculate and plot the normalised intensity profile 
% written for tif files acquired using MATLAB image acquisition tool

% Written: 24-Feb-2023



% housekeeping 
% close all 
% clc 
% clear 

%% DEFINE USER INPUT

% folder containing data files 
folder_name = fullfile('/Volumes/PRJ-grad1',...
    '1. Thermophoresis - fluor NPs',...
    '20230227_1000-150_HCHCH_500nm_1%_1000um/60min_across device')
% image size [height, width]
size = [1216, 1936];
conv_fac = 2.93e3; % microscope scale conversion factor - pix/um

%% 

% count number of data files to analyse
a = dir([folder_name '/pos*avi']);
N = length(a); 

% load reference image (t = 0min)
ref_name = a(1).name; % assume this is the first image in folder
ref = VideoReader([folder_name '/' ref_name]);
n_ref = ref.NumFrames; % total number of frames 

mat_ref = zeros(size(1), size(2)); % initialise empty matrix 

% find average intensity of each pixel across all frames in ref video file 
for i = 1:n_ref
    im = read(ref,i);
    im = im2gray(im); % convert to grayscale 
    im = double(im); % convert to double 
    mat_ref = mat_ref + im; 
end 

mat_ref_avg = mat_ref ./ n_ref;
sum_ref = sum(mat_ref_avg, "all"); % sum of all pixel intensities

% get timestamp of ref data
ref_file_info = dir([folder_name '/' ref_name]);
datenum_ref = datevec(ref_file_info.datenum); 
t_ref = datenum_ref(4)*60 + datenum_ref(5) + datenum_ref(6)/60; % time in mins

%% TIME-INTENSITY ANALYSIS

% initialise empty arrays
fac_array = zeros(1,N);
chck_array = zeros(1,N);

t_array = zeros(1,N); 
grad_array = zeros(1,N);

for j = 1:N

    file = a(j).name
    vid = VideoReader([folder_name '/' file]);
    n_vid = vid.NumFrames; % total number of frames 

    % calculate average of all frames 
    mat_vid = zeros(size(1), size(2)); % initialise empty matrix 

    for k = 1:n_vid
        frame = read(vid,i);
        frame = im2gray(frame); % convert to grayscale 
        frame = double(frame); % convert to double 
        mat_vid = mat_vid + frame;
    end 

    mat_vid_avg = mat_vid ./ n_vid; 
    sum_frame = sum(mat_vid_avg, "all"); % sum of all pixel intensities

    % normalisation step to correct for possible photobleaching over time 
    corr_fac = sum_ref / sum_frame; 
    fac_array(j) = corr_fac;
    corr_frame = mat_vid_avg .* corr_fac; 

    chck = sum(corr_frame, "all")/ sum_ref; %check - this should be ~1
    chck_array(j) = chck; 

    % INTENSITY PROFILE - normalisation of each datapoint against reference data (0 min)
    norm_frame = corr_frame ./ mat_ref_avg;
    avg_norm_frame = mean(norm_frame); % averaging each column

    % INTENSITY GRADIENT 
    di = avg_norm_frame; % analysing whole region of frame
    dx = [1:size(2)]./conv_fac; % convert pixels to mm
    p = polyfit(dx,di,1); % assume linear fit 
    grad = p(1); % gradient 
    grad_array(j) = grad; 

    % find elapsed time 
    file_info = dir([folder_name '/' file]);
    datenum_file = datevec(file_info.datenum); 
    t_file = datenum_file(4)*60 + datenum_file(5) + datenum_file(6)/60; % time in mins
    
    t = t_file - t_ref; 
    t_array(j) = t; 

    % plot intensity profiles 
    plot(avg_norm_frame, 'DisplayName', [num2str(t,'%.0f') 'mins'], LineWidth=0.8);
    hold on 

end 

% format plot 
axis tight 
legend % legend represents elapsed time 
xlabel("distance in x-direction (pix)"); ylabel("normalised intensity"); 

% sense check 
fac_array
chck_array

%% CURVE FIT - ESTIMATING THERMOPHORESIS CHARACTERISTIC TIME 
%  Fit equation: 
%      Y = a - b*exp(-X/c)
%  Data for curve fit:
%      X Input : time (s)
%      Y Output : intensity gradient wrt distance across sample channel (dc/dx)
%      g : intial guess
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.


% user-defined inputs
X = t_array; % time 
Y = grad_array; % gradient 
g = [0.03 0.03 5]; %intial guess values 

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

% plot grad-time curve
figure 
plot(t_array, grad_array, 'ko'); % data points
hold on 
plot(XFit, YFit); % fitted points 

xlabel("time (min)", 'Interpreter', 'none'); 
ylabel("d(int)/dx (mm-1)", 'Interpreter', 'none');
legend('data','fitted')


