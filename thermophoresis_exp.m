% SUMMARY: Script file to for time-lapse analysis for thermophoeresis 
% experiments. 
% Takes .tiff stack and plot intensity profile at each time point.  

% INPUT:
% - Tiff stack file
% - Microscope scale calibration factor 

% OUTPUT: 
% - plot of normalised intensity profile over time 

% WORKFLOW: 
% 1) correct image for photobleaching (by assuming the sum of pixel
% intensity across whole frame would remain constant over time) 
% 2) normalise each frame against frame @ 1 minute 


% Written by: Shin Wei Chong
% Version 1.0, 24-May-2023

%%%%%%%%%%%%%%%%%%


% housekeeping 
close all 
clc 
clear  

%% DEFINE USER INPUT

% image stack
file_name = '[file name].tif';

% microscope sacle conversion factor
conv_fac = 1.55; % [pix/µm]

%% IMAGE CORRECTION

warning('off','all');

tstack = Tiff(file_name);

% image size [height, width]
[I J] = size(tstack.read());
% number of frames in stack
K = length(imfinfo(file_name));

ref = tstack.read(); 
ref1 = double(im2gray(ref));

sum_ref = sum(ref1, 'all'); 

%% TIME-INTENSITY ANALYSIS

% initialise empty arrays
fac_array = zeros(1,K);
chck_array = zeros(1,K);
pix_array = zeros(K,J);

pix_array(1,:) = ones(1,J); % assume no gradinet at start

% disatance across frame
dist = [1:J]./conv_fac; % convert pixels to µm

% loop through each frame in stack 
for i = 2:K

    tstack.nextDirectory(); 
    img = tstack.read(); 
    img = double(im2gray(img));

    % normalisation to correct for photobleaching 
    sum_img = sum(img,"all"); % get sum of pixel intensities 
    fac = sum_ref /sum_img; 
    fac_array(i) = fac;

    corr_img = img.*fac; 

    chck = sum(corr_img,"all")/ sum_ref; %check - this should be ~1
    chck_array(i) = chck;

    % INTENSITY PROFILE - normalise image against reference
    norm_img = corr_img./ref1;
    avg_norm_img = mean(norm_img); % get avg value of each column
    pix_array(i,:) = avg_norm_img; 


    % plot intensity profiles 
    plot(dist, avg_norm_img, LineWidth=0.8);
%     plot(dist, avg_norm_img, 'DisplayName', [num2str(i-1) 'mins'],
%     LineWidth=0.8); % if want plot legend
    
    hold on

    pause(0.1)


end

plot(dist, pix_array(1,:), LineWidth=0.8);

% format plot 
axis tight 
% legend % legend represents elapsed time 
xlabel("distance in x-direction (µm)"); ylabel("normalised intensity"); 

% sense check 
fac_array;
chck_array;
% pix_array = pix_array';
