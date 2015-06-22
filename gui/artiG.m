function varargout = artiG(varargin)
% ARTIG MATLAB code for artiG.fig
%      ARTIG, by itself, creates a new ARTIG or raises the existing
%      singleton*.
%
%      H = ARTIG returns the handle to a new ARTIG or the handle to
%      the existing singleton*.
%
%      ARTIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARTIG.M with the given input arguments.
%
%      ARTIG('Property','Value',...) creates a new ARTIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before artiG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to artiG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help artiG

% Last Modified by GUIDE v2.5 19-May-2015 12:23:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @artiG_OpeningFcn, ...
                   'gui_OutputFcn',  @artiG_OutputFcn, ...
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


% --- Executes just before artiG is made visible.
function artiG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to artiG (see VARARGIN)

% Choose default command line output for artiG
list=dir('*.mif');
for i=1:numel(list)
    handles.allsubjects{i}=list(i).name;
end

set(handles.subjectMenu,'String',handles.allsubjects,'Value',1)

handles.subject=handles.allsubjects{get(handles.subjectMenu,'Value')}(1:end-4);
handles.output = hObject;
handles.img = read_mrtrix(strcat(handles.subject,'.mif'));
if exist(strcat(handles.subject,'.labels.txt'))
    handles.labels=dlmread(strcat(handles.subject,'.labels.txt'));
else
    handles.labels=ones(handles.img.dim(3),handles.img.dim(4))*-1;
end
if exist(strcat(handles.subject,'.labels_local.mat'))
    tmp=load(strcat(handles.subject,'.labels_local.mat'));
    handles.labels_local=tmp.labels_local;
else
    handles.labels_local=cell(handles.img.dim(3),handles.img.dim(4));
end
handles.xcoord=floor(handles.img.dim(1)/2);
handles.ycoord=floor(handles.img.dim(2)/2);
handles.zcoord=1;
handles.dir=1;

drawNow(hObject,[],handles);
guidata(hObject, handles);

% UIWAIT makes artiG wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = artiG_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in previousSlice.
function previousSlice_Callback(hObject, eventdata, handles)
% hObject    handle to previousSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of previousSlice
val=get(hObject,'Value');
if ( val == 1 )
    [handles.zcoord,handles.dir]=PrevSlice(handles.zcoord,handles.dir,handles);
end
guidata(hObject,handles)
drawNow(hObject,[],handles);


% --- Executes on button press in nextSlice.
function nextSlice_Callback(hObject, eventdata, handles)
% hObject    handle to nextSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nextSlice
val=get(hObject,'Value');
if ( val == 1 )
    [handles.zcoord,handles.dir]=NextSlice(handles.zcoord,handles.dir,handles);
end
guidata(hObject,handles)
drawNow(hObject,[],handles);


% --- Executes on button press in prevUnlabeledSlice.
function prevUnlabeledSlice_Callback(hObject, eventdata, handles)
% hObject    handle to prevUnlabeledSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[unlabeledz unlabeleddir]=find(handles.labels==-1);
prevUnlabeled=find(unlabeledz+unlabeleddir*handles.img.dim(3)<handles.zcoord+handles.dir*handles.img.dim(3),1,'last');
if ~isempty(prevUnlabeled)
    handles.zcoord=unlabeledz(prevUnlabeled);
    handles.dir=unlabeleddir(prevUnlabeled);
else
    msgbox('Info: There is no last unlabeled slice.','Info','warn')
end
guidata(hObject,handles)
drawNow(hObject,[],handles);

% --- Executes on button press in nextUnlabeledSlice.
function nextUnlabeledSlice_Callback(hObject, eventdata, handles)
% hObject    handle to nextUnlabeledSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[unlabeledz unlabeleddir]=find(handles.labels==-1);
nextUnlabeled=find(unlabeledz+unlabeleddir*handles.img.dim(3)>handles.zcoord+handles.dir*handles.img.dim(3),1,'first');
if ~isempty(nextUnlabeled)
    handles.zcoord=unlabeledz(nextUnlabeled);
    handles.dir=unlabeleddir(nextUnlabeled);
