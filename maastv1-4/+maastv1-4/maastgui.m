function varargout = maastgui(varargin)
% MAASTGUI M-file for maastgui.fig
%      MAASTGUI, by itself, creates a new MAASTGUI or raises the existing
%      singleton*.
%
%      H = MAASTGUI returns the handle to a new MAASTGUI or the handle to
%      the existing singleton*.
%
%      MAASTGUI('Property','Value',...) creates a new MAASTGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to maastgui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MAASTGUI('CALLBACK') and MAASTGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MAASTGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help maastgui

% Last Modified by GUIDE v2.5 21-Aug-2003 09:41:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @maastgui_OpeningFcn, ...
                   'gui_OutputFcn',  @maastgui_OutputFcn, ...
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


% --- Executes just before maastgui is made visible.
function maastgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for maastgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maastgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = maastgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
