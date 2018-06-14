
%% Camera setup
% Right camera
right = videoinputvideoinput('winvideo', 1, 'RGB24_1280x1024');
% Left camera
left = videoinput('winvideo', 2, 'RGB24_1280x1024');%left

set([left right],'FramesPerTrigger',Inf);
set([left right], 'ReturnedColorspace', 'grayscale'); 

right.FrameGrabInterval = 1; 
left.FrameGrabInterval = 1;
hFigure = figure(1); 
load('stereoParamsSS7.mat') %loads it back in and Matlab recognises it is a structure
stereoParamsSS7 = stereoParameters(stereoParamsSS7) % recreates the stereo parameters object 

try
    start([left right]);

    while islogging([left right]); 

        % Acquire 1 frame
        I1 = getsnapshot(left);
        I2 = getsnapshot(right);
        I1 = im2double(I1); I2 = im2double(I2);
        % Rectify the image pairs
        [frameLeftRect, frameRightRect] = rectifyStereoImages(I1, I2, stereoParamsSS7);

        w1 =fspecial('log',[5 5],0.5); 
        av = fspecial('average',[3 3]);

        M1 = imfilter(I1,av,'replicate');  M2 = imfilter(I2,av,'replicate'); 
        M1 = medfilt2(M1, 'indexed'); M2 = medfilt2(M2,'indexed'); 

        frameLeftGray = imfilter(M1,w1,'replicate'); 
        frameRightGray = imfilter(M2,w1,'replicate'); 
        disparityMap = disparity(frameLeftGray, frameRightGray, 'BlockSize', 17);
        imshow(disparityMap, [0, 64]);
    end

catch err
    
    stop([right left]);
    imaqreset
    disp('Cleaned up')
    rethrow(err)
end    