else
    msgbox('Info: There is no next unlabeled slice.','Info','warn')
end
guidata(hObject,handles)
drawNow(hObject,[],handles);

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dlmwrite(strcat(handles.subject,'.labels.txt'),handles.labels)


% --- Executes on button press in quitButton.
function quitButton_Callback(hObject, eventdata, handles)
% hObject    handle to quitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
unlabeled=find(handles.labels==-1);
choice='Quit anyway';
if ~isempty(unlabeled)
    choice=questdlg('Warning: Some slices have not been labeled.','Warning','Quit anyway','Cancel','Cancel');
end
if strcmp(choice,'Quit anyway')
    dlmwrite(strcat(handles.subject,'.labels.txt'),handles.labels)
    close(handles.figure1)
end

% --- Executes when selected object is changed in labelsButtonGroup.
function labelsButtonGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in labelsButtonGroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'unlabeled'
        handles=qDeleteROI(hObject,[],handles);guidata(hObject,handles);
        handles.labels(handles.zcoord,handles.dir)=-1;
    case 'noArtefact'
         handles=qDeleteROI(hObject,[],handles);guidata(hObject,handles);
       handles.labels(handles.zcoord,handles.dir)=0;
    case 'localArtefact'
        handles=qDeleteROI(hObject,[],handles);guidata(hObject,handles);
        handles.labels(handles.zcoord,handles.dir)=1;
        h=impoly;
        position=wait(h);
        handles.labels_local{handles.zcoord,handles.dir}=position;
        save(strcat(handles.subject,'.labels_local.mat'),'-struct','handles','labels_local')
        % don't go to next slice for this case yet
    case 'mildArtefact'
        handles=qDeleteROI(hObject,[],handles);guidata(hObject,handles);
        handles.labels(handles.zcoord,handles.dir)=2;
    case 'severeArtefact'
        handles=qDeleteROI(hObject,[],handles);guidata(hObject,handles);
        handles.labels(handles.zcoord,handles.dir)=3;
end

[handles.zcoord,handles.dir]=NextSlice(handles.zcoord,handles.dir,handles);
guidata(hObject,handles)
%pause(0.2)
drawNow(hObject, eventdata, handles);
guidata(hObject,handles)

%%
function drawNow(hObject, eventdata, handles)
% main axial view
clims=[0 prctile(reshape(handles.img.data(:,:,:,handles.dir),1,[]),99.9)];

imagesc(rot90(squeeze(handles.img.data(:,:,handles.zcoord,handles.dir))),'Parent',handles.MainAxialView);
set(handles.MainAxialView,'Clim',clims)
colormap gray; axis equal; axis tight; set(gca,'xtick',[],'ytick',[])
text(10,10,sprintf('volume %d of %d',handles.dir, handles.img.dim(4)),'color','w')


% small sagittal view
handles.sag=squeeze(handles.img.data(handles.xcoord,:,:,handles.dir));
handles.sag(:,handles.zcoord)=1000; % this adds a horizontal "burnt-in" line
h=imagesc(rot90(handles.sag),'Parent',handles.SmallSagittalView);
set(handles.SmallSagittalView,'Clim',clims)
set(handles.SmallSagittalView,'xtick',[],'ytick',[])

% small coronal view
handles.cor=squeeze(handles.img.data(:,handles.ycoord,:,handles.dir));
handles.cor(:,handles.zcoord)=1000;
imagesc(rot90(handles.cor),'Parent',handles.SmallCoronalView);
set(handles.SmallCoronalView,'Clim',clims)
set(handles.SmallCoronalView,'xtick',[],'ytick',[])

% update the Radio Button Group
switch handles.labels(handles.zcoord,handles.dir)
    case -1
        set(handles.unlabeled,'Value',1);
    case 0
        set(handles.noArtefact,'Value',1);
    case 1
        set(handles.localArtefact,'Value',1);        
    case 2
        set(handles.mildArtefact,'Value',1);
    case 3
        set(handles.severeArtefact,'Value',1);
end

% update slice/volume indicator
set(handles.SetVolume,'String',num2str(handles.dir));
set(handles.SetSlice,'String',num2str(handles.zcoord));

