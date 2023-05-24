% SUMAMARY: script file to perform normalisation of pixel intensity with
% respect to reference image
% developed for single gradient (Alex's thesis)

% WORKFLOW:
% 1) image correction so that the sum of pixel intensity is the same across
% each image (account for decreasing brightness due to photobleaching)
% 2) normalise pixel intensity of image relative to reference image (t=0)
% 3) compute average intensity of each column 
% 4) plot the intensity profile for each image 

% REQUIRED USER INPUT:
% - image folder name 
% - image crop size 

% Written by: Shin Wei Chong 
% Project: thermophoretic approach for gradient patterning of substrates
% version 1.0, 02-Jul-2022


% -------------------------------



% housekeeping 
close all 
clear 
clc

% load folder
% NOTE: this assumes folder is in the same directory as code file.
% Otherwise, need to ammend filepath description to map to the correct 
% directory containing the folder 
folder_name = fullfile('../',...
    '1. Fluorescent nanoparticles/',...
    '24-Aug 100-100 50nm 1%/'); % INPUT FOLDER NAME
% count number of images to analyse
a = dir([folder_name '/*jpg']); 
N = length(a); % total number of files (including ref)

% define image crop size
% syntax: [x-coord of upper left point, y-coord of upper left point,
% width, height]
crop_size = [0 1158 4000 930]; % CHANGE CROP SIZE
% crop_size = [0 0 4000 3000];

% load reference image (t=0)
ref_name = a(1).name; % assume this is always the first image in the folder
ref = imread([folder_name '/' ref_name]); 
ref = imcrop(ref, crop_size); 
ref = double(im2gray(ref)); % convert to grayscale


sum_ref = sum(ref, "all"); % get sum of pixel intensities 

% -- for hour:min:sec format
t_ref = str2double(ref_name(9:10))*3600 +...
    str2double(ref_name(11:12))*60 +...
    str2double(ref_name(13:14)); % get time of ref image taken (in secs)

% -- for hour:min format
% t_ref = str2double(ref_name(9:10))*3600 +...
%     str2double(ref_name(11:12))*60; % get time of ref image taken (in secs)


% for sense check
fac_array = zeros(1,N);
chck_array = zeros(1,N);

% load images to analyse
for i = 1:N

    % get image file name
    file = a(i).name;  
    img = imread([folder_name '/' file]);
    img = imcrop(img, crop_size);
    img = double(im2gray(img)); % convert to grayscale

    % determine image correction factor (assumes sum of intensity is
    % constant across images; in other words, total number of fluorescent
    % particles in frame remains constant throughout experiment, only
    % change is their position within the frame due to thermophoretic
    % movement)
    sum_img = sum(img,"all"); % get sum of pixel intensities 
    fac = sum_ref / sum_img; 
    fac_array(i) = fac;

    % image correction 
    corr_img = img.*fac; 
    
    chck = sum(corr_img, "all")/ sum_ref; %check - this should be 1
    chck_array(i) = chck; 

    % normalise image 
    norm_img = corr_img./ ref;
    avg_norm_img = mean(norm_img); % get avg value of each column 

    % find elapsed time of current image
    % -- for hour:min:sec format
    t_img = str2double(file(9:10))*3600 +...
            str2double(file(11:12))*60 +...
            str2double(file(13:14)); % get time of image taken (in seconds)
    
    % -- for hour:min format
%     t_img = str2double(file(9:10))*3600 +...
%             str2double(file(11:12))*60; % get time of ref image taken (in secs)
    
    % find experiment elapsed time 
    t = t_img - t_ref; 
    
    plot(avg_norm_img, 'DisplayName', num2str(t), LineWidth=0.8); 
    hold on 
    

end 

% plot features
axis tight
legend % legend represents the elapsed time
xlabel("distance in x-direction"); ylabel("normalised intensity"); 


% show correction factor calculated for each image
fac_array
chck_array

figure 
imshow(img,[0 255])
