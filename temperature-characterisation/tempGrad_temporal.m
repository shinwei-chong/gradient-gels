% SUMMARY: Script file to predict the temperature profile for each frame in
% a tif stack file and plot the profile over time

% INPUT:
% - file name of tif stack file  
% - file name of image data at reference temperature
% - measured reference temperature
% - coefficients of calibration curve 

% OUTPUT: 
% - plot of temperature profile (T-x curve) over time 
% - plot of temperature gradient over time

% Written by: SWC
% Version 1.0, 12-Mar-2023

% COMMENT (24-May-2023): code is outdated with current image acquisiation
% workflow - needs update!

%%%%%%%%%%%%%%%%%%



% housekeeping 
close all 
clear 
clc

%% DEFINE USER INPUT

% Measured reference (room) temperature 
T_ref = 22.3; % [degC]

% Image at reference temperature (no applied temperature conditions)
ref_file = '/Volumes/PRJ-grad1-1/2. Temperature characterisation - RhoB/5. 1000-150/20230309_1000-150_HCHCH_device2/20230309_HCH_LHS_dT10_ref/20230309_4x_HCH_LHS_2_ref_MMStack_Pos0.ome.tif';

% Image stack at under applied temperature conditions
file = '/Volumes/PRJ-grad1-1/2. Temperature characterisation - RhoB/5. 1000-150/20230309_1000-150_HCHCH_device2/20230309_HCH_LHS_dT10/20230309_4x_HSH_LHS_2_MMStack_Pos0.ome.tif';

% Microscope scale calibration
conv_fac = 0.62e3; % [pix/mm]

% coefficients of temperature-intensity calibration curve 
% T = A0 + A1*I + A2*I^2 + A3*I^3
% T = predicted temperature, I = normalised intensity 
A0 = 119; 
A1 = -199; 
A2 = 155; 
A3 = -53;


%% IMAGE CORRECTION FOR GAUSSIAN BEAM EFFECT 

warning('off','all');

ref_tstack = Tiff(ref_file); % load ref image 
[H W] = size(ref_tstack.read()); % get image size [height width]
N_ref = length(imfinfo(ref_file)); % get number of frames in stack 

% read image
if N_ref == 1
    ref = ref_tstack.read(); 
    ref = double(im2gray(ref));

else 
    ref_mat = zeros(H, W, N_ref); % initialise empty matrix 

    % combine all frames into 3D matrix 
    im = ref_tstack.read(); 
    ref_mat(:,:,1) = double(im2gray(im));

    for i = 2:N_ref
        ref_tstack.nextDirectory(); 
        im = ref_tstack.read(); 
        ref_mat(:,:,i) = double(im2gray(im));
    end 

    ref = mean(ref_mat,3);
   
end 

% generate correction factor matrix 
avg_pix = mean(ref,"all"); % average pixel intensity across whole frame 
corr_fac = ref./ avg_pix; 

% apply correction factor to image 
corr_ref = ref./ corr_fac; 

%% TEMPERATURE PROFILING (USING CALIBRATION CURVE EQUATION)

% find global average intensity at reference temperature
global_ref = mean(corr_ref,"all");

tstack = Tiff(file); % load file
[I J] = size(tstack.read()); % get image size [height width]
N = length(imfinfo(file)); % get number of frames in stack 
        
% find normalised intensity at T_ref using calibration curve equation
r = roots([A3 A2 A1 A0-T_ref]); % solve for all roots 
normI_ref = r(imag(r)==0) % only save real root

% pixel intensity at reference point of calibration curve (T = 22degC)
Iref = global_ref/normI_ref

% initialise empty matrix 
dT_x = zeros(N,J); 


for j = 1:N-1

    frame = tstack.read(); 
    frame = double (im2gray(frame));

    % apply correction factor to image 
    corr_frame = frame./ corr_fac; 

    % normalise pixel intensity against reference @ T = 22degC
    norm_mat = corr_frame / Iref; 

    predT = A0 + A1.*norm_mat + A2.*norm_mat.^2 + A3.*norm_mat.^3; 
    dT_x(j,:) = mean(predT,1);

    tstack.nextDirectory()

end 

%% PLOT FULL TEMPERATURE PROFILE OVER TIME 

figure 
hold on 

for t = 1:N
    plot(dT_x(t,:), 'DisplayName', [num2str(t-1) 'mins']);
end

% format plot 
axis tight 
xlabel('x-direction (pix)'); ylabel('estimated temperature (degC)');
title('temperature profile over time');
legend 

%% PLOT TEMPERATURE GRADIENT OVER TIME 

% select 10 random frames to find local max and min points
randN = randi(N,10,1);   

loc = zeros(length(randN),3); % assume 3 local points of inflection 

for k = 1:length(randN)

    T_prof = dT_x(randN(k),:); 

    % find local minimum and maximum points 
    Tmax = islocalmax(T_prof,'MinSeparation',1200);
    Tmin = islocalmin(T_prof,'MinSeparation',1200);

    locMax = find(Tmax==1);
    locMin = find(Tmin==1);

    loc(k,:) = sort([locMax locMin]);

end
  
xcor = mean(loc); % x-coordinates of hottest and coldest points 

dx1 = (xcor(1):xcor(2))./conv_fac;

% gradient 1
dT1 = dT_x(:,xcor(1):xcor(2));

for m1 = 1:N
    p = polyfit(dx1, dT1(m1,:),1);
    grad1 = p(1);
    grad1_arr(m1) = grad1;
end 

% % user-defined inputs
% X = 1:N; % time 
% Y = grad1_arr; % gradient 
% g = [-10 -10 5]; %intial guess values 
% 
% % Prepare data
% [xData, yData] = prepareCurveData( X, Y );
% 
% % Set up fittype and options.
% ft = fittype( 'a-b*exp(-x/c)', 'independent', 'x', 'dependent', 'y' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Algorithm = 'Levenberg-Marquardt';
% opts.Display = 'Off';
% opts.MaxIter = 1000;
% opts.StartPoint = g;
% opts.TolFun = 1e-10;
% 
% % Fit model to data.
% [fitresult, gof] = fit( xData, yData, ft, opts )
% a = fitresult.a;
% b = fitresult.b; 
% c = fitresult.c;
% 
% % Fitted plot
% XFit = 0:max(X); 
% YFit = a-b.*exp(-XFit./c);

figure
plot(1:N, grad1_arr, 'ko')
% hold on 
% plot(XFit, YFit);
xlabel('time (min)'); ylabel('temperature gradient (deg/mm)')
title (['grad1: ' num2str((dx1(end)-dx1(1))*1000) 'µm'])



% gradient 2
dx2 = (xcor(2):xcor(3))./conv_fac;
dT2 = dT_x(:,xcor(2):xcor(3));

for m2 = 1:N
    p = polyfit(dx2, dT2(m2,:),1);
    grad2 = p(1);
    grad2_arr(m2) = grad2;
end 

figure
plot(1:N, grad2_arr, 'ko')
xlabel('time (min)'); ylabel('temperature gradient (deg/mm)')
title (['grad2: ' num2str((dx2(end)-dx2(1))*1000) 'µm'])







