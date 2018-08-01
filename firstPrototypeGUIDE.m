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

% Last Modified by GUIDE v2.5 24-Jul-2018 14:40:55

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
end

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
disp('Start');
load('stereoParams14.mat'); %loads it back in and Matlab recognises it is a structure
handles.stereoParams = stereoParameters(stereoParams14); % recreates the stereo parameters object 
% StereoParams13
% handles.base = 73.529741856656770   ;    
% handles.pixelSize = 0.003523034446473;
% handles.f = 5.092573034865157;
% StereoParams14
handles.base = 72.692357395132800   ;   
handles.f = 5.074332625803680;
handles.pixelSize = handles.base*handles.f/(91.875*1.13)*10^-3;


global mouseX;
mouseX = -1;
global mouseY;
mouseY = -1;
global gui_depth;

offset_load = load('Offset_0108.mat');
handles.offset = offset_load.offset;

% Camera setup
imaqreset;

handles.right = videoinput('winvideo', 1, 'RGB24_1280x1024');
handles.left = videoinput('winvideo', 2, 'RGB24_1280x1024');

% Slider setup
handles.distance = 1.8;
handles.threshold = 0.4;
            
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes firstPrototypeGUIDE wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = firstPrototypeGUIDE_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on slider movement.
function distanceSlider_Callback(hObject, eventdata, handles)
% hObject    handle to distanceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

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
end

% --- Executes on slider movement.
function thresholdSlider_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

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
                I1 = 1.*getsnapshot(left);
                I2 = 1.*getsnapshot(right);
            
                % Rectify the image pairs
                [J1s, J2s] = rectifyStereoImages(I1(:,:,2), I2(:,:,2), handles.stereoParams, 'OutputView','valid');
            
                %% Disparity
                disparityRange = [0 144];
            
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
                    
                %% Disparität Korrektur mit Offset-Funktion
                for x_i=1:size(disparityMap,2)
                    for y_i=1:size(disparityMap,1)
                        dispa = disparityMap(y_i,x_i);
                        if(dispa >= 10 && dispa <= 144)
                            index = ((dispa-10)/0.0025) + 10;
                            disparityMap(y_i,x_i) = disparityMap(y_i,x_i) + handles.offset(index);
                        end
                    end
                end
                
                %% Depth
                depth = abs(handles.base) *handles.f ./ (disparityMap*handles.pixelSize) ;
                depth = depth ./ 1000;
                %% Median
                depth = medfilt2(depth, [5 5]);
            
                %% video processing
                depth_mask = depth;
                %% Filter objects from 1.8m to 2.2 m
                global mouseX;
                global mouseY;

                if(mouseX > 0 && mouseY >0)
              
                    pos_x = mouseX *size(depth,2);
                    pos_y = mouseY *size(depth,1);
                    pos_x = round(pos_x,0);
                    pos_y = round(pos_y,0);
                    disp(pos_x);
                    disp(pos_y);
                    set(handles.distanceSlider, 'Value', depth(pos_y, pos_x));
                    
                    set(handles.disparityValue, 'String', ['Disparity: ',num2str(disparityMap(pos_y, pos_x))]);
                end
                
                near = handles.distanceSlider.Value - handles.thresholdSlider.Value/2;
                far = handles.distanceSlider.Value + handles.thresholdSlider.Value/2;
                set(handles.edit1, 'String', num2str(get(handles.distanceSlider,'Value')));
                set(handles.edit2, 'String', num2str(get(handles.thresholdSlider,'Value')));
                 
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
                if(size(bbox,1) >= 1)
                    result = insertShape(J1s, 'Rectangle', bbox, 'Color', 'green', 'LineWidth', 5);
                    % Insert width and height
                     position1 = bbox(1:end,1);
                     position2 = bbox(1:end,2);
                     position = horzcat(position1,position2);
                     
                    % Breite und Hoehe berechnen
                    x_bild = double(bbox(1,3));
                    y_bild = double(bbox(1,4));
                    centroid_x = position(1,1) + x_bild/2;
                    centroid_y = position(1,2) + y_bild/2;
                    z = 1000*depth(centroid_y, centroid_x);
                    breite = x_bild * handles.pixelSize * z / handles.f;
                    hoehe = y_bild * handles.pixelSize * z / handles.f;
                    
%                      result2 = insertText(result , position, ['B: ' num2str(bbox(1:end,3)) ' H: '  num2str(bbox(1:end,4))], ...
%                          'FontSize',50,'BoxColor', 'black','BoxOpacity',0.4,'TextColor','white');
                       result2 = insertText(result , position, ['B: ' num2str(breite) ' H: '  num2str(hoehe)], ...
                          'FontSize',50, 'BoxColor', 'black', 'BoxOpacity',0.6, 'TextColor','white');
                else
                    result2 = J1s;
                end
                %% Display output
                %step(videoPlayer, result);
                imshow(result2, 'Parent', handles.leftCamera);
                drawnow;
                %step(foregroundPlayer, cleanFG);
                imshow(cleanFG, 'Parent', handles.binaryMask);
                drawnow;
                
                %depth_show = mat2gray(depth);
                %step(disPlayer, depth_show);
                imshow(depth, [0 5], 'Parent', handles.depthMap);
                colormap(handles.depthMap,'default');
                drawnow;
                
                flushdata(right);
                flushdata(left);
                guidata(hObject, handles);
            end
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete handles.left;
delete handles.right;
clear handles.left;
clear handles.right;
delete (instrfind);
% Hint: delete(hObject) closes the figure
delete(hObject);
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
end

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
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in setDistance.
function setDistance_Callback(hObject, eventdata, handles)
% hObject    handle to setDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.distanceSlider, 'Value', str2num(get(handles.edit1,'String')));
end

% --- Executes on button press in setThreshold.
function setThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to setThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.thresholdSlider, 'Value', str2num(get(handles.edit2,'String')));
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mouseX;
global mouseY;
    pos = get(hObject, 'CurrentPoint');
    if(pos(1)>= 50 && pos(1)<=370 && pos(2)>=264 && pos(2)<=520)
        set(handles.currentPoint, 'String',['Current Point [ ',num2str(pos(1)),' , ', num2str(pos(2)),' ]']);
        mouseX = (pos(1)-50)/320;
        mouseY = (520-pos(2))/256;
        disp(mouseX);
        disp(mouseY);
        guidata(hObject, handles);
    else
        set(handles.currentPoint, 'String','Invalid point');
        mouseX = -1;
        mouseY = -1;
        guidata(hObject, handles);
    end
    
end

% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% pos = get(hObject, 'CurrentPoint');
% set(handles.currentPoint, 'String',['Current Point [ ',num2str(pos(1)),' , ', num2str(pos(2)),' ]']);
end