% draw ROI if exists
if ~isempty(handles.labels_local{handles.zcoord,handles.dir})
    h=impoly(gca,handles.labels_local{handles.zcoord,handles.dir});
end

% Update handles structure
guidata(hObject, handles);

function [currentSlice, currentVolume] = PrevSlice(currentSlice,currentVolume,handles)
if ( currentSlice > 1 )
    currentSlice=currentSlice-1;
elseif ( currentSlice == 1 && currentVolume > 1)
    currentSlice=handles.img.dim(3);
    currentVolume=currentVolume-1;
end

function [currentSlice, currentVolume] = NextSlice(currentSlice,currentVolume,handles)
if ( currentSlice < handles.img.dim(3) )
    currentSlice=currentSlice+1;
elseif ( currentSlice == handles.img.dim(3) && currentVolume ~= handles.img.dim(4))
    currentSlice=1;
    currentVolume=currentVolume+1;
    dlmwrite(strcat(handles.subject,'.labels.txt'),handles.labels)
else
    dlmwrite(strcat(handles.subject,'.labels.txt'),handles.labels)
    unlabeled=numel(find(handles.labels==-1));
    if (unlabeled > 0)
        msgbox({'Info: Reached end of dataset',sprintf('%d slices left unlabeled',unlabeled)})
    else
        msgbox({'Info: Reached end of dataset','All done for this one! :)'})
    end
end

% --- Executes during object creation, after setting all properties.
function subjectMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in subjectMenu.
function subjectMenu_Callback(hObject, eventdata, handles)
% hObject    handle to subjectMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns subjectMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from subjectMenu
choice='Change anyway';
unlabeled=find(handles.labels==-1);
if ~isempty(unlabeled)
    choice=questdlg('Warning: Some slices have not been labeled.','Warning','Change anyway','Cancel','Cancel');
end
if strcmp(choice,'Cancel')
    dlmwrite(strcat(handles.subject,'.labels.txt'),handles.labels)
    set(handles.subjectMenu,'Value',strmatch(strcat(handles.subject,'.mif'),handles.allsubjects,'exact'))
else   
    handles.subject=handles.allsubjects{get(handles.subjectMenu,'Value')}(1:end-4);
    handles.img = read_mrtrix(strcat(handles.subject,'.mif'));
    if exist(strcat(handles.subject,'.labels_local.mat'))
        tmp=load(strcat(handles.subject,'.labels_local.mat'));
        handles.labels_local=tmp.labels_local;
    else
        handles.labels_local=cell(handles.img.dim(3),handles.img.dim(4));
    end
    if exist(strcat(handles.subject,'.labels.txt'))
        handles.labels=dlmread(strcat(handles.subject,'.labels.txt'));
        if isempty(find(handles.labels==-1))
            msgbox('Info: This subject has already been fully labeled.','Info','warn')
        end
    else
        handles.labels=ones(handles.img.dim(3),handles.img.dim(4))*-1;
    end
    
    handles.xcoord=floor(handles.img.dim(1)/2);
    handles.ycoord=floor(handles.img.dim(2)/2);
    handles.zcoord=1;
    handles.dir=1;
    
    drawNow(hObject,[],handles);
end

