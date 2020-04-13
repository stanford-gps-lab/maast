function [mtype, msg] = RINEX_get_sbas_msg(fid)

% SYNTAX:
%   [mtype, msg] = RINEX_get_sbas_msg(fid)
%
% INPUT:
%   fid = binary broadcast SBAS message RINEX file
%
% OUTPUT:
%   mtype = message type (# between 0 and 63)
%   msg = binary 250 bit message stored in 64 unsigned characters
%
% DESCRIPTION:
%   Acquisition of RINEX broadcast SBAS message.

%variable initialization
mtype = NaN;
msg = cast(zeros(1,32),'uint8');
tmpmsg = cast(zeros(1,64),'uint8');

eof = 0;

%search data
while (eof==0)
    %read the string
    lin = fgets(fid);
     
    mtype = cast(str2double(lin(2:3)),'int8');
    
    %check if it is a string that should be analyzed
    if mtype >= 0 && mtype < 64
        
        buf = lin(8:60);
        % - Keep only relevant characters.
        buf = buf(buf>47);
        % - Cast to double (makes the following faster).
        buf = buf + 0 ;
        % - Map '0'-'9' to 0-9 and 'A'-'F' to 10-15.
        idNum = buf < 58 ;
        buf(idNum)  = buf(idNum)  - 48 ; 
        buf(~idNum) = buf(~idNum) - 55 ; 
        tmpmsg(1:36) = cast(buf,'uint8');
        
        %read the 2nd line
        lin = fgets(fid);       
        
        buf = lin(8:48);
        % - Keep only relevant characters.
        buf = buf(buf>47);
        % - Cast to double (makes the following faster).
        buf = buf + 0 ;
        % - Map '0'-'9' to 0-9 and 'A'-'F' to 10-15.
        idNum = buf < 58 ;
        buf(idNum)  = buf(idNum)  - 48 ; 
        buf(~idNum) = buf(~idNum) - 55 ; 
        tmpmsg(37:64) = cast(buf,'uint8'); 
        msg = tmpmsg(1:2:63)*16 + tmpmsg(2:2:64);
        
        eof = 1;

    end
end
