% Recover all depth-maps in the dataset
clear, clc
st = clock;

% iname = 'IMG_0326';
iname = 'IMG_0369';

im = imread('IMG_0369_rgb.png');
seg = imread('IMG_0369.png');
load('IMG_0369.mat');

%Using segmentation as guidance:
% dmr1 = recover(dm, seg);


% %If segmentation is not available, use basic super-pixel segmentation:
dmr2 = recover(dm, [], im);
figure
subplot(121), imagesc(dm), axis off, daspect([1 1 1])
xlabel('Original depth-map')
subplot(122), imagesc(dmr2), axis off, daspect([1 1 1])
xlabel('Recovered depth-map')

sp = clock;
fprintf('Started: %s\nFinished: %s\n', datestr(st), datestr(sp))