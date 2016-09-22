function varargout = face(varargin)
% FACE MATLAB code for face.fig
%      FACE, by itself, creates a new FACE or raises the existing
%      singleton*.
%
%      H = FACE returns the handle to a new FACE or the handle to
%      the existing singleton*.
%
%      FACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACE.M with the given input arguments.
%
%      FACE('Property','Value',...) creates a new FACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before face_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to face_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help face

% Last Modified by GUIDE v2.5 18-Dec-2014 12:02:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @face_OpeningFcn, ...
                   'gui_OutputFcn',  @face_OutputFcn, ...
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


% --- Executes just before face is made visible.
function face_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to face (see VARARGIN)

% Choose default command line output for face
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes face wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = face_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% read image to be recognize
global im;
[filename, pathname] = uigetfile({'*.bmp'},'choose photo');
str = [pathname, filename];
im = imread(str);
if numel(size(im)) > 2
	im = rgb2gray(im);
end
im = imresize(im, [128, 128]);
axes( handles.axes1);
imshow(im);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global im
global reference
global W
global imgmean
global col_of_data
global pathname
global img_path_list

% Ԥ���������?im = double(im(:));
objectone = W'*(im - imgmean);
distance = 100000000;

% ��С���뷨��Ѱ�Һʹ�ʶ��ͼƬ��Ϊ�ӽ��ѵ��ͼ�?for k = 1:col_of_data
    temp = norm(objectone - reference(:,k));
    if(distance>temp)
        aimone = k;
        distance = temp;
        aimpath = strcat(pathname, '/', img_path_list(aimone).name);
        axes( handles.axes2 )
        imshow(aimpath)
    end
end

% ��ʾ���Խ��?% aimpath = strcat(pathname, '/', img_path_list(aimone).name);
% axes( handles.axes2 )
% imshow(aimpath)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global reference
global W
global imgmean
global col_of_data
global pathname
global img_path_list

% ������ȡָ���ļ����µ�ͼƬ128*128
pathname = uigetdir;
img_path_list = dir(strcat(pathname,'/*.bmp'));
img_num = length(img_path_list);
imagedata = [];
if img_num >0
    for j = 1:img_num
        img_name = img_path_list(j).name;
        temp = imread(strcat(pathname, '/', img_name));
	if numel(size(temp)) > 2
		temp = rgb2gray(temp);
	end
	temp = imresize(temp, [128, 128]);
        temp = double(temp(:));
        imagedata = [imagedata, temp];
    end
end
col_of_data = size(imagedata,2);

% ���Ļ� & ����Э�������?imgmean = mean(imagedata,2);
for i = 1:col_of_data
    imagedata(:,i) = imagedata(:,i) - imgmean;
end
covMat = imagedata'*imagedata;
[COEFF, latent, explained] = pcacov(covMat);

% ѡ�񹹳�95%����������ֵ
i = 1;
proportion = 0;
while(proportion < 95)
    proportion = proportion + explained(i);
    i = i+1;
end
p = i - 1;

% ������
W = imagedata*COEFF;    % N*M��
W = W(:,1:p);           % N*p��

% ѵ�������������µı����� p*M
reference = W'*imagedata;


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ѡ����Լ�?
global W
global reference
col_of_data = 60;

pathname = uigetdir;
img_path_list = dir(strcat(pathname,'/*.bmp'));
img_num = length(img_path_list);
testdata = [];
if img_num >0
    for j = 1:img_num
        img_name = img_path_list(j).name;
        temp = imread(strcat(pathname, '/', img_name));
	if numel(size(temp)) > 2
		im = rgb2gray(temp);
	end
	temp = imresize(temp, [128, 128]);
        temp = double(temp(:));
        testdata = [testdata, temp];
    end
end
col_of_test = size(testdata,2);
testdata = center( testdata );
object = W'* testdata;

% ��С���뷨��Ѱ�Һʹ�ʶ��ͼƬ��Ϊ�ӽ��ѵ��ͼ�?% ���������׼ȷ��?num = 0;
for j = 1:col_of_test;
    distance = 1000000000000;
    for k = 1:col_of_data;
        temp = norm(object(:,j) - reference(:,k));
        if(distance>temp)
            aimone = k;
            distance = temp;
        end
    end
    if ceil(j/3)==ceil(aimone/4)
       num = num + 1;
    end
end
accuracy = num/col_of_test;
msgbox(['������׼ȷ��:                   ',num2str(accuracy)],'accuracy')
