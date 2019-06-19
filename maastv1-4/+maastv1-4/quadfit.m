function x0 = quadfit(y0,x,y)
% interpolates 3 points in (x,y) quadratically to get fourth point x0 given y0
% Two possible answers.  The one with a positive slope is returned.

mu=mean(x);
x=x(:) - mu;
y=y(:);
a = inv([x.*x x ones(3,1)])*y;
if a(1)==0
    x0 = (y0-a(3))/a(2) + mu;
else
    x0_1 = (-a(2)+sqrt(a(2)*a(2)-4*a(1)*(a(3)-y0)))/2/a(1);
    x0_2 = -a(2)/a(1)-x0_1;
    if a(1)>0
        x0 = max(x0_1,x0_2) + mu;
    else
        x0 = min(x0_1,x0_2) + mu;
    end
end
