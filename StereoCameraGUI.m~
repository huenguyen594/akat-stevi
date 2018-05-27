function varargout = StereoCameraGUI(varargin)
% STEREOCAMERAGUI MATLAB code for StereoCameraGUI.fig
%      STEREOCAMERAGUI, by itself, creates a new STEREOCAMERAGUI or raises the existing
%      singleton*.
%
%      H = STEREOCAMERAGUI returns the handle to a new STEREOCAMERAGUI or the handle to
%      the existing singleton*.
%
%      STEREOCAMERAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STEREOCAMERAGUI.M with the given input arguments.
%
%      STEREOCAMERAGUI('Property','Value',...) creates a new STEREOCAMERAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StereoCameraGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StereoCameraGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StereoCameraGUI

% Last Modified by GUIDE v2.5 27-May-2018 23:04:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StereoCameraGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @StereoCameraGUI_OutputFcn, ...
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


% --- Executes just before StereoCameraGUI is made visible.
function StereoCameraGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StereoCameraGUI (see VARARGIN)

% Choose default command line output for StereoCameraGUI
handles.output = hObject;

% Number of saved images
global nImage;
nImage = 0;
global tImage;
tImage = 0;


% Initialize image folders
mkdir leftCamera;
addpath leftCamera;

mkdir rightCamera;
addpath rightCamera;

mkdir testImages;
addpath testImages;

% handles.leftVideo = videoinput('macvideo', 1, 'YCbCr422_1280x720');
handles.leftVideo = videoinput('winvideo', 2, 'RGB24_1280x1024');
handles.rightVideo = videoinput('winvideo', 1, 'RGB24_1280x1024');


handles.leftFrame = getsnapshot(handles.leftVideo);
handles.rightFrame = getsnapshot(handles.rightVideo);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StereoCameraGUI wait for user response (see UIRESUME)
uiwait(handles.StereoCameraGUI);


% --- Outputs from this function are returned to the command line.
function varargout = StereoCameraGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;


% --- Executes when user attempts to close StereoCameraGUI.
function StereoCameraGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to StereoCameraGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clear handles.leftVideo
clear handles.rightVideo
delete (instrfind)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in startPreview.
function startPreview_Callback(hObject, eventdata, handles)
% hObject    handle to startPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Create video object and put it into the axes

% Left Camera
% handles.leftVideo = videoinput('macvideo', 1, 'YCbCr422_1280x720');
% handles.leftVideo = videoinput('winvideo', 2, 'RGB24_1280x1024');
triggerconfig(handles.leftVideo, 'manual');
src_left = getselectedsource(handles.leftVideo);
src_left.VerticalFlip = 'on';
get(src_left);
% src_left.Exposure = 20;
% set(src_left, 'Exposure', 20);
% set(src_left, 'ExposureMode', 'manual');

leftVidRes = get(handles.leftVideo, 'VideoResolution');
leftNBands = get(handles.leftVideo, 'NumberOfBands');
leftHImage = image(handles.leftCameraAxes, zeros(leftVidRes(2), leftVidRes(1), leftNBands));

% For non-RGB colorspace
% set(handles.leftVideo,'ReturnedColorSpace', 'RGB');

% % Right camera
% handles.rightVideo = videoinput('winvideo', 1, 'RGB24_1280x1024');
triggerconfig(handles.rightVideo, 'manual');
config = triggerinfo(handles.rightVideo);
rightVidRes = get(handles.rightVideo, 'VideoResolution');
rightNBands = get(handles.rightVideo, 'NumberOfBands');
rightHImage = image(handles.rightCameraAxes, zeros(rightVidRes(2), rightVidRes(1), rightNBands));

src_right = getselectedsource(handles.rightVideo);
src_right.VerticalFlip = 'on';
% Update handles
guidata(hObject, handles);

% Start Preview
preview(handles.leftVideo, leftHImage);
preview(handles.rightVideo, rightHImage);

textOut = 'Preview started';
disp(textOut);
set(handles.textOut, 'String',textOut);


% --- Executes on button press in captureImages.
function captureImages_Callback(hObject, eventdata, handles)
% hObject    handle to captureImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Trigger
handles.leftFrame = 1.75.*getsnapshot(handles.leftVideo);
handles.rightFrame = 1.75.*getsnapshot(handles.rightVideo);

% Update handles
guidata(hObject, handles);

% Stop preview and show the captured frame
stoppreview(handles.leftVideo);
imshow(handles.leftFrame,'parent',handles.leftCameraAxes);

stoppreview(handles.rightVideo);
imshow(handles.rightFrame,'parent',handles.rightCameraAxes);
textOut = 'Images captured';
disp(textOut);
set(handles.textOut, 'String', textOut);



% --- Executes on button press in saveImages.
function saveImages_Callback(hObject, eventdata, handles)
% hObject    handle to saveImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global nImage;

leftFilename = sprintf('%s_%d.png', 'leftImage', nImage);
leftFullFilename = fullfile(pwd, '/leftCamera', leftFilename);
imwrite(handles.leftFrame, leftFullFilename);
% textOut = [leftFilename,' saved'];
% disp(textOut);

rightFilename = sprintf('%s_%d.png', 'rightImage', nImage);
rightFullFilename = fullfile(pwd, '/rightCamera', rightFilename);
imwrite(handles.rightFrame, rightFullFilename);

textOut = [leftFilename, ' and ', rightFilename,' saved.'];
disp(textOut);

set(handles.textOut, 'String', textOut);
nImage = nImage + 1;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function leftCameraAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leftCameraAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object deletion, before destroying properties.
function leftCameraAxes_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to leftCameraAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function textOut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when StereoCameraGUI is resized.
function StereoCameraGUI_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to StereoCameraGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveTestImages.
function saveTestImages_Callback(hObject, eventdata, handles)
% hObject    handle to saveTestImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tImage;

leftFilename = sprintf('%s_%d.png', 'test_left', tImage);
leftFullFilename = fullfile(pwd, '/testImages', leftFilename);
imwrite(handles.leftFrame, leftFullFilename);
% textOut = [leftFilename,' saved'];
% disp(textOut);

rightFilename = sprintf('%s_%d.png', 'test_right', tImage);
rightFullFilename = fullfile(pwd, '/testImages', rightFilename);
imwrite(handles.rightFrame, rightFullFilename);

textOut = [leftFilename, ' and ', rightFilename,' saved.'];
disp(textOut);

set(handles.textOut, 'String', textOut);
tImage = tImage + 1;


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over saveTestImages.
function saveTestImages_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to saveTestImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
