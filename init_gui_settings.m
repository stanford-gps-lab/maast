function init_gui()
%*************************************************************************
%*     Copyright c 2001 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% globals for GUI objects

global SETTINGS_TR_HNDL SETTINGS_CLOSE_HNDL SETTINGS_WIND_HNDL;
global SETTINGS_TR_DAT SETTINGS_TR_FILE TRUTHFLAG;
global SETTINGS_BR_HNDL SETTINGS_BR_FILE SETTINGS_BR_DAT
global GUISET_RUN_TAGS GUISET_RUN_HNDL

% Settings Menu
SETTINGS_TR_MENU = {'Almanac (No Truth Data)', 'January 11, 2000', 'April 6, 2000', 'June 6, 2000', 'July 2, 2000',...
    'July 15, 2000', 'March 31, 2001', 'September 7, 2002', 'September 8, 2002'};

% Data contains arays of filename, almanac week to use, time to start, and
% time to end for the truth day selected
SETTINGS_TR_FILE  = {'' , 'format_truth_000111', 'format_truth_000406', 'format_truth_000606', 'format_truth_000702',...
    'format_truth_000715.mat', 'format_truth_010331', 'format_truth_020907.mat', 'format_truth_020908.mat'};
SETTINGS_TR_DAT  = [[0 0 0]; [20 172800 259200]; [32 345600 432000]; [41 172800 259200]; [45 0 86400];...
    [46 518400 604800]; [83 518400 604800]; [158 518400 604800];  [159 0 86400]];
SETTINGS_TR_TAGS = {'SETIN1', 'SETIN2', 'SETIN3', 'SETIN4', 'SETIN5', 'SETIN6', 'SETIN7', 'SETIN8', 'SETIN9'};

% Brazil menus
SETTINGS_BR_MENU = {'January 11, 2000', 'April 6, 2000', 'April 7, 2000', 'July 15, 2000', 'July 16, 2000',...
                    'March 31, 2001', 'February 18, 2002', 'February 19, 2002', 'February 20, 2002'};
SETTINGS_BR_FILE = {'format_brazil_000111', 'format_brazil_000406', 'format_brazil_000407',...
                    'format_brazil_000715', 'format_brazil_000716', 'format_brazil_010331',...
                    'format_brazil_020218', 'format_brazil_020219', 'format_brazil_020220'};
SETTINGS_BR_DAT  = [[20 172800 259200]; [32 345600 432000]; [32 432000 518400];  [46 518400 604800]; [47 0 86400];...
                     [83 518400 604800]; [130 86400 172800];[130 172800 259200];[130 259200 345600];];
SETTINGS_BR_TAGS = {'SETBR1', 'SETBR2', 'SETBR3', 'SETBR4', 'SETBR5', 'SETBR6', 'SETBR7', 'SETBR8', 'SETBR9'};

% Run Options buttons
GUISET_RUN_TAGS = {'BRAZPARMS', 'RTR_FLAG', 'IPP_SPREAD_FLAG'};
GUISET_RUN_STRINGS = {'Use Brazil Parameters', 'Use Real Time R-irreg', 'Use IPP Spread Metric'};

for i = 1:length(GUISET_RUN_TAGS)
    GUISET_RUN_HNDL(i) = findobj('Tag', GUISET_RUN_TAGS{i});
    set(GUISET_RUN_HNDL(i), 'Value', 0);
    set(GUISET_RUN_HNDL(i), 'String', GUISET_RUN_STRINGS{i});
end;

% handles for buttons
%deactivate buttons without corresponding files 
%default is first active one on the list

%Input buttons
default=1;
for i = 1:length(SETTINGS_TR_TAGS)
    SETTINGS_TR_HNDL(i) = findobj('Tag',SETTINGS_TR_TAGS{i});
    set(SETTINGS_TR_HNDL(i), 'String', SETTINGS_TR_MENU(i));
    if(isempty(SETTINGS_TR_FILE{i}) & default == 0) 
      set(SETTINGS_TR_HNDL(i), 'Enable', 'off', 'Value', 0);
    else  
      set(SETTINGS_TR_HNDL(i), 'Enable', 'on');
      if (default)
        set(SETTINGS_TR_HNDL(i), 'Value', 1);
        TRUTH_FLAG = 0; % Default;
        default=0;
      else
        set(SETTINGS_TR_HNDL(i), 'Value', 0);
      end   
    end
end

% Brazil Menu, all start unselected
for i = 1:length(SETTINGS_BR_TAGS)
    SETTINGS_BR_HNDL(i) = findobj('Tag',SETTINGS_BR_TAGS{i});
    set(SETTINGS_BR_HNDL(i), 'String', SETTINGS_BR_MENU(i));
    if(isempty(SETTINGS_BR_FILE{i})) 
      set(SETTINGS_BR_HNDL(i), 'Enable', 'off', 'Value', 0);
    else  
      set(SETTINGS_BR_HNDL(i), 'Enable', 'on', 'Value', 0);
    end
end

SETTINGS_CLOSE_HNDL = findobj('Tag', 'SETCLOSE');
SETTINGS_WIND_HNDL = findobj('Tag', 'SETTINGS');