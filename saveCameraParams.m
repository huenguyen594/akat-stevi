stereoParams = toStruct(stereoParams9) %change it into struct

save stereoParams9.mat stereoParams %Saves as a mat file


save estimationErrors9.mat estimationErrors9 %Saves as a mat file



% clear %clear variables in workspace
% 
% 
% load('stereoParams.mat') %loads it back in and Matlab recognises it is a structure
% 
% stereoParams=stereoParameters(stereoParams) % recreates the stereo parameters object 
% 
% 
% load('estimationErrors.mat')
