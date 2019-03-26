function plot(obj)
% plot  plot the user locations as points on a map.
%   
%   plot(user) plot the user locations as points.
%
%   user.plot() is also a valid command where user is of type
%   maast.tools.User
%
%   Example:
%
%       % create a list of users
%       users = maast.tools.User.createUserGrid(100);
%
%       % plot with first syntax
%       figure(1); plot(users);
%
%       % plot with second snytax
%       figure(1); users.plot();

% get the position of all the users
allPosLLH = [obj(:).PositionLLH];

% get the positions of all the users
latDeg = allPosLLH(1,:);
lonDeg = allPosLLH(2,:);

% get the coast dataset for plotting
coastData = load('coast');

% Plot the grid points on a map
hold all;
plot(coastData.long, coastData.lat, 'k');
plot(lonDeg, latDeg, 'o');

% if we have some that are in bound, want to highlight those
inBnd = [obj(:).InBound];
if sum(inBnd) > 0
    plot(lonDeg(inBnd), latDeg(inBnd), 'r*');
end

hold off;
grid on; axis equal;
xlim([-180, 180]); ylim([-90, 90]);

end