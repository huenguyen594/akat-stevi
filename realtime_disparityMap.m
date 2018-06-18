close all hidden;
clear %clear variables in workspace


%% Camera setup
imaqreset
% Right camera
right = videoinput('winvideo', 1, 'RGB24_1280x1024');
% Left camera
left = videoinput('winvideo', 2, 'RGB24_1280x1024');%left

set([left right],'FramesPerTrigger',Inf);
set([left right], 'ReturnedColorspace', 'grayscale'); 

right.FrameGrabInterval = 1; 
left.FrameGrabInterval = 1;
hFigure = figure(1); 
title('Depth Map');
% colormap(gca, 'default');
% colorbar;

load('stereoParams9.mat') %loads it back in and Matlab recognises it is a structure
stereoParams = stereoParameters(stereoParams) % recreates the stereo parameters object 
base = 76.034525998165490;
pixelSize = 3.4342*10^-3;
f = 9.214797770218713;
try
    start([left right]);

    while islogging([left right]) 

        % Acquire 1 frame
        I1 = getsnapshot(left);
        I2 = getsnapshot(right);
        
%         I1 = imresize(I1, 0.5);
%         I2 = imresize(I2, 0.5); 
        
        I1 = im2double(I1); I2 = im2double(I2);
        % Rectify the image pairs
        [J1s, J2s] = rectifyStereoImages(I1, I2, stereoParams, 'OutputView','valid');

        %% Disparity
        disparityRange = [48 160];
        blockSize = 5 %% for point pattern

%         %% Histogrammausgleich
%         J1s = histeq(J1s);
%         J2s = histeq(J2s);
% 
%         %% Gauss
%         J1s = imgaussfilt(J1s);
%         J2s = imgaussfilt(J2s);

        
%         [frameLeftRect, frameRightRect] = rectifyStereoImages(I1, I2, stereoParams);
% 
%         w1 =fspecial('log',[5 5],0.5); 
%         av = fspecial('average',[3 3]);
% 
%         M1 = imfilter(I1,av,'replicate');  M2 = imfilter(I2,av,'replicate'); 
%         M1 = medfilt2(M1, 'indexed'); M2 = medfilt2(M2,'indexed'); 
% 
%         frameLeftGray =  histeq(1.5.* imfilter(M1,w1,'replicate')); 
%         frameRightGray =  histeq(1.5.*imfilter(M2,w1,'replicate')); 
% %         disparityMap = disparity(frameLeftGray, frameRightGray, 'BlockSize', 5);
%         disparityMap = disparity(frameLeftGray, frameRightGray, 'BlockSize', 11,...
%                'ContrastThreshold', 0.001, 'UniquenessThreshold', 15,...
%                'DistanceThreshold', [],  ...
%                'DisparityRange', [48 160]  );

        disparityMap = disparity(J1s, J2s,  'BlockSize', 5,  'ContrastThreshold', 0.0001, 'UniquenessThreshold', 0,...
                'DistanceThreshold', [],  ...
                'DisparityRange', disparityRange );

%         disparityMap = disparity_stackoverflow(J1s, J2s, 16, 80, 3);
            
        depth = abs(base) *f ./ (disparityMap*pixelSize) ;
        depth = depth ./ 1000;
        %% Median
        depth = medfilt2(depth, [5 5]);

        %% gauss
        depth = imgaussfilt(depth);
%       imshow(disparityMap, [0, 64]);
        imshow(depth , [0, 6]); 
        title('Depth Map');
%       colormap(gca, 'default');
        flushdata(right, 'triggers');
        flushdata(left, 'triggers');
               
    end
flushdata(right);
flushdata(left);
delete(right)
clear(right)
delete(left)
clear(left)
catch err
    
    stop([right left]);
    imaqreset
    disp('Cleaned up')
    rethrow(err)
end    
