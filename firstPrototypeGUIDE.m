function varargout = firstPrototypeGUIDE(varargin)
% FIRSTPROTOTYPEGUIDE MATLAB code for firstPrototypeGUIDE.fig
%      FIRSTPROTOTYPEGUIDE, by itself, creates a new FIRSTPROTOTYPEGUIDE or raises the existing
%      singleton*.
%
%      H = FIRSTPROTOTYPEGUIDE returns the handle to a new FIRSTPROTOTYPEGUIDE or the handle to
%      the existing singleton*.
%
%      FIRSTPROTOTYPEGUIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIRSTPROTOTYPEGUIDE.M with the given input arguments.
%
%      FIRSTPROTOTYPEGUIDE('Property','Value',...) creates a new FIRSTPROTOTYPEGUIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before firstPrototypeGUIDE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to firstPrototypeGUIDE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help firstPrototypeGUIDE

% Last Modified by GUIDE v2.5 02-Jul-2018 12:04:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @firstPrototypeGUIDE_OpeningFcn, ...
                   'gui_OutputFcn',  @firstPrototypeGUIDE_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before firstPrototypeGUIDE is made visible.
function firstPrototypeGUIDE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to firstPrototypeGUIDE (see VARARGIN)

% Choose default command line output for firstPrototypeGUIDE
handles.output = hObject;

%% stereoParams
load('stereoParams10.mat'); %loads it back in and Matlab recognises it is a structure
handles.stereoParams = stereoParameters(stereoParams); % recreates the stereo parameters object 
handles.base = 72.895433590710810   ;    
handles.pixelSize = 0.003482560000000;
handles.f = 9.214831822060825;


% Camera setup
imaqreset;

handles.right = videoinput('winvideo', 2, 'RGB24_1280x1024');
handles.left = videoinput('winvideo', 1, 'RGB24_1280x1024');

% Slider setup
handles.distance = 1.8;
handles.threshold = 0.4;
            
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes firstPrototypeGUIDE wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = firstPrototypeGUIDE_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function distanceSlider_Callback(hObject, eventdata, handles)
% hObject    handle to distanceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function distanceSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distanceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.distanceSlider.Value = 1.8;
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
    
end


% --- Executes on slider movement.
function thresholdSlider_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function thresholdSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.thresholdSlider.Value = 0.4;
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
left = handles.left;
right = handles.right;

set([left right],'FramesPerTrigger',Inf);
set([left right], 'ReturnedColorspace', 'RGB'); 
src_left = getselectedsource(left);
src_left.VerticalFlip = 'on';

src_right = getselectedsource(right);
src_right.VerticalFlip = 'on';

 %% Create blob analysis objects
            blobAna = vision.BlobAnalysis('BoundingBoxOutputPort', true,...
                'AreaOutputPort', false, 'CentroidOutputPort', false,...
                'MinimumBlobArea', 800);
            
            
            %% Loop through video
            start([left right]);
            while islogging([left right]) 
                %% Acquire 1 frame
                I1 = 4.*getsnapshot(left);
                I2 = 4.*getsnapshot(right);
            
                % Rectify the image pairs
                [J1s, J2s] = rectifyStereoImages(I1(:,:,2), I2(:,:,2), handles.stereoParams, 'OutputView','valid');
            
                %% Disparity
                disparityRange = [16 112];
            
                %% Histogrammausgleich
                J1s = histeq(J1s);
                J2s = histeq(J2s);
                %% Median filter
                J1s = medfilt2(J1s, [5 5]);
                J2s = medfilt2(J2s, [5 5]);
            
                %% Disparity berechnen
                disparityMap = disparity(J1s, J2s,  'BlockSize', 5,  'ContrastThreshold', 0.0001, 'UniquenessThreshold', 0,...
                        'DistanceThreshold', [],  ...
                        'DisparityRange', disparityRange );
            
                depth = abs(handles.base) *handles.f ./ (disparityMap*handles.pixelSize) ;
                depth = depth ./ 1000;
                %% Median
                 depth = medfilt2(depth, [5 5]);
            
                %% video processing
                depth_mask = depth;
                %% Filter objects from 1.8m to 2.2 m
                near = handles.distanceSlider.Value;
                far = near + handles.thresholdSlider.Value;
                set(handles.distanceText, 'String', num2str(get(handles.distanceSlider,'Value')));
                set(handles.thresText, 'String', num2str(get(handles.thresholdSlider,'Value')));
                 
                depth_mask( (depth_mask < near) | (depth_mask > far)) = 0;
                depth_mask( (depth_mask >= near) & (depth_mask <= far) ) = 1;
                cleanFG = depth_mask;
                cleanFG = imopen(cleanFG, strel('Disk',15));
                cleanFG = imclose(cleanFG, strel('Disk',15));
                cleanFG = logical(cleanFG);
                
                % detect the connected components with the specified minumum area and
                % compute their bouding boxes
                bbox = step(blobAna, cleanFG);
                % Draw bounding boxes around
                result = insertShape(J1s, 'Rectangle', bbox, 'Color', 'green', 'LineWidth', 5);
                
                %% Display output
                %step(videoPlayer, result);
                imshow(result, 'Parent', handles.leftCamera);
                drawnow;
                %step(foregroundPlayer, cleanFG);
                imshow(cleanFG, 'Parent', handles.binaryMask);
                drawnow;
                
                %depth_show = mat2gray(depth);
                %step(disPlayer, depth_show);
                imshow(depth, [0 5], 'Parent', handles.depthMap);
                colormap(gca, 'default');
                drawnow;
                
                flushdata(right);
                flushdata(left);
               
            end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear handles.left
clear handles.right
delete (instrfind)
% Hint: delete(hObject) closes the figure
delete(hObject);
