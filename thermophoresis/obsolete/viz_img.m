% script file to correct for Gaussian beam effect of a single image frame 

ref_file = '/Volumes/PRJ-grad1/1. Thermophoresis - fluor NPs/5. 5-channel_V1_600-100/CHCHC_1%_100nm_fluorPS/20230323_2_600-100_CHCHC_Device1_dT4_1%_100nmPS/4gradT_ref_22C/4gradT_ref_22C_MMStack_Pos0.ome.tif';

file = '';

warning('off','all');

ref_tstack = Tiff(ref_file); % load ref image 
ref = ref_tstack.read(); 
ref = double(im2gray(ref));

% generate correction factor matrix 
avg_pix = mean(ref,"all"); % average pixel intensity across whole frame 
corr_fac = ref./ avg_pix; 

tstack = Tiff(file); % load file
frame = tstack.read(); 
frame = double(im2gray(frame));

% apply correction factor to image 
corr_frame = frame./ corr_fac; 

figure


imshow(corr_frame./ 2^16);
