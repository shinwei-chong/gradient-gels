% SUMMARY: Script file to faciliate fluorescence thermometry using
% temperature-sensitive Rhodamine B dye. 
% Takes the .tif file of fluorescence microscopy images to generate a 
% temperature heat map using established temperature-fluorescence
% correlation curve. 

% INPUT:
% - reference temperature value 
% - file name of image data at reference temperature
% - file name of image data at unknown temperature conditions
% - coefficients of calibration curve equation
% - (formatting): microscope scale calibration 
% - (formatting): display temperature limits for heat map

% OUTPUT: 
% - heat map of temperature profile7
% - 1D temperature profile in x-direction (assume temperature variation
% in x-direction only)


% Written by: Shin Wei Chong
% Version 1.0, 27-Apr-2024

%%%%%%%%%%%%%%%%%

% housekeeping 
close all  
clear 
clc 

%% DEFINE USER INPUT 

% Measured reference (room) temperature 
T_ref = 21; % [degC]

% Image at reference temperature (uniform temperature conditions)
ref_file = '[file_name].tif';

% Image at unknown temperature (under applied temperature conditions)
file = '[file_name].tif';

% coefficients of temperature-intensity calibration curve 
% T = A0 + A1*I + A2*I^2 + A3*I^3
% T = predicted temperature, I = normalised intensity 
A0 = 118; 
A1 = -198; 
A2 = 155; 
A3 = -53;

% Microscope scale calibration (to present output results in desired units)
conv_fac = 1.55e3; % [pixel/mm]

% Temperature axis limits for heat map
T_low = 50; 
T_hi = 70;


%% IMAGE CORRECTION FOR GAUSSIAN BEAM EFFECT 

warning('off','all');

ref_tstack = Tiff(ref_file); % load ref image 
[H W] = size(ref_tstack.read()); % get image size [height width]
N_ref = length(imfinfo(ref_file)); % get number of frames in stack 


if N_ref == 1 % if only acquired 1 image frame 
    ref = ref_tstack.read(); 
    ref = double(im2gray(ref)); 

else % if take multiple frames for more robust analysis (account for fluctuations)
    ref_mat = zeros(H, W, N_ref); % initialise empty matrix 

    % combine all frames into 3D matrix 
    im = ref_tstack.read(); 
    ref_mat(:,:,1) = double(im2gray(im));

    for i = 2:N_ref
        ref_tstack.nextDirectory(); 
        im = ref_tstack.read(); 
        ref_mat(:,:,i) = double(im2gray(im));
    end 

    ref = mean(ref_mat,3);  % take average across stack

end 

% generate correction factor matrix 
avg_pix = mean(ref,"all"); % average pixel intensity across whole frame 
corr_fac = ref./ avg_pix; 

% apply correction factor to image 
corr_ref = ref./ corr_fac; 


%% NORMALISATION OF IMAGE (TAKEN AT UNKNOWN TEMPERATURE)

% find global average intensity at reference temperature
global_ref = mean(corr_ref,"all");

tstack = Tiff(file); % load file
[I J] = size(tstack.read()); % get image size [height width]
N = length(imfinfo(file)); % get number of frames in stack 
        
if N == 1 % if only acquired 1 image frame 
    frame = tstack.read(); 
    frame = double(im2gray(frame));

else % if take multiple frames for more robust analysis (account for fluctuations)
    mat = zeros(I, J, N); % initialise empty matrix 

    % combine all frames into 3D matrix 
    img = tstack.read(); 
    mat(:,:,1) = double(im2gray(img));

    for j = 2:N
        tstack.nextDirectory(); 
        img = tstack.read(); 
        mat(:,:,j) = double(im2gray(img));
    end 

    frame = mean(mat,3);    % take average across stack

end

% apply correction factor to image 
corr_frame = frame./ corr_fac; 


% find normalised intensity at T_ref using calibration curve equation
r = roots([A3 A2 A1 A0-T_ref]); % solve for all roots 
normI_ref = r(imag(r)==0) % only save real root

% pixel intensity at reference point of calibration curve (T = 22degC)
Iref = global_ref/normI_ref;

% normalise pixel intensity against reference @ T = 22degC
norm_mat = corr_frame / Iref; 

%% MAP TEMPERATURE PROFILE (USING CALIBRATION CURVE EQUATION)

% calculate temperature using calibration curve equation
predT = A0 + A1.*norm_mat + A2.*norm_mat.^2 + A3.*norm_mat.^3; 

% take average down column
% NOTE: in our case, temperature only varies in x-direction
dT_x = mean(predT,1); 
dT_x = dT_x';

figure 

subplot(2,1,1)
h = heatmap(predT, 'GridVisible', 'off', 'ColorLimits', [T_low T_hi],'Colormap', jet);
title('estimated temperature profile')
XLabels = (1:J)./conv_fac*1e3; customXLabels = string(XLabels); % custom x-axis tick marks
customXLabels(mod(XLabels,200)~=0) = " ";
h.XDisplayLabels = customXLabels;
YLabels = (1:I)./conv_fac*1e3; customYLabels = string(YLabels); % custom y-axis tick marks
customYLabels(mod(YLabels,200)~=0) = " ";
h.YDisplayLabels = customYLabels;

subplot(2,1,2)
plot((1:J)./conv_fac, dT_x); axis tight
xlabel('distance in x-direction (mm)'); ylabel('temperature (degC)');


