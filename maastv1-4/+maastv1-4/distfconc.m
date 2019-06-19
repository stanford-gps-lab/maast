function delta=distfconc(distance, nugget, dist2double, overall_variance);

if nargin<2
   nugget=.03;
end
if nargin<3
   dist2double=1000000 ;
end
if nargin<4 
   overall_variance=2;
end

sill=overall_variance-nugget;
slope=nugget/(sill*dist2double);
range=1/slope;

x=-range*log(range*(1-exp(-distance/range))/distance);

delta=sill*((exp(-distance/range)-1)*x/distance -(exp(-x/range)-1));
