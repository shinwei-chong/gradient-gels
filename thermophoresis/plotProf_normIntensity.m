% SUMMARY: Script file to analyse tiff stack files acquired through
% micromanager for thermophoresis experiments 

% INPUT:
% - Tiff stack file
% - Microscope scale calibration factor 

% OUTPUT: 
% - plot of normalised intensity profile over time 

% WORKFLOW: 
% 1) correct image for photobleaching (by assuming the sum of pixel
% intensity across whole frame would remain constant over time) 
% 2) normalise each frame against frame @ 1 minute (slightly under 1 minute
% since application of temperature gradient)


% Written by: SWC
% Version 2.0, 24-May-2023

%%%%%%%%%%%%%%%%%%


% housekeeping 
close all 
clc 
clear  

%% DEFINE USER INPUT

% folder containing data files 
file_name = '/Volumes/PRJ-grad1/1. Thermophoresis - fluor NPs/6. Exp_600-100_100nmFlourPS+Triton/20230517_0.9A-1_thermophoresis_61mins_1/20230517_0.9A-1_thermophoresis_61mins_1_MMStack_Pos0.ome.tif';

conv_fac = 0.62; % microscope scale conversion factor - pix/µm

%% 

warning('off','all');

tstack = Tiff(file_name);

% image size [height, width]
[I J] = size(tstack.read());
% number of frames in stack
K = length(imfinfo(file_name));

ref = tstack.read(); 
tstack.nextDirectory(); 
ref1 = tstack.read();
ref1 = double(im2gray(ref1));

sum_ref = sum(ref1, 'all'); 

%% TIME-INTENSITY ANALYSIS

% initialise empty arrays
fac_array = zeros(1,K);
chck_array = zeros(1,K);
pix_array = zeros(K,J);

pix_array(1,:) = ones(1,J);

% disatance across frame
dist = [1:J]./conv_fac; % convert pixels to µm

t_array = 0:K-1; % assuming each image is 1 minute interval
grad_array = zeros(1,K);

for i = 2:K-1

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
%     plot(dist, avg_norm_img, 'DisplayName', [num2str(i-1) 'mins'], LineWidth=0.8);
    hold on


end

plot(dist, pix_array(1,:), LineWidth=0.8);

% format plot 
axis tight 
% legend % legend represents elapsed time 
xlabel("distance in x-direction (µm)"); ylabel("normalised intensity"); 

% sense check 
fac_array;
chck_array;

