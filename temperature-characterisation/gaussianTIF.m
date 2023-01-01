% SUMMARY: script file to generate a matrix of normalisation factor to
% correct for Gaussian beam effect of microscope light source
% [for processing tiff files]

% INPUT:
% - folder name 
% - image size 

% OUTPUT: 
% - 2D plot of light distribution 
% - matrix of normalisation factor (matrix size = image size)

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
    '20221219_1mM_rhoB_coverslip_olympus10x');
size = [1216,1936];

%% read folder
a = dir([folder_name '/*tif']); 
N = length(a); % number of images in folder 

mat = zeros(size(1), size(2),N); % generate empty matrix 

% sum intensity of each pixel 
for i = 1:N
    file = a(i).name; % get file name
    im = imread([folder_name '/' file]); % read image file 
    mat(:,:,i) = double(im); % add to matrix
end

%% calculate and plot average pixel intensity
avg_mat = mean(mat,3); 
% figure
% surf(avg_mat,'FaceAlpha',0.2,'EdgeAlpha',0.8,'EdgeColor','interp','LineWidth',0.5)
% colorbar

%% generate normalisation factor matrix
avg_pix = mean(mat,"all"); % average pixel intensity across whole image
norm_fac = avg_mat./ avg_pix;
% figure
% surf(norm_fac,'FaceAlpha',0.2,'EdgeAlpha',0.8,'EdgeColor','interp','LineWidth',0.5)
% colorbar








