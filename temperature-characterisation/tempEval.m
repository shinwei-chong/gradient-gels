% SUMMARY: Script file to generate to predict the temperature profile
% of a microfluidic system based on temperature-dependent fluorescence
% (used for data collected using micromanager - saved as tif stack)

% INPUT:
% - file name of image data at unknown temperature conditions
% - file name of image data at reference temperature
% - measured reference temperature
% - coefficients of calibration curve 

% OUTPUT: 
% - panel figure
%       i) surface plot of uncorrected reference image 
%       ii) surface plot of corrected reference image 
%       iii) surface plot of correction factor (wrt average pixel
%       intensity)
%       iv) 1D profile of correction factor (variation in x-direction)
% - heat map of temperature profile
% - 1D temperature profile in x-direction (assume temperature variation
% in x-direction only)


% Written by: SWC
% Version 1.0, 11-Mar-2023

%%%%%%%%%%%%%%%%%%

% housekeeping 
close all 
clear 
clc 

%% DEFINE USER INPUT 

% Measured reference (room) temperature 
T_ref = 22.3; % [degC]

% Image at reference temperature (no applied temperature conditions)
ref_file = '/Volumes/PRJ-grad1-1/2. Temperature characterisation - RhoB/5. 1000-150/20230309_1000-150_CHCHC_device1/20230309_CHC_LHS_dT2_ref_2/20230309_CHC_LHS_dTx_ref_2_MMStack_Pos0.ome.tif'; 

% Image at unknown temperature (under applied temperature conditions)
file = '/Volumes/PRJ-grad1-1/2. Temperature characterisation - RhoB/5. 1000-150/20230309_1000-150_CHCHC_device1/100min_CHC_RHS_dT2/100min_CHC_RHS_dT2_MMStack_Pos0.ome.tif';

% coefficients of temperature-intensity calibration curve 
% T = A0 + A1*I + A2*I^2 + A3*I^3
% T = predicted temperature, I = normalised intensity 
A0 = 119; 
A1 = -199; 
A2 = 155; 
A3 = -53;



%% IMAGE CORRECTION FOR GAUSSIAN BEAM EFFECT 

warning('off','all');

ref_tstack = Tiff(ref_file); % load ref image 
[H W] = size(ref_tstack.read()); % get image size [height width]
N_ref = length(imfinfo(ref_file)); % get number of frames in stack 

if N_ref == 1
    ref = ref_tstack.read(); 
    ref = double(im2gray(ref));
    
%     % plot distribution of light intensity profile
%     figure
%     surf(ref,'FaceAlpha',0.2,'EdgeAlpha',0.8,'EdgeColor','interp','LineWidth',0.5)
%     colorbar

else 
    ref_mat = zeros(H, W, N_ref); % initialise empty matrix 

    % combine all frames into 3D matrix 
    im = ref_tstack.read(); 
    ref_mat(:,:,1) = double(im2gray(im));

    for i = 2:N_ref
        ref_tstack.nextDirectory(); 
        im = ref_tstack.read(); 
        ref_mat(:,:,i) = double(im2gray(im));
    end 

    ref = mean(ref_mat,3);
    
%     % plot distribution of light intensity profile
%     figure
%     surf(ref,'FaceAlpha',0.2,'EdgeAlpha',0.8,'EdgeColor','interp','LineWidth',0.5)
%     colorbar

end 

% generate correction factor matrix 
avg_pix = mean(ref,"all"); % average pixel intensity across whole frame 
corr_fac = ref./ avg_pix; 

% apply correction factor to image 
corr_ref = ref./ corr_fac; 

% check image correction quality 
figure 

subplot(2,2,1) % uncorrected reference image
s1 = surf(ref); s1.EdgeColor = 'none'; 
title('reference image - uncorrected');

subplot(2,2,3) % corrected reference image
s2 = surf(corr_ref); s2.EdgeColor = 'none';
title('reference image - corrected');

subplot(2,2,2) % surface plot of correction factor 
surf(corr_fac, 'FaceAlpha',0.2,'EdgeAlpha',0.8,'EdgeColor','interp','LineWidth',0.5)
colorbar; caxis([0.8 1.2])
title('correction factor')

subplot(2,2,4) % 2D plot of correction factor - variation in x-direction
norm_fac_avg = mean(corr_fac,1);
plot(norm_fac_avg); axis tight
xlabel('x-direction'); ylabel('normalised intensity (@ uniform temp)');
title('correction factor - 2D variation in x-direction')


%% NORMALISATION OF IMAGE (TAKEN AT UNKNOWN TEMPERATURE)

% find global average intensity at reference temperature
global_ref = mean(corr_ref,"all");

tstack = Tiff(file); % load file
[I J] = size(tstack.read()); % get image size [height width]
N = length(imfinfo(file)); % get number of frames in stack 
        
if N == 1
    frame = tstack.read(); 
    frame = double(im2gray(frame));

else 
    mat = zeros(I, J, N); % initialise empty matrix 

    % combine all frames into 3D matrix 
    img = tstack.read(); 
    mat(:,:,1) = double(im2gray(img));

    for j = 2:N
        tstack.nextDirectory(); 
        img = tstack.read(); 
        mat(:,:,j) = double(im2gray(img));
    end 

    frame = mean(mat,3);

end

% apply correction factor to image 
corr_frame = frame./ corr_fac; 


% find normalised intensity at T_ref using calibration curve equation
r = roots([A3 A2 A1 A0-T_ref]); % solve for all roots 
normI_ref = r(imag(r)==0) % only save real root

% pixel intensity at reference point of calibration curve (T = 22degC)
Iref = global_ref/normI_ref

% normalise pixel intensity against reference @ T = 22degC
norm_mat = corr_frame / Iref; 

%% MAP TEMPERATURE PROFILE (USING CALIBRATION CURVE EQUATION)

predT = A0 + A1.*norm_mat + A2.*norm_mat.^2 + A3.*norm_mat.^3; 
dT_x = mean(predT,1);

figure

subplot(2,1,1)
h = heatmap(predT, 'GridVisible', 'off', 'ColorLimits', [min(dT_x)-5 max(dT_x)+5],'Colormap', jet);
% h = heatmap(predT, 'GridVisible', 'off', 'ColorLimits', [20 50],'Colormap', jet);
title('estimated temperature profile')
XLabels = 1:J; customXLabels = string(XLabels); % custom x-axis tick marks
customXLabels(mod(XLabels,200)~=0) = " ";
h.XDisplayLabels = customXLabels;
YLabels = 1:I; customYLabels = string(YLabels); % custom y-axis tick marks
customYLabels(mod(YLabels,200)~=0) = " ";
h.YDisplayLabels = customYLabels;

% figure
subplot(2,1,2)
plot(dT_x); axis tight
xlabel('distance in x-direction (pix)'); ylabel('temperature (degC)');



