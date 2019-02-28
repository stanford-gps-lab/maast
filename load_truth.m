function truth_matrix=load_truth(wrsdata, satdata) 

global COL_USR_LL COL_SAT_PRN
global TRUTH_FILE SETTINGS_TR_HNDL SETTINGS_BR_HNDL;

i = gui_readselect(SETTINGS_TR_HNDL);
if (isempty(i)) % Truth data from the brazil menu must have been selected
    i = gui_readselect(SETTINGS_BR_HNDL) + length(SETTINGS_TR_HNDL);
end;

nwrs=size(wrsdata,1);
nsat=size(satdata,1);

% the following code assumes that the file loaded contains the matrix data,
% that time is in column 1, station is in column 2, svn in column 3, lat in
% column 4, lon in column 5, az in column 6, el in column 7, delay in
% column 8, and sigma in column 9.
% lat, lon, az and el are already in radians, though az may be larger than
% pi
% The best way to meet these conditions is to follow the following steps:
% 1. download the original file, Truth_tecs_yymmdd.txt
% 2. call tm_decimate_data and with the intermediate output,
% 3. call tm_write_conus_data (make sure height is set to 350000)
%    (I've followed the convention of calling the final output
%    format_truth_yymmdd
% If these steps are followed, then the same idx2maastwrs can be used as is
% used for Sep 7-8, 2002 (or Feb 19, 2002 for Brazil).  Because tm_decimate_data makes use of
% tm_get_wre_id which assigns a constant number to each WRE. Set zero_based to 1
% -- M. DeLand

if i == 8 | i == 9 % Sep 7, 2002  Sep 8, 2002
    idx2maastwrs = [6 6 6 3 3 3 4 4 4 8 8 8 7 7 7 2 2 2 12 12 12 11 11 11 13 13 13 14 14 14 ...
                    10 10 10 15 15 15 17 17 17 1 1 1 23 23 23 19 19 19 18 18 18 20 20 20 21 21 21 ...
                    22 22 22 9 9 9 24 24 24 25 25 25 5 5 5 16 16 16]';
    % This idx2maastwrs will work with any file decimated using the latest
    % version of the Raytheon threat model assuming that the file
    % tm_get_wre_id was used.
    svn2prn = create_svn2prn(2002, 9, 7);
    svn2prn = svn2prn';
    
    %change from SVN to PRN ***NOTE SVN 14 & 18 are mislabeled should be 41 and
    %54 respectively.  Instead the are PRNs
    % Seems to be an anomoly for these days.
    svn2prn(14) = 14;
    svn2prn(18) = 18;
    zero_based = 1;

elseif i == 6 % July 15, 2000
    svn2prn = create_svn2prn(2000, 7, 15);
    svn2prn = svn2prn';
    idx2maastwrs = [6 3 4 8 7 2 12 11 13 10 15 17 1 23 19 18 20 21 22 9 24 25 5 16]';
    zero_based = 0;

elseif i == 5  % July 2, 2000
    idx2maastwrs = [6 6 6 3 3 3 4 4 4 8 8 8 7 7 7 2 2 2 12 12 12 11 11 11 13 13 13 14 14 14 ...
                    10 10 10 15 15 15 17 17 17 1 1 1 23 23 23 19 19 19 18 18 18 20 20 20 21 21 21 ...
                    22 22 22 9 9 9 24 24 24 25 25 25 5 5 5 16 16 16]';
    zero_based = 1;
    svn2prn = create_svn2prn(2000, 7, 2);
    svn2prn = svn2prn';
elseif i == 4 % June 6, 2000
    idx2maastwrs = [6 6 6 3 3 3 4 4 4 8 8 8 7 7 7 2 2 2 12 12 12 11 11 11 13 13 13 14 14 14 ...
                    10 10 10 15 15 15 17 17 17 1 1 1 23 23 23 19 19 19 18 18 18 20 20 20 21 21 21 ...
                    22 22 22 9 9 9 24 24 24 25 25 25 5 5 5 16 16 16]';
    zero_based = 1;
    svn2prn = create_svn2prn(2000, 6, 6);
    svn2prn = svn2prn';
    svn2prn(18) = 18;
elseif i == 7 % March 31, 2001
    svn2prn = create_svn2prn(2001, 3, 31);
    svn2prn = svn2prn';
    % This file has the same trouble as September 7-8
    svn2prn(14) = 14;
    svn2prn(18) = 18;
    % For reasons unkown, this file has no station 1, and starts indexing
    % at station 2
    idx2maastwrs = [NaN 6 3 4 8 7 2 12 11 13 14 10 15 17 1 23 19 18 20 21 22 9 24 25 5 16]';
    zero_based = 0;
elseif i == 2 % Jan 11, 2000
    svn2prn = create_svn2prn(2000, 1, 11);
    svn2prn = svn2prn';
    svn2prn(14) = 14;
    svn2prn(18) = 18;
    idx2maastwrs = [6 3 4 8 7 2 12 11 13 14 10 15 17 1 23 19 18 20 21 22 9 24 25 5 16]';
    zero_based = 0;
elseif i == 3 % April 6, 2000
    svn2prn = create_svn2prn(2000, 4, 6);
    svn2prn = svn2prn';
    svn2prn(14) = 14;
    svn2prn(18) = 18;
    idx2maastwrs = [6 3 4 8 7 2 12 11 13 14 10 15 17 1 23 19 18 20 21 22 9 24 25 5 16]';
    zero_based = 0;
elseif i == 10 % January 11, 2000 (Brazil)
    svn2prn = create_svn2prn(2000, 1, 11);
    svn2prn = svn2prn';
    svn2prn(14) = 14;
    svn2prn(18) = 18;
    idx2maastwrs = [11 6 7 10 12 2 9 3 8 4 5 1]';
    zero_based = 1;
elseif i == 11 % April 6, 2000 (Brazil)
    svn2prn = create_svn2prn(2000, 4, 6);
    svn2prn = svn2prn';
    svn2prn(14) = 14;
    svn2prn(18) = 18;
    idx2maastwrs = [11 6 7 10 12 2 9 3 8 4 5 1]';
    zero_based = 1;
elseif i == 12 % April 7, 2000 (Brazil)
    svn2prn = create_svn2prn(2000, 4, 7);
    svn2prn = svn2prn';
    svn2prn(14) = 14;
    svn2prn(18) = 18;
    idx2maastwrs = [11 6 7 10 12 2 9 3 8 4 5 1]';
    zero_based = 1;
elseif i == 13 % July 15, 2000 (Brazil)
    svn2prn = create_svn2prn(2000, 7, 15);
    svn2prn = svn2prn';
    svn2prn(14) = 14;
    svn2prn(18) = 18;
    idx2maastwrs = [11 6 7 10 12 2 9 3 8 4 5 1]';
    zero_based = 1;
elseif i == 14 % July 16, 2000 (Brazil)
    svn2prn = create_svn2prn(2000, 7, 16);
    svn2prn = svn2prn';
    svn2prn(14) = 14;
    svn2prn(18) = 18;
    idx2maastwrs = [11 6 7 10 12 2 9 3 8 4 5 1]';
    zero_based = 1;
elseif i == 15 % March 31, 2001 (Brazil)
    svn2prn = create_svn2prn(2001, 3, 31);
    svn2prn = svn2prn';
    svn2prn(14) = 14;
    svn2prn(18) = 18;
    idx2maastwrs = [11 6 7 10 12 2 9 3 8 4 5 1]';
    zero_based = 1;
elseif i == 16 % February 18, 2002 (Brazil)
    svn2prn = create_svn2prn(2002, 2, 18);
    svn2prn = svn2prn';
    idx2maastwrs = [11 6 7 10 12 2 9 3 8 4 5 1]';
    zero_based = 1;
elseif i == 17 % February 19, 2002 (Brazil)
    svn2prn = create_svn2prn(2002, 2, 19);
    svn2prn = svn2prn';
    idx2maastwrs = [11 6 7 10 12 2 9 3 8 4 5 1]';
    zero_based = 1;
elseif i == 18 % February 20, 2002 (Brazil)
    svn2prn = create_svn2prn(2002, 2, 20);
    svn2prn = svn2prn';
    idx2maastwrs = [11 6 7 10 12 2 9 3 8 4 5 1]';
    zero_based = 1;
end

  %load data and get units into correct format
  eval (['load ' TRUTH_FILE{1}]);
  
  % Some receivers in brazil have identical measurements, the following two
  % lines remove any duplicates.
  [b i j] = unique(data(:, 1:3), 'rows');
  data = data(i, :);
  truth_matrix = data;
  clear data;
  
  %supertruth data offset
  truth_matrix(:,1) = truth_matrix(:,1) + 630763213;    
  truth_matrix(:,1) = mod(truth_matrix(:,1),3600*24); 
  
  kk=find(truth_matrix(:,6)> pi);
  truth_matrix(kk,6) = truth_matrix(kk,6) - 2*pi;
  
  %change from SVN to PRN ***NOTE SVN 14 & 18 are mislabeled should be 41 and
  %54 respectively.  Instead the are PRNs
  truth_matrix(:,3) = svn2prn(truth_matrix(:,3)); 
    
  %convert PRN to storage index
  n2prn = satdata(:,COL_SAT_PRN);
  prn2n = repmat(NaN,max(n2prn),1);
  prn2n(n2prn)=1:nsat;
  truth_matrix(:,3) = prn2n(truth_matrix(:,3));
    
  %adjust station number to match MAAST WRSs
  truth_matrix(:,2) = idx2maastwrs(truth_matrix(:,2) + zero_based); % zero based
