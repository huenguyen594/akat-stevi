stereoParams13 = toStruct(stereoParams13); %change it into struct
save stereoParams13.mat stereoParams13
% save Offset.mat offset %Saves as a mat file


save estimationErrors13.mat estimationErrors13 %Saves as a mat file



% clear %clear variables in workspace
% 
% 
% load('Offset.mat') %loads it back in and Matlab recognises it is a structure
% 
% stereoParams=stereoParameters(stereoParams) % recreates the stereo parameters object 
% 
% 
% load('estimationErrors.mat')
