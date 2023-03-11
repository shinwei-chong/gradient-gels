% SUMMARY: script file to estimate temperature profile of a
% microfluidic system based on temperature-dependent fluorescence

% INPUT:
% - folder name of image data at unknown temperature conditions
% - folder name of image data at reference temperature
% - measured reference temperature
% - image size 
% - normalisation factor matrix (.mat file, generated from: gaussianTIF.m OR gaussianAVI.m)
% - coefficients of calibration curve 

% OUTPUT: 
% - heat map of temperature profile (default color limits: 22-55 degC)
% - variation in temperature in x-direction (assume temperature variation
% in x-direction only)

% Written by: SWC
% version 1.0, 02-Jan-2023
 
%%%%%%%%%%

% housekeeping
close all
clc
clear

%% DEFINE USER INPUT 

% image data of system at unknown temperature
% data_file_name = 'Z:\2. Temperature characterisation - RhoB\4. device characterisation\20230119_600-100_systematicTest_Rep2\Test2_100-100_T12.avi';

data_file_name = fullfile('/Volumes/PRJ-grad1',...
    '2. Temperature characterisation - RhoB',...
    '4. device characterisation/20230117_600-100_fixedposition',...
    'Test1_7000us_30fps_T1.avi');

% image data of system at reference (room) temperature 
% ref_file_name ='Z:\2. Temperature characterisation - RhoB\4. device characterisation\20230119_600-100_systematicTest_Rep2\Test2_100-100_ref.avi';

ref_file_name = fullfile('/Volumes/PRJ-grad1',...
    '2. Temperature characterisation - RhoB',...
    '4. device characterisation/20230117_600-100_fixedposition',...
    'Test1_ref2_7000us_30fps_22-7C.avi');

% measured reference temperature (degC)
T_ref = 22.7;

% image size [height,width]
size = [1216,1936];

% mat file of normlisation factor
% norm_mat_name = 'Z:\2. Temperature characterisation - RhoB\4. device characterisation\20230119_600-100_systematicTest_Rep2\test2_normfac.mat';


norm_mat_name = fullfile('/Volumes/PRJ-grad1',...
    '2. Temperature characterisation - RhoB',...
    '4. device characterisation/20230117_600-100_fixedposition',...
    'Test1_ref1.mat');



% coefficients of temperature-intensity calibration curve 
% T = A0 + A1*I + A2*I^2 + A3*I^3
% T = predicted temperature, I = normalised intensity 
A0 = 119; 
A1 = -199; 
A2 = 155; 
A3 = -53; 

%% find average pixel intensity at known, uniform temperature (for calibration) 

%load file 
v_ref = VideoReader(ref_file_name);
n_ref = v_ref.NumFrames; %total number of frames 

mat_ref = zeros(size(1), size(2)); %create empty matrix 

% sum pixel intensities across all frames
for i = 1:n_ref
    im = read(v_ref,i); 
    im = im2gray(im);
    im = double(im); %convert to double
    mat_ref = mat_ref + im; 
end

% find average intensity of each pixel across all frames 
mat_ref_avg = mat_ref./n_ref; 

% correction for gaussian beam effects
norm_fac = load(norm_mat_name); 
norm_fac = norm_fac.norm_fac; %load matrix of correction factor 

% divide original pixel matrix by correction factor matrix
corr_mat_ref_avg = mat_ref_avg./ norm_fac;

%check correction quality 
% figure
subplot(2,2,1)
s1 = surf(mat_ref_avg); s1.EdgeColor = 'none'; 
title('reference image - uncorrected');
% figure
subplot(2,2,3)
s2 = surf(corr_mat_ref_avg); s2.EdgeColor = 'none';
title('reference image - corrected');

% find global average intensity 
global_ref = mean(corr_mat_ref_avg,"all")


%% normalisation step (unknown temperature system)

%load file 
v = VideoReader(data_file_name);
n = v.NumFrames; %total number of frames 
  
mat = zeros(size(1), size(2)); %create empty matrix 

% sum pixel intensities across all frames
for j = 1:n
    im = read(v,j); 
    im = im2gray(im);
    im = double(im); %convert to double
    mat = mat + im; 
end

% find average intensity of each pixel across all frames 
mat_avg = mat./n; 

% correction for gaussian beam effects
corr_mat_avg = mat_avg./ norm_fac;

% find normalised intensity at T_ref using calibration curve equation
r = roots([A3 A2 A1 A0-T_ref]); % solve for all roots 
normI_ref = r(imag(r)==0) % only save real root

% pixel intensity at reference point of calibration curve (T = 22degC)
Iref = global_ref/normI_ref

% normalise pixel intensity to reference @ T = 22degC
norm_mat = corr_mat_avg / Iref; 


%% mapping temperature profile (using calibration curve equation)

predT = A0 + A1.*norm_mat + A2.*norm_mat.^2 + A3.*norm_mat.^3; 

% plot heatmap 
% figure 
% h = heatmap(predT, 'GridVisible', 'off', 'ColorLimits', [22 40], 'Colormap', jet);

subplot(2,2,2)
h = heatmap(predT, 'GridVisible', 'off', 'ColorLimits', [30 50],'Colormap', jet);
title('estimated temperature profile')
XLabels = 1:size(2); customXLabels = string(XLabels); % custom x-axis tick marks
customXLabels(mod(XLabels,200)~=0) = " ";
h.XDisplayLabels = customXLabels;
YLabels = 1:size(1); customYLabels = string(YLabels); % custom y-axis tick marks
customYLabels(mod(YLabels,200)~=0) = " ";
h.YDisplayLabels = customYLabels;

% plot temperature variation along x-direction
dT_x = mean(predT,1);
% figure
subplot(2,2,4)
plot(dT_x)
xlabel('distance in x-direction (pix)'); ylabel('temperature (degC)');


