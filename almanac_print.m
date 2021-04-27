function almanac_print(alm_param, weeknum, starting_sat_num, filename)
n_sv = size(alm_param,1);

sat_num = starting_sat_num;
fid = fopen(filename, 'w');

for idx = 1:n_sv
    sat_num = sat_num +1;

    svn = alm_param(idx,1);
    if svn < 38
        s = ['******* Week   ' int2str(weeknum) ' almanac for PRN-' ...
               num2str(svn,'%02d') ' *******'];
    elseif svn < 112
        s = ['******* Week   ' int2str(weeknum) ' almanac for GAL-' ...
               inum2str(svn-74,'%02d') ' *******'];
    elseif svn < 400
        prn = svn - 300;
        s = ['******* Week   ' int2str(weeknum) ' almanac for BDU-G' ...
               int2str(prn) ' *******'];
    elseif  svn < 500
        prn = svn - 400;
        s = ['******* Week   ' int2str(weeknum) ' almanac for BDU-M' ...
               int2str(prn) ' *******'];      
    elseif svn < 600
        prn = svn - 500;
        s = ['****** Week   ' int2str(weeknum) ' almanac for BDU-IGSO' ...
               int2str(prn) ' *****'];        
    else
        s = ['******** Week   ' int2str(weeknum) ' almanac for GLO-' ...
                int2str(svn) ' ********'];           
    end
    fprintf(fid,'%s\n',s);
    s = ['ID:                         ' int2str(sat_num)];
    fprintf(fid,'%s\n',s);
    s = ['Health:                     000'];
    fprintf(fid,'%s\n',s);
    s = ['Eccentricity:               ' ...
                num2str(alm_param(idx,2), '%0.5g')];
    fprintf(fid,'%s\n',s);
    s = ['Time of Applicability(s):   ' ...
                num2str(mod(alm_param(idx,3), 7*24*3600.0), '%11.4f')];
    fprintf(fid,'%s\n',s);
    s = ['Orbital Inclination(rad):   ' ...
                num2str(alm_param(idx,4), '%0.10g')];
    fprintf(fid,'%s\n',s); 
    s = ['Rate of Right Ascen(r/s):   ' ...
                num2str(alm_param(idx,5), '%0.10g')];
    fprintf(fid,'%s\n',s);     
    s = ['SQRT(A)  (m 1/2):           ' ...
                num2str(alm_param(idx,6), '%11.6f')];
    fprintf(fid,'%s\n',s); 
    s = ['Right Ascen at TOA(rad):    ' ...
                num2str(alm_param(idx,7), '%11.8f')];
    fprintf(fid,'%s\n',s); 
    s = ['Argument of Perigee(rad):   ' ...
                num2str(alm_param(idx,8), '%11.9f')];
    fprintf(fid,'%s\n',s); 
    s = ['Mean Anom(rad):             ' ...
                num2str(alm_param(idx,9), '%11.9f')];
    fprintf(fid,'%s\n',s); 
    s = ['Af0(s):                     ' ...
                num2str(alm_param(idx,10), '%0.8g')];
    fprintf(fid,'%s\n',s); 
    s = ['Af1(s/s):                   ' ...
                num2str(alm_param(idx,11), '%0.8g')];
    fprintf(fid,'%s\n',s); 
    s = ['week:                       ' ...
                int2str(weeknum)];
    fprintf(fid,'%s\n\n',s);     
end
