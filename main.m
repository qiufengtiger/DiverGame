clear all;

% gw = gameWindow;
% setup(gw);
% moveDiver(gw, 'up');
menu = startMenu;
run(menu);
dir = getDir(menu);
id = getId(menu);
group = getGroup(menu);
trial = getTrial(menu);
gw = gameWindow(dir, id, group, trial);
% gw = gameWindow('R', 1, 1, 1);

% while 1
%     for i = 1 : 100
%        moveDiver(gw, gameWindow.UP); 
%     end
%     for i = 1 : 100
%        moveDiver(gw, gameWindow.DOWN); 
%     end
% end