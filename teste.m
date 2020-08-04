function varargout = sample(varargin)
% SAMPLE M-file for sample.fig
%      SAMPLE, by itself, creates a new SAMPLE or raises the existing
%      singleton*.
%
%      H = SAMPLE returns the handle to a new SAMPLE or the handle to
%      the existing singleton*.
%
%      SAMPLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAMPLE.M with the given input arguments.
%
%      SAMPLE('Property','Value',...) creates a new SAMPLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sample_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sample_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sample

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sample_OpeningFcn, ...
                   'gui_OutputFcn',  @sample_OutputFcn, ...
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

% --- Executes just before sample is made visible.
function sample_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sample (see VARARGIN)

% Choose default command line output for sample
handles.output = hObject;
clc
imaqreset
warning off
set(handles.pushbutton4,'Enable','Off');


x = 0;
handles.x = x;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sample wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sample_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in cmd_ini.
function cmd_ini_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_ini (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
axes(handles.preview)
vidObj1 = videoinput('winvideo',2,'YUY2_320x240');
% set(vidObj1,'ReturnedColorSpace','RGB');   % setting the properties of object
set(vidObj1,'FramesPerTrigger',1);   
set(vidObj1,'TriggerRepeat',inf);        
triggerconfig(vidObj1,'manual');  
videoRes = get(vidObj1, 'VideoResolution');

numberOfBands = get(vidObj1, 'NumberOfBands');
handleToImage = image( zeros([videoRes(2), videoRes(1), numberOfBands], 'uint8') );
%set(handles.live_video_axes,'Visible','on');
%preview(vidObj1)
set(handles.cmd_track,'Enable','Off');
set(handles.pushbutton4,'Enable','On');
set(handles.pushbutton5,'Enable','Off');
preview(vidObj1, handleToImage)
handles.vidObj1 = vidObj1;
handles.vidObj1 = vidObj1;
handles.videoRes = videoRes;
handles.numberOfBands = numberOfBands;
% Update handles structure
guidata(hObject, handles);







% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure


delete(hObject);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
vidObj1 = handles.vidObj1;
axes(handles.target);

imgy = getsnapshot(vidObj1);
img = ycbcr2rgb(imgy);
imshow(img)
[M_R M_G M_B] = get_MY_THRESHOLDING(img);
[r c d]=size(img);
im = img;
range = 50;
red = M_R;
grn = M_G;
blu = M_B;
for i1=1:r
    for i2=1:c
        if( (im(i1,i2,1)>red-range) && (im(i1,i2,1)<red+range) && (im(i1,i2,2)>grn-range) && (im(i1,i2,2)<grn+range) && (im(i1,i2,3)>blu-range) && (im(i1,i2,3)<blu+range) )
            img_bw(i1,i2)=255;
        end
    end
end
img_bw =~ img_bw;
% figure, imshow(img_bw)

% [r c f]=size(img_target);
% [M_R M_G M_B] = get_MY_THRESHOLDING(img_target);
% set(handles.cmd_track,'Enable','On');
% set(handles.pushbutton5,'Enable','Off');
% 
% handles.M_R = M_R;
% handles.M_G = M_G;
% handles.M_B = M_B;
% handles.r = r;
% handles.c = c;
% handles.f = f;
%% Image Pre-processing
% Median Filtering
img(:,:,1) = medfilt2(img(:,:,1),[3 3]);
% title('Image Red Channel after Median Filtering')

img(:,:,2) = medfilt2(img(:,:,2),[3 3]);
% title('Image Green Channel after Median Filtering')

img(:,:,3) = medfilt2(img(:,:,3),[3 3]);
% title('Image Blue Channel after Median Filtering')
% figure
% imshow(img)
% title('Complete Image after Median Filtering')

% Thresholding and Gray Region Identification
img_thresh1 = abs(img(:,:,1)-img(:,:,2))<=15 & img(:,:,1) >70 & img(:,:,2) >70;
% title('Subtraction of Red & Green Channel for Gray Region Identification')

img_thresh2 = abs(img(:,:,2)-img(:,:,3))<=20 & img(:,:,2) >70 & img(:,:,3) >70;
% title('Subtraction of Green & Blue Channel for Gray Region Identification')

img_thresh3 = abs(img(:,:,1)-img(:,:,3))<=20 & img(:,:,1) >70 & img(:,:,3) >70;
% title('Subtraction of Red & Blue Channel for Gray Region Identification')

%% Grey Region Identification
img_thresh = img_thresh1.*img_thresh2.*img_thresh3;
% title('Gray Region Identification - All channels Combined')
jc = 0;
% imshow(img_thresh)
axes(handles.target);
imshow(img)

[labc,numc]=bwlabel(img_bw,8);
sizeblobc = zeros(1,numc);
    for i=1:numc,
    sizeblobc(i) = length(find(labc==i));
    
%     [maxno largestBlobNo] = max(sizeblob);
    if (sizeblobc(i)>50) & (sizeblobc(i)<10000)
        jc=jc+1;
        tabc(jc) = i;
    end
    end
j = 0;    
    [lab,num]=bwlabel(img_thresh,8);
sizeblob = zeros(1,num);
    for i=1:num,
    sizeblob(i) = length(find(lab==i));
    
%     [maxno largestBlobNo] = max(sizeblob);
    if (sizeblob(i)>200) & (sizeblob(i)<40000)
        j=j+1;
        tab(j) = i;
    end
    end
    
    sizeblobc
    sizeblob
    if j == 0 & jc == 0
        set(handles.text2,'string','No defect Detected.');
        set(handles.text3,'string','No defect Detected.');
    elseif j > 0 & jc == 0
        x = ['Hole defects Detected:' num2str(j)];
        set(handles.text2,'string',x);
        imshow(img);
        for i=1:j
            outim = zeros(size(img_thresh),'uint8');
            outim(find(lab==tab(i))) = 1;
            last=255*outim;

            last_bw=bwlabel(last,8);
            cen=regionprops(last_bw,'BoundingBox');        %to find centriod

            rectangle('Position',[cen.BoundingBox(1),cen.BoundingBox(2),cen.BoundingBox(3),cen.BoundingBox(4)],...
            'EdgeColor','r','LineWidth',2 )
        end
        hold on
%         disp('Sending sms...')
%         ser_gsm = serial('COM15');
%         pause(1)
%         fopen(ser_gsm);
%         ser_gsm.terminator = 'CR';
%         fprintf(ser_gsm,'at+cmgf=1');
%         pause(1)
%         fprintf(ser_gsm,'at+cmgs="+919920669916"');
%         pause(0.5)
%         ser_gsm.terminator = 26;
        b = ['Hole defects Detected on Leaf are:' num2str(j)]
%         fprintf(ser_gsm,b);
%         disp('SMS Sent!')
%         fclose(ser_gsm);

        
    elseif jc > 0 & j == 0
        x = ['Color defects Detected:' num2str(jc)];
        set(handles.text3,'string',x);
        imshow(img);
        for i=1:jc
            outim = zeros(size(img_bw),'uint8');
            outim(find(labc==tabc(i))) = 1;
            last=255*outim;

            last_bw=bwlabel(last,8);
            cen=regionprops(last_bw,'BoundingBox');        %to find centriod

            rectangle('Position',[cen.BoundingBox(1),cen.BoundingBox(2),cen.BoundingBox(3),cen.BoundingBox(4)],...
            'EdgeColor','b','LineWidth',2 )
            hold on
        end
    
%         disp('Sending sms...')
%         ser_gsm = serial('COM10');
%         pause(1)
%         fopen(ser_gsm);
%         ser_gsm.terminator = 'CR';
%         fprintf(ser_gsm,'at+cmgf=1');
%         pause(1)
%         fprintf(ser_gsm,'at+cmgs="+919920669916"');
%         pause(0.5)
%         ser_gsm.terminator = 26;
        b = ['Color defects Detected on Leaf are:' num2str(jc)]
%         fprintf(ser_gsm,b);
%         disp('SMS Sent!')
%         fclose(ser_gsm);
    else
        x = ['Hole defects Detected:' num2str(j)];
        set(handles.text2,'string',x);
        imshow(img);
        for i=1:j
            outim = zeros(size(img_thresh),'uint8');
            outim(find(lab==tab(i))) = 1;
            last=255*outim;

            last_bw=bwlabel(last,8);
            cen=regionprops(last_bw,'BoundingBox');        %to find centriod

            rectangle('Position',[cen.BoundingBox(1),cen.BoundingBox(2),cen.BoundingBox(3),cen.BoundingBox(4)],...
            'EdgeColor','r','LineWidth',2 )
        end
        hold on
%         disp('Sending sms...')
%         ser_gsm = serial('COM10');
%         pause(1)
%         fopen(ser_gsm);
%         ser_gsm.terminator = 'CR';
%         fprintf(ser_gsm,'at+cmgf=1');
%         pause(1)
%         fprintf(ser_gsm,'at+cmgs="+919920669916"');
%         pause(0.5)
%         ser_gsm.terminator = 26;
        b = ['Hole defects Detected on Leaf are:' num2str(j)]
%         fprintf(ser_gsm,b);
%         disp('SMS Sent!')
%         fclose(ser_gsm);
        
        x = ['Color defects Detected:' num2str(jc)];
        set(handles.text3,'string',x);
%         imshow(img);
        
        for i=1:jc
            outim = zeros(size(img_bw),'uint8');
            outim(find(labc==tabc(i))) = 1;
            last=255*outim;

            last_bw=bwlabel(last,8);
            cen=regionprops(last_bw,'BoundingBox');        %to find centriod

            rectangle('Position',[cen.BoundingBox(1),cen.BoundingBox(2),cen.BoundingBox(3),cen.BoundingBox(4)],...
            'EdgeColor','b','LineWidth',2 )
            hold on
        end
    
    disp('Sending sms...')
    ser_gsm = serial('COM10');
    pause(1)
%     fopen(ser_gsm);
%     ser_gsm.terminator = 'CR';
%     fprintf(ser_gsm,'at+cmgf=1');
%     pause(1)
%     fprintf(ser_gsm,'at+cmgs="+919920669916"');
%     pause(0.5)
%     ser_gsm.terminator = 26;
    b = ['Color defects Detected on Leaf are:' num2str(jc)]
%     fprintf(ser_gsm,b);
%     disp('SMS Sent!')
%     fclose(ser_gsm);
        
        
        
end

    
        
    
    

guidata(hObject, handles);

% --- Executes on button press in pushbutton5.



% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
