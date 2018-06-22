%% Cleaning
close all hidden;

load('depth.mat');
%% Read input
% depth = im2double(imread('depth.tiff');
figure;
imshow(depth, [0 5]);
% [L,C,LUT]=FastCMeans(depth,10);
depth_mask = depth;
%% Filter objects from 1.8m to 2.2 m
depth_mask( (depth_mask < 1.8) | (depth_mask > 2.2)) = 0;
depth_mask( (depth_mask >= 1.8) & (depth_mask <= 2.2) ) = 1;

se = strel('disk',5);
depth_mask = imopen(depth_mask, se);
figure
imshow(depth_mask, [0 2])
s  = regionprops(depth_mask);
figure;
imshow(J1s);
hold on;
rectangle('Position', s.BoundingBox ,'EdgeColor','g', 'LineWidth', 3);