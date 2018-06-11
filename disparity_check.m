% stereoParamsSS7 = toStruct(stereoParamsSS7) %change it into struct
% save stereoParamsSS7.mat stereoParamsSS7 %Saves as a mat file
% save estimationErrorsSS7.mat estimationErrorsSS7 %Saves as a mat file
close all hidden;
clear %clear variables in workspace
load('stereoParamsSS7.mat') %loads it back in and Matlab recognises it is a structure
stereoParamsSS7 = stereoParameters(stereoParamsSS7) % recreates the stereo parameters object 

%% Calculata base and focal length in mm
base = norm(stereoParamsSS7.TranslationOfCamera2);
f1x = 3.6*10^(-6) * stereoParamsSS7.CameraParameters1.FocalLength(1);
f1y = 3.6*10^(-6) * stereoParamsSS7.CameraParameters1.FocalLength(2);

f2x = 3.6*10^(-6) * stereoParamsSS7.CameraParameters2.FocalLength(1);
f2y = 3.6*10^(-6) * stereoParamsSS7.CameraParameters2.FocalLength(2);

f = (f1x + f1y + f2x + f2y)/4 *1000;
%% GUI to open file
 
[ workingDir, name, ext] = fileparts( mfilename( 'fullpath'));
ImageDir = [ workingDir, '/Session7_Beamer/5m/'];
 
[leftFileName,leftPathName] = uigetfile('*.PNG','Select the left image', ImageDir);
if isequal(leftFileName,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(leftPathName, leftFileName)])
end
 
[rightFileName,rightPathName] = uigetfile('*.PNG','Select the right image', ImageDir);
if isequal(rightFileName,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(rightPathName, rightFileName)])
end

%% Read the images from the first stereo pair
J1 = imread(fullfile(leftPathName, leftFileName));
J2 = imread(fullfile(rightPathName, rightFileName));

%% Rectify check
% [J1, J2] = rectifyStereoImages(I1, I2, stereoParamsSS7, 'OutputView','valid');
% [J1, newOrigin1] = undistortImage(I1, stereoParamsSS7.CameraParameters1);
% [J2, newOrigin2] = undistortImage(I2, stereoParamsSS7.CameraParameters1);

% [J1s, J2s] = rectifyStereoImages(J1(:,:,2), J2(:,:,2), stereoParamsSS7, 'OutputView','valid');
% figure;
% imshow(I1);
% title('Link original');
% figure;
% imshow(J1);
% title('Link undistorted');
% 
% figure
% imshow(I2)
% title('Recht original');
% figure;
% imshow(J2);
% title('Recht undistorted');

disparityRange = [0 64];
blockSize = 23 %% for point pattern
disparityMap = disparity(J1(:,:,2), J2(:,:,2), 'BlockSize', 55,...
               'ContrastThreshold', 0.5, 'UniquenessThreshold', 5,...
               'DistanceThreshold', 3,  'TextureThreshold' , 0,...
               'DisparityRange', disparityRange );
disparityMap = disparityMap .* 20/8 ;
figure;
imshow(disparityMap, disparityRange); % durch 16 teilbar
title('Disparity Map');
colormap (gca, 'jet');
colorbar   

%% Depth map
depth = base *f ./ (disparityMap*3.6*10^-3) ;
depth = depth ./ 1000;

% depth = medfilt2(depth, [15 15]);

figure;
imshow(depth , [0, 8]); 
title('Depth Map Filtered');
colormap (gca, 'jet');
colorbar

h2=figure; showExtrinsics(stereoParamsSS7, 'CameraCentric');
