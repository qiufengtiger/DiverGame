classdef gameWindow < handle
    % the game window is 650 by 650
    % variable obj refers to the gameWindow object
    % use '< handle' such that the gameWindow object is passed by reference
    % otherwise always update gameWindow obj using the returned value
    %
    % Authors
    % Feng Qiu qiuf@lafayette.edu
    % Zachary Martin martinz@lafayette.edu
    
    properties
        % game variables
        gameFigure;
        xDiverCurrentPos;
        yDiverCurrentPos;
        xChestCurrentPos;
        yChestCurrentPos;
        distance;
        lostChest;
        
        % images and score display
        diverImage;
        diverAlphaChannel;
        diverImageFlipped;
        diverAlphaChannelFlipped;
        diverImageDir;
        diverImageObject;
        diverImageFlippedObject
        chestImage;
        chestAlphaChannel;
        chestImageObject; 
        score;
        scoreObject;       
        
        % timing
        scoreStarted;
        scoreStartTime;
        lastMoveTime;
        lastScoreTime;
        
        % user inputs
        dir;
        id;
        group;
        trial;
        
        % chest spawning
        chestIndex;
        chestPatternR;
        chestPatternL;
        chestNumInTrial;
        chestPos;
        
        % result tracking
        totalTimePos0;
        totalTimePos1;
        totalTimePos2;
        totalTimePos3;
        totalTimePos4;
        numPos0;
        numPos1;
        numPos2;
        numPos3;
        numPos4;
        
        inputMsg;
        gameStartTime;
    end
    
    properties(Constant)      
        ON_TEST = 0;
        
        % directions
        UP = 0;
        DOWN = 1;
        RIGHT = 2;
        LEFT = 3;
        NOT_MOVING = 4;
        
        % object types
        DIVER = 0;
        DIVERFLIPPED = 1;
        CHEST = 2;
        SCORE = 3;
        
        % game window definations
        X_WINDOW_SIZE = 650;
        Y_WINDOW_SIZE = 650;
        DIVER_WIDTH = 75;
        DIVER_HEIGHT = 38;
        CHEST_WIDTH = 75;
        CHEST_HEIGHT = 71;
        X_SCORE_POS = 530; 
        Y_SCORE_POS = 30;
        
        % game behaviors definations
        MOVE_STEP_SIZE = 25;
        SCORE_DISTANCE = 60;
    end
        
    
    methods
        function obj = gameWindow(dirIn, idIn, groupIn, trialIn)
            % from previous java game
            obj.xDiverCurrentPos = gameWindow.X_WINDOW_SIZE / 2;
            obj.yDiverCurrentPos = gameWindow.Y_WINDOW_SIZE / 2;
            obj.xChestCurrentPos = gameWindow.X_WINDOW_SIZE / 2;
            obj.yChestCurrentPos = gameWindow.Y_WINDOW_SIZE / 2;
            obj.score = 0;
            obj.diverImageDir = gameWindow.RIGHT;
            obj.scoreStarted = false;
            obj.scoreStartTime = 0;     
            obj.dir = dirIn;
            obj.id = idIn;
            obj.group = groupIn;
            obj.trial = trialIn;   
            obj.totalTimePos0 = 0;
            obj.totalTimePos1 = 0;
            obj.totalTimePos2 = 0;
            obj.totalTimePos3 = 0;
            obj.totalTimePos4 = 0;
            obj.numPos0 = 0;
            obj.numPos1 = 0;
            obj.numPos2 = 0;
            obj.numPos3 = 0;
            obj.numPos4 = 0;
            obj.distance = 0;
           % obj.distanceResults = {}; 
            obj.lostChest = {};
            
            obj.chestIndex = 1; % 1 to 11
            % though the first chest is also hardcoded, it won't be read by
            % repaintChest() method
            % since the first chest is created directly using paint(chest) 
            obj.chestPatternR = [2, 3, 0, 4, 3, 1, 1, 4, 3, 0, 1];
            obj.chestPatternL = [2, 1, 0, 4, 3, 1, 1, 4, 3, 0, 3];
            if(length(obj.chestPatternR) ~= length(obj.chestPatternL))
                error('lengths of two patterns do not match!');
            end
            obj.chestNumInTrial = length(obj.chestPatternR); 
            
            obj.inputMsg = {};
            obj.gameStartTime = datetime;
            
            setup(obj);
        end
        
        function obj = setup(obj)
            obj.gameFigure = figure('Name', 'DiverGame', 'NumberTitle', 'off', 'Color', [0, 0.749, 1], 'Units', 'pixels', 'Resize', 'off', ...
            'Position', [100, 100, gameWindow.X_WINDOW_SIZE, gameWindow.Y_WINDOW_SIZE], 'keyPressFcn', {@keyPressed, obj}, 'MenuBar', 'none', 'ToolBar', 'none');       
            
            axes('Units', 'pixels', 'Position', [1, 1, gameWindow.X_WINDOW_SIZE, gameWindow.Y_WINDOW_SIZE], ...
                'XLim', [1, gameWindow.X_WINDOW_SIZE], 'YLim', [1, gameWindow.Y_WINDOW_SIZE], 'Visible', 'off', 'YDir', 'normal');
            
            [a, ~, b] = imread('scuba75.png');
            obj.diverImage = a;
            obj.diverAlphaChannel = b;
            obj.diverImageFlipped = flip(a, 2);
            obj.diverAlphaChannelFlipped = flip(b, 2);                      
            [a, ~, b] = imread('tc75.png');
            obj.chestImage = a;
            obj.chestAlphaChannel = b;
            
            hold on;
            obj.chestImageObject = imshow(obj.chestImage);
            obj.diverImageObject = imshow(obj.diverImage);
            obj.diverImageFlippedObject = imshow(obj.diverImageFlipped);   
            hold off;
            
            obj.chestImageObject.AlphaData = obj.chestAlphaChannel;
            obj.diverImageObject.AlphaData = obj.diverAlphaChannel;       
            obj.diverImageFlippedObject.AlphaData = obj.diverAlphaChannelFlipped;
                   
            % for some strange reason the y axis is reversed after reading
            % images, so up & down dirs in moveDiver are flipped        
            
            % paint divers
            % to flip diver's dir, set the target image visibility to on
            % and the other one to off
            set(obj.diverImageObject, 'Visible', 'on');
            set(obj.diverImageFlippedObject, 'Visible', 'off');
            paint(obj, obj.xDiverCurrentPos, obj.yDiverCurrentPos, gameWindow.DIVER);
            % the first chest pos hardcoded here
            obj.chestPos = 2;
            paint(obj, obj.xChestCurrentPos, obj.yChestCurrentPos, gameWindow.CHEST);
            paint(obj, gameWindow.X_SCORE_POS, gameWindow.Y_SCORE_POS, gameWindow.SCORE);
            
            obj.lastMoveTime = datetime; % start 30 sec timing here
            obj.lastScoreTime = datetime; % count time taken to get chests
            
            % when key is pressed
            function keyPressed(figure, KeyData, obj)
                switch(KeyData.Key)
                    case 'uparrow'
                        moveDiver(obj, gameWindow.UP);
                    case 'downarrow'
                        moveDiver(obj, gameWindow.DOWN);
                    case 'rightarrow'
                        moveDiver(obj, gameWindow.RIGHT);
                    case 'leftarrow'
                        moveDiver(obj, gameWindow.LEFT);
                    case 'q'
                        writeMsg(obj);
                    otherwise
                        disp('command not recognized');
                end
            end
            if(gameWindow.ON_TEST)
                text(1, 1, 'pos 1, 1');
                text(1, 650 - 10, 'pos 1, 650');
                text(650 - 100, 1, 'pos 650, 1');
                text(650 - 100, 650 - 10, 'pos 650, 650');  
            end     
        end
        
        function writeMsg(obj)
            obj.inputMsg{end + 1} = seconds(datetime - obj.gameStartTime);
            
            
        end
        
        function obj = moveDiver(obj, command)
            timeTaken =  milliseconds(datetime - obj.lastMoveTime); % check time took after last input
