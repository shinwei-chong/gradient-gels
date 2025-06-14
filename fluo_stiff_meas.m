% SUMMARY: Script file to faciliate fluorescence-based stiffness gradient
% characterisation
% Takes the .tif file of fluorescence microscopy images to calculate the
% stiffness profile based on established conentration-intensity and 
% intensity-stiffness correlation curves

% NOTES: 
% (1) analysis assumes stiffness is uniform in y-direction, so stiffness
% gradient is along x-direction
% (2) assumes the average of stiffness across the gradient corresponds to
% the initial concentration (i.e., mass conservation)
% (3) script written for two cases: FITC-GelMA (F-GM) and FITC-Gellan gum
% (F-GG). Need to manually switch cases to apply appropriate calibration
% equations

% Written by: Shin Wei Chong 
% Version 1.0, 14-Feb-2025

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% housekeeping
clear all 
clc 
close

%% define user input

% known distance of gradient 
x_dist = 1000; % [um]

% initial polymer concentration 
conc0 = 10; % [wt%]

%%%%%%%%%%%%%%%
% prompt user to select file 
[input_filename, input_path] = uigetfile('*.tif', 'Select image file');
if input_filename == 0
    disp ('No file selected.');
    return; 
end

% get file directory
full_input_path = fullfile(input_path, input_filename); 

% read image 
image = double(im2gray(imread(full_input_path)));
X_length = length(image); % x-distance (in pixels)
conv_fac = x_dist/ X_length; 
x_arr = (1:X_length) .* conv_fac; 

img_int_prof = mean(image, 1); % average down each column
subplot(3,1,1); plot(x_arr, img_int_prof); ylabel('pixel intensity')


%% normalise image against initial conditions 

% calculate average intensity of whole frame 
pix_avg = mean(image, "all"); 

% evaluate normalised fluorescence intensity at initial polymer 
% concentration 
% F-GM intensity-concentration calibtraion: normI = 0.1164 * conc [wt%]
% F-GG intensity-concentration calibtraion: normI = 0.8310 * conc [wt%]

% normI_ref = 0.1164*conc0 %FGM
normI_ref = 0.8310 * conc0 %FGG

% calculate corresponding absolute intensity at initial polymer
% concentration 
I_ref = pix_avg / normI_ref; 

% normalise image against initial intensity
norm_img = image ./ I_ref;

norm_int_prof = mean(norm_img, 1); % average down each column
subplot(3,1,2); plot(x_arr, norm_int_prof); ylabel('norm. pixel intensity')
hold on; plot([1, x_arr(end)], [1,1]);


%% infer stiffness 

% ==== FGM ====
% F-GM conc-stiffness correlation: E [kPa] = 6.3527c [wt%] - 18.572

% c = norm_int_prof ./ 0.1164; % apply intensity-concentration curve
% E = 6.3527.*c - 18.572; E=E'; % apply concentration-stiffness curve


% ==== FGG ====
% F-GG conc-stiffness correlation: E [kPa] = 7.9732c [wt%] - 3.7833

c = norm_int_prof ./ 0.831; % apply intensity-concentration curve
E = 7.9732.*c -3.7833; E=E'; % apply concentration-stiffness curve

subplot(3,1,3); plot(x_arr, E); ylabel('stiffness (kPa)'); 
xlabel('distance (µm)')


