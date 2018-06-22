close all hidden;
clear %clear variables in workspace


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

right.FrameGrabInterval = 1; 
left.FrameGrabInterval = 1;
hFigure = figure(1); 
title('Depth Map');


load('stereoParams10.mat'); %loads it back in and Matlab recognises it is a structure
stereoParams = stereoParameters(stereoParams); % recreates the stereo parameters object 
base = 72.895433590710810   ;    
pixelSize = 0.003482560000000;
f = 9.214831822060825;

nFrame = 0;
BG = uint8(zeros(1002,1287));

try
    start([left right]);

    while islogging([left right]) 

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
        
        
        %% BG berechnen
        if(nFrame < 1)
            BG = J1s;
            nFrame = nFrame +1;
        else
            nFrame = nFrame +1;
       
            %% Vordergrund
%             VG = J1s - BG;
%             se = strel('disk',20);
%             VG = imopen(VG, se);
%             s  = regionprops(VG);

            %% Disparity berechnen
            disparityMap = disparity(J1s, J2s,  'BlockSize', 5,  'ContrastThreshold', 0.0001, 'UniquenessThreshold', 0,...
                    'DistanceThreshold', [],  ...
                    'DisparityRange', disparityRange );


            depth = abs(base) *f ./ (disparityMap*pixelSize) ;
            depth = depth ./ 1000;
            %% Median
             depth = medfilt2(depth, [5 5]);

            %% gauss
            %imshow(depth , [0, 5]); 
           % title('Depth Map');
            depth_mask = depth;
            %% Filter objects from 1.8m to 2.2 m
            depth_mask( (depth_mask < 1.8) | (depth_mask > 2.2)) = 0;
            depth_mask( (depth_mask >= 1.8) & (depth_mask <= 2.2) ) = 1;
            
            se = strel('disk',5);
            depth_mask = imopen(depth_mask, se)  ;        
            s  = regionprops(depth_mask);
            
            imshow(J1s);
            title('Left camera');
            if(size(s,1) >= 1)
                hold on;
                for i=1:size(s,1)
                    rectangle('Position', s(i).BoundingBox ,'EdgeColor','g', 'LineWidth', 2);
                    flushdata(right, 'triggers');
                    flushdata(left, 'triggers');
                end
            end
        end
        
    end
flushdata(right);
flushdata(left);
delete(right);
clear(right);
delete(left);
clear(left);
catch err
    
    stop([right left]);
    imaqreset
    disp('Cleaned up')
    rethrow(err)
end    
