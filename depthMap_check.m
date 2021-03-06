%% Cleaning
close all hidden;
clear %clear variables in workspace
load('stereoParams14.mat'); %loads it back in and Matlab recognises it is a structure
stereoParams = stereoParameters(stereoParams14); % recreates the stereo parameters object 

%% Calculata base and focal length in mm
base = stereoParams.TranslationOfCamera2(1);
f1x = 3.6*10^(-3) * stereoParams.CameraParameters1.FocalLength(1);
f1y = 3.6*10^(-3) * stereoParams.CameraParameters1.FocalLength(2);

f2x = 3.6*10^(-3) * stereoParams.CameraParameters2.FocalLength(1);
f2y = 3.6*10^(-3) * stereoParams.CameraParameters2.FocalLength(2);

f = (f1x + f1y + f2x + f2y)/4;

% Auf 1.13m Hyperfokale normiert
pixelSize = -base*f/(91.875*1.13)*10^-3;
% pixelSize = 3.6*10^-3;

%% Offset-funktion
x = [133.375
104.125
97.875
91.875
83.25
74.625
69.0625
51.125
40.5625
34
28.875
26
];
x=x';

% y = [ 25.59882653
% 7.295051022
% 9.049413267
% 10.27953061
% 8.491275511
% 7.82287901
% 7.019706633
% 6.244183674
% 6.979765307
% 7.017968461
% 7.373137756
% ];
% y = y';

y = [-3.6015625
-0.30625
-0.848130841
0
-0.195
-0.46875
0.15
0.784375
0.965
0.60625
0.7875
1.320723684
];
y = y';
xq = 25:0.0025:144;

offset = interp1(x,y,xq, 'pchip');
figure;
plot(x,y,'o',xq,offset,':.');
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

%% Rectify check
% [J1, J2] = rectifyStereoImages(I1, I2, stereoParamsSS7, 'OutputView','valid');
% [J1, newOrigin1] = undistortImage(I1, stereoParamsSS7.CameraParameters1);
% [J2, newOrigin2] = undistortImage(I2, stereoParamsSS7.CameraParameters2);

[J1s, J2s] = rectifyStereoImages(I1(:,:,2), I2(:,:,2), stereoParams, 'OutputView','valid');

figure;
imshow(stereoAnaglyph(J1s, J2s));
%% Disparity
disparityRange = [0 144];
blockSize = 5; %% for point pattern

%% Histogrammausgleich
J1s = histeq(J1s);
J2s = histeq(J2s);


%% Median
J1s = medfilt2(J1s, [5 5]);
J2s = medfilt2(J2s, [5 5]);
% For undistorted images
% disparityMap = disparity(J1(:,:,2), J2(:,:,2), 'BlockSize', 19,...
%                'ContrastThreshold', 1, 'UniquenessThreshold', 0,...
%                'DistanceThreshold', [],  ...
%                'DisparityRange', disparityRange );

% For rectified images
% disparityMap = disparity(J1s, J2s, 'BlockSize', 19,...
%    'ContrastThreshold', 0.0001, 'UniquenessThreshold', 15,...
%    'DistanceThreshold', [],  ...
%    'DisparityRange', disparityRange );
% disparity matlab standard
disparityMap = disparity(J1s, J2s,  'BlockSize', 5,  'ContrastThreshold', 0.0001, ...
                'UniquenessThreshold', 0,...
                'DistanceThreshold', [],  ...
                'DisparityRange', disparityRange );

%% Disparitšt Korrektur mit Offset-Funktion
for x_i=1:size(disparityMap,2)
    for y_i=1:size(disparityMap,1)
        disp = disparityMap(y_i,x_i);
        if(disp >= 25 && disp <= 144)
            index = ((disp-25)/0.0025) + 25;
            disparityMap(y_i,x_i) = disparityMap(y_i,x_i) + offset(index);
        end
    end
end

% owlbread github code
% disparityMap = disparity2reloaded(imresize(J1s,0.25), imresize(J2s,0.25));
% BlockMatching, ROI too big, cropping needed
% disparityMap = disparity(J1(:,:,2), J2(:,:,2), 'Methode', 'BlockMatching', 'DisparityRange', disparityRange);

% disparity stackoverflow
% [disparityMap, C_min, C] = disparity_stackoverflow(histeq(I1(:,:,2)), histeq(I2(:,:,2)), 45, 130, 21);

figure;
imshow(disparityMap, disparityRange); % durch 16 teilbar
title('Disparity Map');
colormap(gca, 'default');
colorbar   

%% Depth map

depth = abs(base) *f ./ (disparityMap*pixelSize) ;
depth = depth ./ 1000;

%% Median
% depth = medfilt2(depth, [25 25]);

%% gauss
% depth = imgaussfilt(depth);

figure;
imshow(depth , [0 15]); 
title('Depth Map Filtered');
colormap(gca, 'default');
colorbar;

%% Write out
% depth_normalized = mat2gray(depth);
% imwrite(depth_normalized, 'depth_normalized.tiff');

%% Data save
% save('depth.mat', depth);

