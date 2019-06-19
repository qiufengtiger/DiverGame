classdef gameWindow < handle
    % the game window is 650 by 650
    % variable obj refers to the gameWindow object
    properties
        % game window settings
        gameFigure;
        xWindowSize;
        yWindowSize;
        xDiverCurrentPos;
        yDiverCurrentPos;
        xChestCurrentPos;
        yChestCurrentPos;
        
        % images
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
        moveStepSize; 
        scoreDistance;
        scoreStarted;
        scoreStartTime;
        lastMoveTime;
        diverWidth
        diverHeight;
        chestWidth;
        chestHeight;    
        dir;
        id;
        group;
        trial;
        chestIndex;
        chestPatternR;
        chestPatternL;
        chestNumInTrial;
    end
    
    properties(Constant)
        UP = 0;
        DOWN = 1;
        RIGHT = 2;
        LEFT = 3;
        
        DIVER = 0;
        DIVERFLIPPED = 1;
        CHEST = 2;
        SCORE = 3;
    end
        
    
    methods
        function obj = gameWindow(dirIn, idIn, groupIn, trialIn)
            obj.xWindowSize = 650;
            obj.yWindowSize = 650;
            % from previous java game
            obj.xDiverCurrentPos = obj.xWindowSize / 2;
            obj.yDiverCurrentPos = obj.yWindowSize / 2;
            obj.xChestCurrentPos = obj.xWindowSize / 2;
            obj.yChestCurrentPos = obj.yWindowSize / 2;
            obj.score = 0;
%             setup(obj);
            obj.diverWidth = 75;
            obj.diverHeight = 38;
            obj.chestWidth = 75;
            obj.chestHeight = 71;
            
            obj.diverImageDir = 0; % right
            
            obj.moveStepSize = 5;
            
            obj.scoreDistance = 50;
            obj.scoreStarted = false;
            obj.scoreStartTime = 0;
            
            obj.dir = dirIn;
            obj.id = idIn;
            obj.group = groupIn;
            obj.trial = trialIn;
            
            obj.chestIndex = 0; % 0 to 10; 11 chests
            % though the first chest is also hardcoded, it won't be read by
            % repaintChest() method
            % since the first chest is created directly using paint(chest) 
            obj.chestPatternR = [2, 3, 0, 4, 3, 1, 1, 4, 3, 0, 1];
            obj.chestPatternL = [2, 1, 0, 4, 3, 1, 1, 4, 3, 0, 3];
            obj.chestNumInTrial = 11;
            
            obj.lastMoveTime = datetime; % start 30 sec timing here
            setup(obj);
        end
        
        function obj = setup(obj)
            obj.gameFigure = figure('Name', 'DiverGame', 'NumberTitle', 'off', 'Color', [0, 0.749, 1], 'Units', 'pixels', 'Resize', 'off', ...
            'Position', [100, 100, obj.xWindowSize, obj.yWindowSize], 'keyPressFcn', {@keyPressed, obj}, 'MenuBar', 'none', 'ToolBar', 'none');       
            
            axes('Units', 'pixels', 'Position', [1, 1, 650, 650], 'XLim', [1, 650], 'YLim', [1, 650], 'Visible', 'off', 'YDir', 'normal');
            
            [a, ~, b] = imread('scuba75.png');
            obj.diverImage = a;
            obj.diverAlphaChannel = b;
            obj.diverImageFlipped = flip(a, 2);
            obj.diverAlphaChannelFlipped = flip(b, 2);                      
            [a, ~, b] = imread('tc75.png');
            obj.chestImage = a;
            obj.chestAlphaChannel = b;
            
            hold on;
       
            obj.diverImageObject = imshow(obj.diverImage);
            obj.diverImageObject.AlphaData = obj.diverAlphaChannel;
            
            obj.diverImageFlippedObject = imshow(obj.diverImageFlipped);
            obj.diverImageFlippedObject.AlphaData = obj.diverAlphaChannelFlipped;
            
            obj.chestImageObject = imshow(obj.chestImage);
            obj.chestImageObject.AlphaData = obj.chestAlphaChannel;
            
            hold off;
            
            paint(obj, obj.xChestCurrentPos, obj.yChestCurrentPos, gameWindow.CHEST);
            paint(obj, obj.xDiverCurrentPos, obj.yDiverCurrentPos, gameWindow.DIVER); 
            paint(obj, 500, 500, gameWindow.SCORE);
            
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
                    otherwise
                        disp('command not recognized');
                end
            end
            
            text(1, 1, 'pos 1, 1');
            text(1, 650 - 10, 'pos 1, 650');
            text(650 - 100, 1, 'pos 650, 1');
            text(650 - 100, 650 - 10, 'pos 650, 650');
            
        end
        
        function obj = moveDiver(obj, command)
            timeTaken =  milliseconds(datetime - obj.lastMoveTime);
            obj.lastMoveTime = datetime; % reset 30 sec timer
            if(checkScored(obj) || timeTaken > 30000)              
                obj.score = obj.score + 1;
                repaintChest(obj);
                obj.xDiverCurrentPos = obj.xWindowSize / 2;
                obj.yDiverCurrentPos = obj.yChestCurrentPos;
                repaintDiver(obj);
                repaintScore(obj);
                return
            elseif(checkBorder(obj, command))
                disp('diver cannot move further!');
                return
            end
            xPos = obj.xDiverCurrentPos;
            yPos = obj.yDiverCurrentPos;
            switch(command)
                case gameWindow.UP
                    yPos = yPos + obj.moveStepSize;
                case gameWindow.DOWN
                    yPos = yPos - obj.moveStepSize;
                case gameWindow.RIGHT
                    xPos = xPos + obj.moveStepSize;
                    obj.diverImageDir = gameWindow.RIGHT;
                case gameWindow.LEFT
                    xPos = xPos - obj.moveStepSize;
                    obj.diverImageDir = gameWindow.LEFT;
            end
            obj.xDiverCurrentPos = xPos;
            obj.yDiverCurrentPos = yPos;
            repaintDiver(obj);             
        end
        
        function obj = repaintDiver(obj)
            xPos = obj.xDiverCurrentPos;
            yPos = obj.yDiverCurrentPos;
