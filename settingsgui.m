function varargout = settingsgui(varargin)
% SETTINGSGUI M-file for settingsgui.fig
%      SETTINGSGUI, by itself, creates a new SETTINGSGUI or raises the existing
%      singleton*.
%
%      H = SETTINGSGUI returns the handle to a new SETTINGSGUI or the handle to
%      the existing singleton*.
%
%      SETTINGSGUI('Property','Value',...) creates a new SETTINGSGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to settingsgui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SETTINGSGUI('CALLBACK') and SETTINGSGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SETTINGSGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help settingsgui

% Last Modified by GUIDE v2.5 21-Aug-2003 09:55:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @settingsgui_OpeningFcn, ...
                   'gui_OutputFcn',  @settingsgui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before settingsgui is made visible.
function settingsgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for settingsgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes settingsgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = settingsgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
