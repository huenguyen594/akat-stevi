stereoParams14 = toStruct(stereoParams14); %change it into struct
save stereoParams14.mat stereoParams14
% save Offset.mat offset %Saves as a mat file


save estimationErrors14.mat estimationErrors14 %Saves as a mat file



% clear %clear variables in workspace
% 
% 
% load('Offset.mat') %loads it back in and Matlab recognises it is a structure
% 
% stereoParams=stereoParameters(stereoParams) % recreates the stereo parameters object 
% 
% 
% load('estimationErrors.mat')
