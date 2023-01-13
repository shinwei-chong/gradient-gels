% SUMMARY: script file to generate a matrix of normalisation factor to
% correct for Gaussian beam effect of microscope light source
% [for processing AVI files]

% INPUT:
% - folder name 
% - image size 

% OUTPUT: 
% - 3D plot of pixel intensity distribution 
% - matrix of normalisation factor (matrix size = image size)
% - 2D plot of pixel intensity distribution along x-direction 

% Written by: SWC
% version 1.0, 31-Dec-2022

%%%%%%%%%%


% housekeeping
clear 
close all 
clc

% DEFINE USER INPUT 
folder_name = fullfile('/Volumes/PRJ-grad1',...
    '2. Temperature characterisation - RhoB',...
    'intensitiy normalisation - uniform samples',...
    '20221124_plain_rhoB_1e-1mM_olympus10x');
size = [1216,1936];


%% read folder
a = dir([folder_name '/*avi']); 
N = length(a); % number of images in folder 

mat = zeros(size(1), size(2),N); % generate empty matrix 

for i = 1:N

    file = a(i).name; 
    v = VideoReader([folder_name '/' file]);
%     nframes = v.NumFrames; 
    im = read(v,1); % presumes there is only 1 frame 
    mat(:,:,i) = double(im); % add to matrix
end 

%% calculate and plot average pixel intensity
avg_mat = mean(mat,3); 
figure
surf(avg_mat,'FaceAlpha',0.2,'EdgeAlpha',0.8,'EdgeColor','interp','LineWidth',0.5)
colorbar

%% generate normalisation factor matrix
avg_pix = mean(mat,"all"); % average pixel intensity across whole image
norm_fac = avg_mat./ avg_pix;
figure
surf(norm_fac,'FaceAlpha',0.2,'EdgeAlpha',0.8,'EdgeColor','interp','LineWidth',0.5)
colorbar; caxis([0.8 1.2])

figure
norm_fac_avg = mean(norm_fac,1);
plot(norm_fac_avg); 
xlabel('x-direction'); ylabel('normalised intensity')







