% % Auto-generated by stereoCalibrator app on 07-May-2018
% %-------------------------------------------------------
% Halloooooooooooo
% 
% % % Define images to process
% imageFileNames1 = {'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_0.png',...
%     'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_1.png',...
%     'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_10.png',...
%     'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_11.png',...
%     'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_2.png',...
%     'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_3.png',...
%     'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_4.png',...
%     'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_5.png',...
%     'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_6.png',...
%     'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_7.png',...
%     'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_8.png',...
%     'C:\Users\akat\Desktop\SteVi\leftCamera\leftImage_9.png',...
%     };
% imageFileNames2 = {'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_0.png',...
%     'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_1.png',...
%     'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_10.png',...
%     'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_11.png',...
%     'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_2.png',...
%     'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_3.png',...
%     'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_4.png',...
%     'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_5.png',...
%     'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_6.png',...
%     'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_7.png',...
%     'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_8.png',...
%     'C:\Users\akat\Desktop\SteVi\rightCamera\rightImage_9.png',...
%     };
% 
% %% Detect checkerboards in images
% [imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames1, imageFileNames2);
% 
% %% Generate world coordinates of the checkerboard keypoints
% squareSize = 46;  % in units of 'millimeters'
% worldPoints = generateCheckerboardPoints(boardSize, squareSize);
 
%% GUI to open file
 
[ workingDir, name, ext] = fileparts( mfilename( 'fullpath'));
ImageDir = [ workingDir, '/testImages/'];
 
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
 
%% Read one of the images from the first stereo pair
I1 = imread(fullfile(leftPathName, leftFileName));
% I1 = imread('LaserTest/leftTest_1.png');
[mrows, ncols, ~] = size(I1);
% 
% %% Calibrate the camera
% [stereoParams, pairsUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
%  'EstimateSkew', true, 'EstimateTangentialDistortion', true, ...
%      'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
%      'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
%      'ImageSize', [mrows, ncols]);
 
%%% View reprojection errors
h1=figure; showReprojectionErrors(stereoParams021);
 
%%%Visualize pattern locations
h2=figure; showExtrinsics(stereoParams021, 'CameraCentric');
 
%%% Display parameter estimation errors
% displayErrors(estimationErrors, stereoParams2c);
 
% %%You can use the calibration data to rectify stereo images.
I2 = imread(fullfile(rightPathName, rightFileName));
% I2 = imread('LaserTest/rightTest_1.png');
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams021);
figure;
imshow(stereoAnaglyph(J1, J2));
title('Rectified Frames');
frameLeftGray  = rgb2gray(J1);
frameRightGray = rgb2gray(J2);
    
disparityMap = disparity(frameLeftGray, frameRightGray);
figure;
imshow(disparityMap, [0, 64]); % durch 16 teilbar
title('Disparity Map');
colormap (gca, 'jet');
colorbar
 
points3D = reconstructScene(disparityMap, stereoParams021);
 
%%% Convert to meters and create a pointCloud object
points3D = points3D ./ 1000;
ptCloud = pointCloud(points3D, 'Color', J1);
 
%%% Create a streaming point cloud viewer
player3D = pcplayer([-3, 3], [-3, 3], [0, 8], 'VerticalAxis', 'y', ...
    'VerticalAxisDir', 'down');
 
%%% Visualize the point cloud
view(player3D, ptCloud);
 
%%% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('StereoCalibrationAndSceneReconstructionExample')
% showdemo('DepthEstimationFromStereoVideoExample')
 
%%% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('StereoCalibrationAndSceneReconstructionExample')
% showdemo('DepthEstimationFromStereoVideoExample')

