%% Cleaning
clc;
close all hidden;

%% stereoParams
load('stereoParams10.mat'); %loads it back in and Matlab recognises it is a structure
stereoParams = stereoParameters(stereoParams); % recreates the stereo parameters object 
base = 72.895433590710810   ;    
pixelSize = 0.003482560000000;
f = 9.214831822060825;

%% Read video
%% Camera setup
imaqreset
% Right camera
right = videoinput('winvideo', 2, 'RGB24_1280x1024');
% Left camera
left = videoinput('winvideo', 1, 'RGB24_1280x1024');%left

set([left right],'FramesPerTrigger',Inf);
set([left right], 'ReturnedColorspace', 'RGB'); 
src_left = getselectedsource(left);
src_left.VerticalFlip = 'on';

src_right = getselectedsource(right);
src_right.VerticalFlip = 'on';

videoPlayer = vision.VideoPlayer;
foregroundPlayer = vision.VideoPlayer;
disPlayer = vision.VideoPlayer;

%% Depth map
% Acquire 1 frame
I1 = 3.*getsnapshot(left);
I2 = 3.*getsnapshot(right);

% Rectify the image pairs
[J1s, J2s] = rectifyStereoImages(I1(:,:,2), I2(:,:,2), stereoParams, 'OutputView','valid');

%% Disparity
disparityRange = [16 112];
blockSize = 5; %% for point pattern

%% Histogrammausgleich
J1s = histeq(J1s);
J2s = histeq(J2s);
%% Median filter
J1s = medfilt2(J1s, [5 5]);
J2s = medfilt2(J2s, [5 5]);
       
%% Create blob analysis objects
blobAna = vision.BlobAnalysis('BoundingBoxOutputPort', true,...
    'AreaOutputPort', false, 'CentroidOutputPort', false,...
    'MinimumBlobArea', 500);


%% Loop through video
start([left right]);
while islogging([left right]) 
    %% Acquire 1 frame
    I1 = 3.*getsnapshot(left);
    I2 = 3.*getsnapshot(right);

    % Rectify the image pairs
    [J1s, J2s] = rectifyStereoImages(I1(:,:,2), I2(:,:,2), stereoParams, 'OutputView','valid');

    %% Disparity
    disparityRange = [16 112];
    blockSize = 5; %% for point pattern

    %% Histogrammausgleich
    J1s = histeq(J1s);
    J2s = histeq(J2s);
    %% Median filter
    J1s = medfilt2(J1s, [5 5]);
    J2s = medfilt2(J2s, [5 5]);

    %% Disparity berechnen
    disparityMap = disparity(J1s, J2s,  'BlockSize', 5,  'ContrastThreshold', 0.0001, 'UniquenessThreshold', 0,...
            'DistanceThreshold', [],  ...
            'DisparityRange', disparityRange );

    depth = abs(base) *f ./ (disparityMap*pixelSize) ;
    depth = depth ./ 1000;
    %% Median
     depth = medfilt2(depth, [5 5]);

    %% video processing
    depth_mask = depth;
    %% Filter objects from 1.8m to 2.2 m
    depth_mask( (depth_mask < 1.8) | (depth_mask > 2.2)) = 0;
    depth_mask( (depth_mask >= 1.8) & (depth_mask <= 2.2) ) = 1;
    cleanFG = depth_mask;
    cleanFG = imopen(cleanFG, strel('Disk',15));
    cleanFG = imclose(cleanFG, strel('Disk',15));
    cleanFG = logical(cleanFG);
    
    % detect the connected components with the specified minumum area and
    % compute their bouding boxes
    bbox = step(blobAna, cleanFG);
    % Draw bounding boxes around
    result = insertShape(J1s, 'Rectangle', bbox, 'Color', 'green', 'LineWidth', 3);
    
    %% Display output
    step(videoPlayer, result);
    step(foregroundPlayer, cleanFG);
    
    depth_show = mat2gray(depth);
    step(disPlayer, depth_show);
    
    flushdata(right);
    flushdata(left);
   
end

%% Release video 
release(videoPlayer);
delete(left);
delete(right);
