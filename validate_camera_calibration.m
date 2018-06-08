
%% Cleaning
close all hidden;
clear

%% Real distance
d = 2;
%% Load stereoParams
load('stereoParams.mat') %loads it back in and Matlab recognises it is a structure
stereoParams = stereoParameters(stereoParams); % recreates the stereo parameters object 

%% Calculata base and focal length in mm
base = norm(stereoParams.TranslationOfCamera2);
f1x = 3.6*10^(-6) * stereoParams.CameraParameters1.FocalLength(1);
f1y = 3.6*10^(-6) * stereoParams.CameraParameters1.FocalLength(2);

f2x = 3.6*10^(-6) * stereoParams.CameraParameters2.FocalLength(1);
f2y = 3.6*10^(-6) * stereoParams.CameraParameters2.FocalLength(2);

f = (f1x + f1y + f2x + f2y)/4 *1000;

%% GUI to open file
 
[ workingDir, name, ext] = fileparts( mfilename( 'fullpath'));
ImageDir = [ workingDir, '/Session 7_Beamer/5m/'];
 
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
I1 = imread(fullfile(leftPathName, leftFileName));
I2 = imread(fullfile(rightPathName, rightFileName));

%% Rectify stereo images
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams, 'OutputView','valid');

%% Disparity
disparityMap = disparity(J1(:,:,2), J2(:,:,2), 'BlockSize', 5,...
               'ContrastThreshold', 0.9, 'UniquenessThreshold', 1,...
               'DistanceThreshold', 1,  'TextureThreshold' , 0.00001 );
           
%% Depth map
depth = base *f ./ (disparityMap*3.6*10^-3) ;
depth = depth ./ 1000;

%% Extract all region of interest

