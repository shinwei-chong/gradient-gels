% SUMMARY: script file to generate a matrix of intensity correction matrix
% from reference image dataset (.avi format)
% [active protocol]

% INPUT: 
% - file name (single avi file)
% - image size

% OUTPUT: 
% - 3D plot of intensity profile
% - 2D plot of intensity profile (along x-direction of image)
% - intensity correction factor matrix (NEED TO MANUALLY SAVE THIS AS .MAT
% FILE FOR USE IN DATA ANALYSIS!!)

clear 
close all
clc

%% DEFINE USER INPUT

% for windows
file = 'Z:\2. Temxperature characterisation - RhoB\4. device characterisation\20230119_600-100_systematicTest_Rep2\Test2_100-100_ref.avi';

% for mac
% file = fullfile('/Volumes/PRJ-grad1',...
%     '2. Temperature characterisation - RhoB',...
%     '4. device characterisation/20230119_600-100_systematicTest_Rep2',...
%     'Test3_100-100_ref.avi');

size = [1216,1936];

%% read frames

v = VideoReader(file); 
nframes = v.NumFrames; 

for i = 1:nframes
    im = read(v,i);
%     im = im2gray(im);
    mat(:,:,i)=double(im);
end

%% calculate and plot image - average across all frames

avg_mat = mean(mat,3);
figure
surf(avg_mat,'FaceAlpha',0.2,'EdgeAlpha',0.8,'EdgeColor','interp','LineWidth',0.5)
colorbar

%% generate and plot correction factor matrix 

avg_pix = mean(mat,"all"); % average pixel intensity across whole image
norm_fac = avg_mat./ avg_pix;
figure
surf(norm_fac,'FaceAlpha',0.2,'EdgeAlpha',0.8,'EdgeColor','interp','LineWidth',0.5)
colorbar; caxis([0.8 1.2])

figure
norm_fac_avg = mean(norm_fac,1);
plot(norm_fac_avg); 
xlabel('x-direction'); ylabel('normalised intensity')


