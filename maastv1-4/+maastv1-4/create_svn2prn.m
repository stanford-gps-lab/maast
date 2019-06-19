function svn2prn = create_svn2prn(year, month, day)

% Create an svn2prn conversion table.
% This is to be used in the file load_truth in order to convert super truth
% SVNs to maast PRNs.  This file is time-dependent, so any future prn
% additions must be made here.

currentdate = [year month day];
% For each SVN, test to determine if the current date is between the
% satellite usable date and final failure date

% SVN 1
if (before([1978 3 29], currentdate) & before(currentdate, [1985 7 17]))
    svn2prn(1) = 4;
else
    svn2prn(1) = NaN;
end;

% SVN 2
if (before([1978 7 14], currentdate) & before(currentdate, [1988 2 12]))
    svn2prn(2) = 7;
else
    svn2prn(2) = NaN;
end;

% SVN 3
if (before([1978 11 13], currentdate) & before(currentdate, [1992 5 18]))
    svn2prn(3) = 6;
else
    svn2prn(3) = NaN;
end;

% SVN 4
if (before([1979 1 8], currentdate) & before(currentdate, [1989 10 14]))
    svn2prn(4) = 8;
else
    svn2prn(4) = NaN;
end;

% SVN 5
if (before([1980 2 27], currentdate) & before(currentdate, [1984 5 11]))
    svn2prn(5) = 5;
else
    svn2prn(5) = NaN;
end;

% SVN 6
if (before([1980 5 16], currentdate) & before(currentdate, [1991 3 6]))
    svn2prn(6) = 9;
else
    svn2prn(6) = NaN;
end;

% SVN 7, Never usable
svn2prn(7) = NaN;

% SVN 8
if (before([1983 8 10], currentdate) & before(currentdate, [1993 5 4]))
    svn2prn(8) = 11;
else
    svn2prn(8) = NaN;
end;

% SVN 9
if (before([1984 7 19], currentdate) & before(currentdate, [1994 2 28]))
    svn2prn(9) = 13;
else
    svn2prn(9) = NaN;
end;

% SVN 10
if (before([1984 10 3], currentdate) & before(currentdate, [1995 11 18]))
    svn2prn(10) = 12;
else
    svn2prn(10) = NaN;
end;

% SVN 11
if (before([1985 10 30], currentdate) & before(currentdate, [1994 4 13]))
    svn2prn(11) = 3;
else
    svn2prn(11) = NaN;
end;

% SVN 12 -- never existed
svn2prn(12) = NaN;

% SVN 13
if (before([1989 8 10], currentdate))
    svn2prn(13) = 2;
else
    svn2prn(13) = NaN;
end;

% SVN 14
if (before([1989 4 15], currentdate) & before(currentdate, [2000 3 26]))
    svn2prn(14) = 4;
else
    svn2prn(14) = NaN;
end;

% SVN 15
if (before([1990 10 1], currentdate))
    svn2prn(15) = 15;
else
    svn2prn(15) = NaN;
end;

% SVN 16
if (before([1989 10 14], currentdate) & before(currentdate, [2000 10 13]))
    svn2prn(16) = 16;
else
    svn2prn(16) = NaN;
end;

% SVN 17
if (before([1990 1 6], currentdate))
    svn2prn(17) = 17;
else
    svn2prn(17) = NaN;
end;

% SVN 18
if (before([1990 2 14], currentdate) & before(currentdate, [2000 8 18]))
    svn2prn(18) = 18;
else
    svn2prn(18) = NaN;
end;

% SVN 19
if (before([1989 11 23], currentdate) & before(currentdate, [2001 9 11]))
    svn2prn(19) = 19;
else
    svn2prn(19) = NaN;
end;

% SVN 20
if (before([1990 4 18], currentdate) & before(currentdate, [1996 5 21]))
    svn2prn(20) = 20;
else
    svn2prn(20) = NaN;
end;

% SVN 21
if (before([1990 8 22], currentdate) & before(currentdate, [2002 9 25]))
    svn2prn(21) = 21;
else
    svn2prn(21) = NaN;
end;

% SVN 22
if (before([1993 4 4], currentdate))
    svn2prn(22) = 22;
else
    svn2prn(22) = NaN;
end;

% SVN 23
if (before([1990 12 10], currentdate))
    svn2prn(23) = 23;
else
    svn2prn(23) = NaN;
end;

% SVN 24
if (before([1991 7 4], currentdate))
    svn2prn(24) = 24;
