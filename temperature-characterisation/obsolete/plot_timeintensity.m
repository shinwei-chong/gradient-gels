% SUMAMARY: script file to compute and visualise average pixel intensity of
% a region over time 
% [for Rhodamine B experiments]

% WORKFLOW:
% 1) crop region of interest 
% 2) calculate average intensity of ROI
% 3) repeat for successive images over time and plot avg-intensity vs. time
% curve

% REQUIRED USER INPUT:
% - image folder name 
% - image crop size 

% Written by: Shin Wei Chong 
% Project: thermophoretic approach for gradient patterning of substrates
% version 1.0, 07-Jul-2022


% -------------------------------



% housekeeping 
close all 
clear 
clc

% load folder
folder_name = fullfile('../',...
    '2. Rhodamine B',...
    '20220707_RhoB_Calibration_shorttest'); % INPUT FOLDER NAME
% count number of images to analyse
a = dir([folder_name '/*jpg']); 
N = length(a);

% define image crop size
% syntax: [x-coord of bottom left point, y-coord of bottom left point,
% width, height]
crop_size = [1512 984 960 870]; % CHANGE CROP SIZE


% retrieve first image as reference image (t=0)
ref_name = a(1).name; 
ref = imread([folder_name '/' ref_name]); 
ref = imcrop(ref, crop_size); 
ref = double(im2gray(ref)); % convert to grayscale
avg_ref = mean(ref, "all"); % get average of pixel intensities 

% get experiment start time (assume first file in folder is t=0)
t0 = str2double(ref_name(9:10))*3600 +...
    str2double(ref_name(11:12))*60 +...
    str2double(ref_name(13:14)); 

% create empty array
pix_arr = zeros(1,N);
t_arr = zeros(1,N);

% load images to analyse
for i = 1:N

    % get image file name
    file = a(i).name;  
    img = imread([folder_name '/' file]);
    img = imcrop(img, crop_size);
    img = double(im2gray(img)); % convert to grayscale

    % get normalised average intensity of cropped region
    avg_pix = mean(img,"all"); 
    norm_pix = avg_pix/avg_ref;
    pix_arr(i) = norm_pix;

    % get experiment elapsed time 
    t_img = str2double(file(9:10))*3600 +...
        str2double(file(11:12))*60 +...
        str2double(file(13:14)); % time of image 
    t = t_img - t0; 
    t_arr(i) = t; 

end 

% plot 
yyaxis left 
plot(t_arr, pix_arr, 'bo', 'LineWidth',0.7);
xlabel("time (s)");
ylabel("average pixel intensity (normalised)");


hold on 
T_arr = [23.3 24.8 27.1 30.1 33.9 36.3 37.9 38.6 39.3];
yyaxis right
plot(t_arr([1:4,6,8,10,12,14]), T_arr, 'r+');
ylabel("temperature (degC)")
