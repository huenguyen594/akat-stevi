stereoParams = toStruct(stereoParams10) %change it into struct

save stereoParams10.mat stereoParams %Saves as a mat file


save estimationErrors10.mat estimationErrors10 %Saves as a mat file



% clear %clear variables in workspace
% 
% 
% load('stereoParams.mat') %loads it back in and Matlab recognises it is a structure
% 
% stereoParams=stereoParameters(stereoParams) % recreates the stereo parameters object 
% 
% 
% load('estimationErrors.mat')
