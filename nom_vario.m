function C=nom_vario(distance)

global KRIG_NUGGET_EFFECT;
global KRIG_DIST2DOUBLE;
global KRIG_VARIANCE;

%NOM_VARIO computes the value of the nominal covariance
%for a given distance.


nugget=KRIG_NUGGET_EFFECT;
dist2double=KRIG_DIST2DOUBLE;
overall_variance=KRIG_VARIANCE;


sill=overall_variance-nugget;
slope=nugget/(sill*dist2double);
range=1/slope;


C=sill*exp(-distance/range);

I=find(distance==0);
C(I)=C(I)+nugget;