%             if(command ~= gameWindow.NOT_MOVING)
%                 obj.lastMoveTime = datetime; % reset 30 sec timer
%             end
            scored = checkScored(obj);
            % need to respawn a chest
            if(scored || timeTaken > 30000)
                % increment score only when player captures the chest
                if(scored)
                    obj.score = obj.score + 1;
                
                elseif(timeTaken > 30000)  %record uncaptured chest data
                    obj.lostChest{end+1} = struct('distance',obj.distance,'chestNumber',obj.chestIndex,'chestPos',obj.chestPos);
                    %obj.distanceResults{end+1} = obj.distance;
                end
                   
                % for time average result
                scoreTimeTaken = seconds(datetime - obj.lastScoreTime);
                switch(obj.chestPos)
                    case 0
                        obj.totalTimePos0 = obj.totalTimePos0 + scoreTimeTaken;
                        obj.numPos0 = obj.numPos0 + 1;
                    case 1
                        obj.totalTimePos1 = obj.totalTimePos1 + scoreTimeTaken;
                        obj.numPos1 = obj.numPos1 + 1;
                    case 2
                        obj.totalTimePos2 = obj.totalTimePos2 + scoreTimeTaken;
                        obj.numPos2 = obj.numPos2 + 1;
                    case 3
                        obj.totalTimePos3 = obj.totalTimePos3 + scoreTimeTaken;
                        obj.numPos3 = obj.numPos3 + 1;
                    case 4
                        obj.totalTimePos4 = obj.totalTimePos4 + scoreTimeTaken;
                        obj.numPos4 = obj.numPos4 + 1;
                end
                % print result
                if(obj.chestIndex == obj.chestNumInTrial)
                    writeResult(obj);
                end
                % respawn the chest
                repaintChest(obj);
                % reset diver to the middle of the line where the chest is
                % spawned
                obj.xDiverCurrentPos = gameWindow.X_WINDOW_SIZE / 2;
                obj.yDiverCurrentPos = obj.yChestCurrentPos;
                repaintDiver(obj);
                repaintScore(obj);
                obj.lastScoreTime = datetime; % reset score timer
                obj.lastMoveTime = datetime; % reset 30 sec timer, might be the same as the one above
                return
            elseif(checkBorder(obj, command))
                %disp('diver cannot move further!');
                return
            else
                % move
                xPos = obj.xDiverCurrentPos;
                yPos = obj.yDiverCurrentPos;
                % set the diver to a new pos
                switch(command)
                    % up & down directions are flipped since y axis is
                    % reversed
