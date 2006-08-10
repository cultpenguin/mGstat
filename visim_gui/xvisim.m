function varargout = xvisim(varargin)
% XVISIM M_FILE-file for xvisim.fig
%      XVISIM, by itself, creates a new XVISIM or raises the existing
%      singleton*.
%
%      H = XVISIM returns the handle to a new XVISIM or the handle to
%      the existing singleton*.
%
%      XVISIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in XVISIM.M_FILE with the given input arguments.
%
%      XVISIM('Property','Value',...) creates a new XVISIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before xvisim_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to xvisim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help xvisim

% Last Modified by GUIDE v2.5 10-Aug-2006 11:03:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @xvisim_OpeningFcn, ...
                   'gui_OutputFcn',  @xvisim_OutputFcn, ...
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


% --- Executes just before xvisim is made visible.
function xvisim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to xvisim (see VARARGIN)

% Choose default command line output for xvisim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes xvisim wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = xvisim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function m_File_Callback(hObject, eventdata, handles)
% hObject    handle to m_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function m_File_View_Callback(hObject, eventdata, handles)
% hObject    handle to m_File_View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function m_OpenPar_Callback(hObject, eventdata, handles)
% hObject    handle to m_OpenPar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function m_DefaultPar_Callback(hObject, eventdata, handles)
% hObject    handle to m_DefaultPar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