guidata(hObject, handles);


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
    case {'9','numpad9'}
        handles=qDeleteROI(hObject,[],handles);guidata(hObject,handles);
        handles.labels(handles.zcoord,handles.dir)=-1;
        [handles.zcoord,handles.dir]=NextSlice(handles.zcoord,handles.dir,handles);
    case {'0','numpad0'} % no artefact
        handles=qDeleteROI(hObject,[],handles);guidata(hObject,handles);
        handles.labels(handles.zcoord,handles.dir)=0;
        [handles.zcoord,handles.dir]=NextSlice(handles.zcoord,handles.dir,handles);
    case {'1','numpad1'} % local artefact
        handles=qDeleteROI(hObject,[],handles);guidata(hObject,handles);
        handles.labels(handles.zcoord,handles.dir)=1;
        h=impoly;
        position=wait(h);
        handles.labels_local{handles.zcoord,handles.dir}=position;
        save(strcat(handles.subject,'.labels_local.mat'),'-struct','handles','labels_local')
        [handles.zcoord,handles.dir]=NextSlice(handles.zcoord,handles.dir,handles);
    case {'2','numpad2'} % mild/moderate artefact
        handles=qDeleteROI(hObject,[],handles);guidata(hObject,handles);
        handles.labels(handles.zcoord,handles.dir)=2;
        [handles.zcoord,handles.dir]=NextSlice(handles.zcoord,handles.dir,handles);
    case {'3','numpad3'} % severe artefact
        handles=qDeleteROI(hObject,[],handles);guidata(hObject,handles);
        handles.labels(handles.zcoord,handles.dir)=3;
        [handles.zcoord,handles.dir]=NextSlice(handles.zcoord,handles.dir,handles);
    case 'rightarrow'
        [handles.zcoord,handles.dir]=NextSlice(handles.zcoord,handles.dir,handles);
    case 'leftarrow'
        [handles.zcoord,handles.dir]=PrevSlice(handles.zcoord,handles.dir,handles);
    case 'uparrow'
        [unlabeledz unlabeleddir]=find(handles.labels==-1);
        nextUnlabeled=find(unlabeledz+unlabeleddir*handles.img.dim(3)>handles.zcoord+handles.dir*handles.img.dim(3),1,'first');
        if ~isempty(nextUnlabeled)
            handles.zcoord=unlabeledz(nextUnlabeled);
            handles.dir=unlabeleddir(nextUnlabeled);
        else
            msgbox('Info: There is no next unlabeled slice.','Info','warn')
        end
    case 'downarrow'
        [unlabeledz unlabeleddir]=find(handles.labels==-1);
        prevUnlabeled=find(unlabeledz+unlabeleddir*handles.img.dim(3)<handles.zcoord+handles.dir*handles.img.dim(3),1,'last');
        if ~isempty(prevUnlabeled)
            handles.zcoord=unlabeledz(prevUnlabeled);
            handles.dir=unlabeleddir(prevUnlabeled);
        else
            msgbox('Info: There is no last unlabeled slice.','Info','warn')
        end
    case 's'
        dlmwrite(strcat(handles.subject,'.labels.txt'),handles.labels)

 end

%[handles.zcoord,handles.dir]=NextSlice(handles.zcoord,handles.dir,handles);
guidata(hObject,handles)
drawNow(hObject, [], handles);
guidata(hObject,handles)

        


% --- Executes on button press in editROI.
function editROI_Callback(hObject, eventdata, handles)
% hObject    handle to editROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.labels_local{handles.zcoord,handles.dir})
    h=impoly(gca,handles.labels_local{handles.zcoord,handles.dir});
else
    h=impoly(gca);
end
position=wait(h);
handles.labels_local{handles.zcoord,handles.dir}=position;
save(strcat(handles.subject,'.labels_local.mat'),'-struct','handles','labels_local')
guidata(hObject,handles)
drawNow(hObject, [], handles);
guidata(hObject,handles)

function handles=qDeleteROI(hObject,eventdata, handles)
if ~isempty(handles.labels_local{handles.zcoord,handles.dir})
    choice = questdlg('Are you sure you want to delete the ROI?', 'Delete ROI', 'Yes','No','No');
    switch choice
        case 'Yes'
            handles.labels_local{handles.zcoord,handles.dir}=[];
            save(strcat(handles.subject,'.labels_local.mat'),'-struct','handles','labels_local')
        case 'No'
    end
end



function SetVolume_Callback(hObject, eventdata, handles)
% hObject    handle to SetVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SetVolume as text
%        str2double(get(hObject,'String')) returns contents of SetVolume as a double
handles.dir=str2num(get(hObject,'String'));
guidata(hObject,handles)
drawNow(hObject,[],handles);
handles.dir
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function SetVolume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SetSlice_Callback(hObject, eventdata, handles)
% hObject    handle to SetSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SetSlice as text
%        str2double(get(hObject,'String')) returns contents of SetSlice as a double
handles.zcoord=str2num(get(hObject,'String'));
guidata(hObject,handles)
drawNow(hObject,[],handles);
handles.dir
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SetSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