%                     case gameWindow.UP
                    case gameWindow.DOWN
                        yPos = yPos + gameWindow.MOVE_STEP_SIZE;
%                     case gameWindow.DOWN
                    case gameWindow.UP
                        yPos = yPos - gameWindow.MOVE_STEP_SIZE;
                    case gameWindow.RIGHT
                        xPos = xPos + gameWindow.MOVE_STEP_SIZE;
                        obj.diverImageDir = gameWindow.RIGHT;
                    case gameWindow.LEFT
                        xPos = xPos - gameWindow.MOVE_STEP_SIZE;
                        obj.diverImageDir = gameWindow.LEFT;
                end
                obj.xDiverCurrentPos = xPos;
                obj.yDiverCurrentPos = yPos;
                repaintDiver(obj);    
            end
        end
        
        function obj = repaintDiver(obj)
            xPos = obj.xDiverCurrentPos;
            yPos = obj.yDiverCurrentPos;
            if(obj.diverImageDir == gameWindow.LEFT)
                set(obj.diverImageObject, 'Visible', 'off');
                set(obj.diverImageFlippedObject, 'Visible', 'on');
                paint(obj, xPos, yPos, gameWindow.DIVERFLIPPED);
            else
                set(obj.diverImageObject, 'Visible', 'on');
                set(obj.diverImageFlippedObject, 'Visible', 'off');
                paint(obj, xPos, yPos, gameWindow.DIVER);
            end
            
        end
        
        function obj = repaintChest(obj)
            xPos = 0;
            yPos = 0;
            obj.chestIndex = mod(obj.chestIndex, obj.chestNumInTrial) + 1; % loop
            if(strcmp(obj.dir, 'R'))
                obj.chestPos = obj.chestPatternR(obj.chestIndex);
            else
                obj.chestPos = obj.chestPatternL(obj.chestIndex);
            end 
            switch(obj.chestPos)
                % far left
                case 0
                    xPos = 40;
                case 1
                    xPos = gameWindow.X_WINDOW_SIZE / 4;
                case 2
                    xPos = gameWindow.X_WINDOW_SIZE / 2;
                case 3
                    xPos = gameWindow.X_WINDOW_SIZE / 4 * 3;
                % far right
                case 4
                    xPos = gameWindow.X_WINDOW_SIZE - gameWindow.CHEST_WIDTH - 40;
            end
            % y pos is randomly generated
            yPos = rand * (gameWindow.Y_WINDOW_SIZE - gameWindow.CHEST_HEIGHT);
            obj.xChestCurrentPos = xPos;
            obj.yChestCurrentPos = yPos;
            paint(obj, xPos, yPos, gameWindow.CHEST);
        end
        
        function obj = repaintScore(obj)
           removeImageObject(obj, gameWindow.SCORE);
           paint(obj, gameWindow.X_SCORE_POS, gameWindow.Y_SCORE_POS, gameWindow.SCORE);
        end
        
        function obj = writeResult(obj)
           fileName = sprintf('./data/timeData_%d_%d_%d.csv' , obj.id, obj.group, obj.trial);
           averagePos0 = obj.totalTimePos0 / obj.numPos0;
           averagePos1 = obj.totalTimePos1 / obj.numPos1;
           averagePos2 = obj.totalTimePos2 / obj.numPos2;
           averagePos3 = obj.totalTimePos3 / obj.numPos3;
           averagePos4 = obj.totalTimePos4 / obj.numPos4;
           averageTotal = (obj.totalTimePos0 + obj.totalTimePos1 + obj.totalTimePos2 + obj.totalTimePos3 + obj.totalTimePos4) / ...
               (obj.numPos0 + obj.numPos1 + obj.numPos2 + obj.numPos3 + obj.numPos4);
           file = fopen(fileName, 'w');
           if(file == -1)
               mkdir('data');
               file = fopen(fileName, 'w');
           end
           fprintf(file, 'Time values in seconds\n');
           fprintf(file, 'Chest No., #Chests, Average time\n');
           columnName = {'Position 0', 'Position 1', 'Position 2', 'Position 3', 'Position 4', 'Total'};
           columnNumPos = {obj.numPos0, obj.numPos1, obj.numPos2, obj.numPos3, obj.numPos4, (obj.numPos0 + obj.numPos1 + obj.numPos2 + obj.numPos3 + obj.numPos4)};
           columnTime = {averagePos0, averagePos1, averagePos2, averagePos3, averagePos4, averageTotal};
           for i = 1 : length(columnName)
               fprintf(file, '%s, %d, %d\n', columnName{i}, columnNumPos{i}, columnTime{i});
           end
           fprintf(file, 'Score: %d\n', obj.score);
           %=========================================
           fprintf(file, 'Uncaptured Chest Data:\n');
           fprintf(file, 'ChestNumber, ChestPos, Distance\n');  
           for k = 1: length(obj.lostChest)
               fprintf(file, '%d, %d, %d\n', obj.lostChest{k}.chestNumber, obj.lostChest{k}.chestPos, obj.lostChest{k}.distance);
           end
           fprintf(file, '\nKeystrokes (sec):\n');
           for i = 1 : size(obj.inputMsg, 2)
               fprintf(file, '%d\n', obj.inputMsg{1, i}); 
           end
           fclose(file);
           disp('result file generated!');
           assignin('base','uncapturedChests',obj.lostChest);
        end
         
        function obj = paint(obj, xPos, yPos, type) % type is 'diver', 'diverFlipped', 'chest' or 'score'
            if(type == gameWindow.SCORE)
                scoreText = sprintf('Score: %d', obj.score);
                obj.scoreObject = text(xPos, yPos, scoreText, 'FontSize', 18, 'Color', 'white');
                return
            end
            % add 15 to diver's y pos for calibration
            if(type == gameWindow.DIVER)
                set(obj.diverImageObject, 'XData', [xPos, xPos + gameWindow.DIVER_WIDTH], 'YData', [yPos + 15, yPos + gameWindow.DIVER_HEIGHT + 15], 'Clipping', 'off');
                drawnow;
            elseif(type == gameWindow.DIVERFLIPPED)
                set(obj.diverImageFlippedObject, 'XData', [xPos, xPos + gameWindow.DIVER_WIDTH], 'YData', [yPos + 15, yPos + gameWindow.DIVER_HEIGHT + 15], 'Clipping', 'off');
                drawnow;
            elseif(type == gameWindow.CHEST)
                set(obj.chestImageObject, 'XData', [xPos, xPos + gameWindow.CHEST_WIDTH], 'YData', [yPos, yPos + gameWindow.CHEST_HEIGHT], 'Clipping', 'off');
                drawnow;
            else
                disp('object type not recognized in paint method');
            end   
        end
        
        function obj = removeImageObject(obj, type) % type 'diver', 'chest' are no longer used!
            if(type == gameWindow.DIVER)
                delete(obj.diverImageObject);   
            elseif(type == gameWindow.CHEST)
                delete(obj.chestImageObject);
            elseif(type == gameWindow.SCORE)
                delete(obj.scoreObject);
            else
                disp('object type not recognized in remove method');
            end          
        end
           
        function isScored = checkScored(obj)
            % diver: 75 * 38
            % chest: 75 * 71
            xDistance = abs((obj.xDiverCurrentPos + (gameWindow.DIVER_WIDTH / 2)) - (obj.xChestCurrentPos + (gameWindow.CHEST_WIDTH / 2)));
            yDistance = abs((obj.yDiverCurrentPos + (gameWindow.DIVER_HEIGHT / 2)) - (obj.yChestCurrentPos + (gameWindow.CHEST_HEIGHT / 2)));
            obj.distance = sqrt(xDistance ^ 2 + yDistance ^ 2); % get the distance
            %obj.distanceResults = [obj.distanceResults; distance];
            if(obj.distance < gameWindow.SCORE_DISTANCE)
                if(~obj.scoreStarted)
                    obj.scoreStartTime = datetime;
                    obj.scoreStarted = true;
                    isScored = false;
                else
                    timeTaken =  milliseconds(datetime - obj.scoreStartTime);
                    % score only if the distance is less enough for 0.25
                    % sec
                    if(timeTaken > 250)       
                        obj.scoreStarted = false;
                        isScored = true;
                    else
                        isScored = false;
                    end
                end
            else
                obj.scoreStarted = false;
                isScored = false;
            end
        end
        
        function isBorder = checkBorder(obj, command)
            if((obj.xDiverCurrentPos <= gameWindow.MOVE_STEP_SIZE && command == gameWindow.LEFT) || ...
              ((gameWindow.X_WINDOW_SIZE - obj.xDiverCurrentPos - gameWindow.DIVER_WIDTH) <= gameWindow.MOVE_STEP_SIZE && command == gameWindow.RIGHT) || ...
              (obj.yDiverCurrentPos <= gameWindow.MOVE_STEP_SIZE && command == gameWindow.DOWN) || ...
              ((gameWindow.Y_WINDOW_SIZE - obj.yDiverCurrentPos - gameWindow.DIVER_HEIGHT) <= gameWindow.MOVE_STEP_SIZE && command == gameWindow.UP))
                isBorder = true;
            else
                isBorder = false;
            end
        end          
    end
    
    methods(Static)
        
    end
end