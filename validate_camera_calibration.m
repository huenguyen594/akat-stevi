
%% Cleaning
close all hidden;
clear

%% Real distance
d = 5;
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
I1 = imread(fullfile(leftPathName, leftFileName));
I2 = imread(fullfile(rightPathName, rightFileName));

%% Rectify stereo images
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams, 'OutputView','valid');

figure;
imshow(stereoAnaglyph(J1, J2));
title('Rectified stereo image pair');

%% Disparity
% Matlab disparity;
disparityRange = [0 64];

blockSize = 23 %% for point pattern
disparityMap = disparity(J1(:,:,2), J2(:,:,2), 'BlockSize', 15,...
               'ContrastThreshold', 0.5, 'UniquenessThreshold', 5,...
               'DistanceThreshold', 3,  'TextureThreshold' , 0,...
               'DisparityRange', disparityRange );

% stereovision disparity
% channel = 2; % Chanel R = 1, G = 2, B =3
% windowsize = 65;
% disparity_max = 64;
% spacc = 0;
% J1s = imresize(J1, 0.75);
% J2s = imresize(J2, 0.75);
% [disparityMap, dcost, pcost, wcost] = stereomatch(J1s(:,:,channel), J2s(:,:,channel), windowsize, disparity_max, spacc);

% Visualize disparity map
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

%% Depth map denoising/ inpainting

% %% Extract all region of interest
% redBand = I1(:,:,1);
% greenBand = I1(:,:,2);
% blueBand = I1(:, :, 3);
% seg = (redBand >= 80) & (greenBand < 25) & (blueBand <60);
% se = strel('disk', 3, 4);
% seg = imdilate(seg, se);
% 
% % Finds all the connected components (objects) in the binary image
% cc = bwconncomp(seg, 4);
% % Get centroid of each object
% data = (regionprops(cc,'centroid'));
% centroids = uint16(cat(1, data.Centroid));
% 
% delta = zeros(size(centroids,1),1);
% for i=1:size(delta,1)
%     delta(i) = depth(centroids(i,2), centroids(i,1));
% end
% 
% delta = abs(delta - d);
% figure;
% imshow(I1);
% hold on;
% for i=1:size(delta,1)
%     plot(centroids(i,1), centroids(i,2), 'go');
%     text( double(centroids(i,1)+15), double(centroids(i,2)), num2str(delta(i)), 'Color', 'blue' );
% end
