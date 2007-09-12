function varargout = vvisim(varargin)
% VVISIM M-file for vvisim.fig
%      VVISIM, by itself, creates a new VVISIM or raises the existing
%      singleton*.
%
%      H = VVISIM returns the handle to a new VVISIM or the handle to
%      the existing singleton*.
%
%      VVISIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VVISIM.M with the given input arguments.
%
%      VVISIM('Property','Value',...) creates a new VVISIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vvisim_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vvisim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vvisim

% Last Modified by GUIDE v2.5 12-Sep-2007 15:33:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vvisim_OpeningFcn, ...
                   'gui_OutputFcn',  @vvisim_OutputFcn, ...
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


% --- Executes just before vvisim is made visible.
function vvisim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vvisim (see VARARGIN)

% Choose default command line output for vvisim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Update handles structure
init(hObject,[] ,handles);
update_handle_all(hObject, eventdata, handles);

% UIWAIT makes vvisim wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = vvisim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% INIT
function init(hObject, eventdata, handles)
data=guidata(hObject);
data.V=visim_init;
data.V.nsim=10;
guidata(hObject,data);

%% UPDATE HANDLES
function update_handle_all(hObject, eventdata, handles)
update_handle_model(hObject, eventdata, handles)
update_handle_data(hObject, eventdata, handles)
update_handle_spatial(hObject, eventdata, handles)
update_handle_distribution(hObject, eventdata, handles)

function update_handle_model(hObject, eventdata, handles)
function update_handle_data(hObject, eventdata, handles)
data=guidata(hObject);
function update_handle_spatial(hObject, eventdata, handles)
function update_handle_distribution(hObject, eventdata, handles)


%% plotting
function plot_kernel(hObject, eventdata, handles)
data=guidata(hObject);
axes(handles.axMain);
visim_plot_kernel(data.V);

%%
% --------------------------------------------------------------------
function mFile_Callback(hObject, eventdata, handles)
% hObject    handle to mFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mFileOpen_Callback(hObject, eventdata, handles)
% hObject    handle to mFileOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
try
	[filename,pathname]=uigetfile( ...
    {'*.par;*.Par','All visim parameter files'; ...
     '*','All Files'},...
    'Pick visim parameter file');
catch
end

cd(pathname);
data.V=read_visim(filename);
guidata(hObject,data);
update_handle_all(hObject, eventdata, handles);





% --------------------------------------------------------------------
function mPlot_Callback(hObject, eventdata, handles)
% hObject    handle to mPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mPlotKernel_Callback(hObject, eventdata, handles)
% hObject    handle to mPlotKernel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plot_kernel(hObject, eventdata, handles)



% --------------------------------------------------------------------
function mPlotHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to mPlotHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
axes(handles.axMain);
visim_plot_hist(data.V);

% --------------------------------------------------------------------
function mPlotSim_Callback(hObject, eventdata, handles)
% hObject    handle to mPlotSim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
axes(handles.axMain);
visim_plot_sim(data.V,1);


% --------------------------------------------------------------------
function mPlotEtype_Callback(hObject, eventdata, handles)
% hObject    handle to mPlotEtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
axes(handles.axMain);
visim_plot_etype(data.V);




% --------------------------------------------------------------------
function mRun_Callback(hObject, eventdata, handles)
% hObject    handle to mRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mRunEstimate_Callback(hObject, eventdata, handles)
% hObject    handle to mRunEstimate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
axes(handles.axMain);
data.V.cond_sim=0;
guidata(hObject,data)
update_handle_all(hObject, eventdata, handles);

data.V=visim(data.V);
guidata(hObject,data)
update_handle_all(hObject, eventdata, handles);


% --------------------------------------------------------------------
function mRunSimulate_Callback(hObject, eventdata, handles)
% hObject    handle to mRunSimulate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
axes(handles.axMain);
data.V=visim(data.V);
guidata(hObject,data)
update_handle_all(hObject, eventdata, handles);





% --------------------------------------------------------------------
function mFileDefault_Callback(hObject, eventdata, handles)
% hObject    handle to mFileDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
data.V=visim_init;
data.V.nsim=10;
guidata(hObject,data);



% --------------------------------------------------------------------
function mSetup_Callback(hObject, eventdata, handles)
% hObject    handle to mSetup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mSetupSpatialModel_Callback(hObject, eventdata, handles)
% hObject    handle to mSetupSpatialModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mSetupGeometry_Callback(hObject, eventdata, handles)
% hObject    handle to mSetupGeometry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mSetupDistribution_Callback(hObject, eventdata, handles)
% hObject    handle to mSetupDistribution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


