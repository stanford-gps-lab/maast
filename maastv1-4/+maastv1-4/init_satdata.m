function satdata = init_satdata(geodata, alm_param, satdata, t)

%*************************************************************************
%*     Copyright c 2009 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%

%May 2008 added GEO MT28 loading

global COL_SAT_PRN COL_SAT_XYZ COL_SAT_XYZDOT COL_SAT_UDREI ...
        COL_SAT_COV COL_SAT_SCALEF COL_SAT_MAX
global CONST_H_GEO

% get sat positions
if isempty(satdata), % get from almanac
	ngps=size(alm_param,1);
    if(~isempty(geodata))
      ngeo=size(geodata,1);
      geo = ngps + (1:ngeo);
      satdata(geo,:)=repmat(NaN,ngeo,COL_SAT_MAX);
      satdata(geo,COL_SAT_PRN) = geodata(:,1);
      satdata(geo,COL_SAT_XYZ) = llh2xyz([zeros(ngeo,1) geodata(:,2) ...
	                                        CONST_H_GEO*ones(ngeo,1)]);
      satdata(geo,COL_SAT_XYZDOT) = zeros(ngeo,3);
      SF = 2.^(geodata(:,13)-5);
      satdata(geo,COL_SAT_SCALEF) = SF;
      
      for i =1:ngeo
          R = SF(i)*[[geodata(i,3:6)];       [0 geodata(i,7:9)]; ...
                     [0 0 geodata(i,10:11)]; [0 0 0 geodata(i,12)];];
          cov = R'*R;
          cov=cov(:)';
          satdata(ngps+i,COL_SAT_COV)=cov;
      end
    end
end
[prn,satxyz,satvel] = alm2satposvel(t,alm_param);

ngps = size(prn,1);
gps=1:ngps;
satdata(gps,:) = repmat(NaN,ngps,COL_SAT_MAX);
satdata(gps,COL_SAT_PRN) = prn;
satdata(gps,COL_SAT_XYZ) = satxyz;
satdata(gps,COL_SAT_XYZDOT) = satvel;