else
    svn2prn(24) = NaN;
end;

% SVN 25
if (before([1992 3 24], currentdate))
    svn2prn(25) = 25;
else
    svn2prn(25) = NaN;
end;

% SVN 26
if (before([1992 7 23], currentdate))
    svn2prn(26) = 26;
else
    svn2prn(26) = NaN;
end;

% SVN 27
if (before([1992 9 30], currentdate))
    svn2prn(27) = 27;
else
    svn2prn(27) = NaN;
end;

% SVN 28
if (before([1992 4 25], currentdate))
    svn2prn(28) = 28;
else
    svn2prn(28) = NaN;
end;

% SVN 29
if (before([1993 1 5], currentdate))
    svn2prn(29) = 29;
else
    svn2prn(29) = NaN;
end;

% SVN 30
if (before([1996 10 1], currentdate))
    svn2prn(30) = 30;
else
    svn2prn(30) = NaN;
end;

% SVN 31
if (before([1993 4 13], currentdate))
    svn2prn(31) = 31;
else
    svn2prn(31) = NaN;
end;

% SVN 32
if (before([1992 12 11], currentdate))
    svn2prn(32) = 1;
else
    svn2prn(32) = NaN;
end;

% SVN 33
if (before([1996 4 9], currentdate))
    svn2prn(33) = 3;
else
    svn2prn(33) = NaN;
end;

% SVN 34
if (before([1993 11 22], currentdate))
    svn2prn(34) = 4;
else
    svn2prn(34) = NaN;
end;

% SVN 35
if (before([1993 9 28], currentdate))
    svn2prn(35) = 5;
else
    svn2prn(35) = NaN;
end;

% SVN 36
if (before([1994 3 28], currentdate))
    svn2prn(36) = 6;
else
    svn2prn(36) = NaN;
end;

% SVN 37
if (before([1993 12 6], currentdate))
    svn2prn(37) = 7;
else
    svn2prn(37) = NaN;
end;

% SVN 38
if (before([1997 12 18], currentdate))
    svn2prn(38) = 8;
else
    svn2prn(38) = NaN;
end;

% SVN 39
if (before([1993 7 21], currentdate))
    svn2prn(39) = 9;
else
    svn2prn(39) = NaN;
end;

% SVN 40
if (before([1996 8 15], currentdate))
    svn2prn(40) = 10;
else
    svn2prn(40) = NaN;
end;

% SVN 41    
if (before([2000 12 10], currentdate))
    svn2prn(41) = 14;
else
    svn2prn(41) = NaN;
end;

% SVN 42
svn2prn(42) = NaN;

% SVN 43    
if (before([1998 1 31], currentdate))
    svn2prn(43) = 13;
else
    svn2prn(43) = NaN;
end;

% SVN 44    
if (before([2000 8 177], currentdate))
    svn2prn(44) = 28;
else
    svn2prn(44) = NaN;
end;

% SVN 45    
if (before([2003 4 12], currentdate))
    svn2prn(45) = 21;
else
    svn2prn(45) = NaN;
end;

% SVN 46
if (before([2000 1 3], currentdate))
    svn2prn(46) = 11;
else
    svn2prn(46) = NaN;
end;

% SVN 47-50 not applicable
svn2prn(47:50) = NaN;

% SVN 51    
if (before([2000 6 1], currentdate))
    svn2prn(51) = 20;
else
    svn2prn(51) = NaN;
end;

% SVN 52-53 N/A
svn2prn(52:53) = NaN;

% SVN 54    
if (before([2001 2 15], currentdate))
    svn2prn(54) = 18;
else
    svn2prn(54) = NaN;
end;

% SVN 55
svn2prn(55) = NaN;

% SVN 56    
if (before([2003 2 19], currentdate))
    svn2prn(56) = 16;
else
    svn2prn(56) = NaN;
end;

return;

function flag = before(date1, date2)
% return 1 if date 1 is before date2
    flag = 0;
    %test year
    if (date1(1) < date2(1))
        flag = 1;
        return;
    elseif (date1(1) > date2(1))
        flag = 0;
        return;
    end;
    % years are equal test month
    if (date1(2) < date2(2))
        flag = 1;
        return;
    elseif (date1(2) > date2(2))
        flag = 0;
        return;
    end
    % years/month are equal, test day
    if (date1(3) <= date2(3))
        flag = 1;
        return;
    else
        flag = 0;
        return;
    end;
    return;
    