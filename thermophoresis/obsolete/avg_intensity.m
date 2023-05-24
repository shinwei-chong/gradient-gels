% SUMAMARY: script file to find the average intensity of an input image
% frame 


% WORKFLOW:
% 1) crop region of interest 
% 2) calculate average intensity of ROI


% REQUIRED USER INPUT:
% - file name 
% - image crop size 

% Written by: Shin Wei Chong 
% Project: thermophoretic approach for gradient patterning of substrates
% version 1.0, 17-Aug-2022


% -------------------------------



% housekeeping 
close all 
clear 
% clc

% load file and read image
file_name = fullfile('../',...
    '2. Rhodamine B',...
    '560nm_350ms_15min.mj2'); % INPUT IMAGE NAME

v = VideoReader(file_name);
im = read(v);
% whos im
im = double(im);
figure 
imshow(im,[0 4095]) %0-255 for 8-bit; 0-4095 for 12-bit; 0-65535 for 16-bit


% define image crop size
% syntax: [x-coord of bottom left point, y-coord of bottom left point,
% width, height]
crop_size = [620 352 512 512]; % CHANGE CROP SIZE
im_crop = imcrop(im, crop_size); 

figure 
imshow(im_crop,[0 4095]) %0-255 for 8-bit; 0-4095 for 12-bit; 0-65535 for 16-bit



avg_int = mean(im_crop, "all") % get average of pixel intensities 