%             removeImageObject(obj, gameWindow.DIVER);
            if(obj.diverImageDir == gameWindow.LEFT)
                paint(obj, xPos, yPos, gameWindow.DIVERFLIPPED);
            else
                paint(obj, xPos, yPos, gameWindow.DIVER);
            end
            
        end
        
        function obj = repaintChest(obj)
            xPos = 0;
            yPos = 0;
            if(strcmp(obj.dir, 'R'))
                chestPos = obj.chestPatternR(obj.chestIndex + 1);
            else
                chestPos = obj.chestPatternL(obj.chestIndex + 1);
            end
            obj.chestIndex = mod(obj.chestIndex + 1, obj.chestNumInTrial); % loop  
            switch(chestPos)
                % far left
                case 0
                    xPos = 40;
                case 1
                    xPos = obj.xWindowSize / 4;
                case 2
                    xPos = obj.xWindowSize / 2;
                case 3
                    xPos = obj.xWindowSize / 4 * 3;
                % far right
                case 4
                    xPos = obj.xWindowSize - obj.chestWidth - 40;
            end
            yPos = rand * (obj.yWindowSize - obj.chestHeight);
            obj.xChestCurrentPos = xPos;
            obj.yChestCurrentPos = yPos;
%             removeImageObject(obj, gameWindow.CHEST);
            paint(obj, xPos, yPos, gameWindow.CHEST);
        end
        
        function obj = repaintScore(obj)
           removeImageObject(obj, gameWindow.SCORE);
           paint(obj, 500, 500, gameWindow.SCORE);
        end
         
        function obj = paint(obj, xPos, yPos, type) % type is 'diver', 'diverFlipped', 'chest' or 'score'
            if(type == gameWindow.SCORE)
                scoreText = sprintf('Score: %d', obj.score);
                obj.scoreObject = text(xPos, yPos, scoreText, 'FontSize', 18, 'Color', 'white');
                return
            end
%             xPos = xPos1 / obj.xWindowSize;
%             yPos = yPos1 / obj.yWindowSize;
            if(type == gameWindow.DIVER)
                set(obj.diverImageObject, 'XData', [xPos, xPos + obj.diverWidth], 'YData', [yPos, yPos + obj.diverHeight], 'Clipping', 'off');
                drawnow;
            elseif(type == gameWindow.DIVERFLIPPED)
                set(obj.diverImageFlippedObject, 'XData', [xPos, xPos + obj.diverWidth], 'YData', [yPos, yPos + obj.diverHeight], 'Clipping', 'off');
                drawnow;
            elseif(type == gameWindow.CHEST)
                set(obj.chestImageObject, 'XData', [xPos, xPos + obj.chestWidth], 'YData', [yPos, yPos + obj.chestHeight], 'Clipping', 'off');
                drawnow;
            else
                disp('object type not recognized in paint method');
            end   
        end
        
        function obj = removeImageObject(obj, type)
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
            xDistance = abs((obj.xDiverCurrentPos + (obj.diverWidth / 2)) - (obj.xChestCurrentPos + (obj.chestWidth / 2)));
            yDistance = abs((obj.yDiverCurrentPos + (obj.diverHeight / 2)) - (obj.yChestCurrentPos + (obj.chestHeight / 2)));
            distance = sqrt(xDistance ^ 2 + yDistance ^ 2);
            if(distance < obj.scoreDistance)
                if(~obj.scoreStarted)
                    obj.scoreStartTime = datetime;
                    obj.scoreStarted = true;
                    isScored = false;
                else
                    timeTaken =  milliseconds(datetime - obj.scoreStartTime);
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
            if((obj.xDiverCurrentPos <= obj.moveStepSize && command == gameWindow.LEFT) || ...
              ((obj.xWindowSize - obj.xDiverCurrentPos - obj.diverWidth) <= obj.moveStepSize && command == gameWindow.RIGHT) || ...
              (obj.yDiverCurrentPos <= obj.moveStepSize && command == gameWindow.DOWN) || ...
              ((obj.yWindowSize - obj.yDiverCurrentPos - obj.diverHeight) <= obj.moveStepSize && command == gameWindow.UP))
                isBorder = true;
            else
                isBorder = false;
            end
        end    
        
        
    end
    
    methods(Static)
        
    end
end