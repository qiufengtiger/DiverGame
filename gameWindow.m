classdef gameWindow < handle
    % the game window is 650 by 650
    % variable obj refers to the gameWindow object
    properties
        xWindowSize;
        yWindowSize;
        xDiverCurrentPos;
        yDiverCurrentPos;
        xChestCurrentPos;
        yChestCurrentPos;
        gameFigure;
        diverImage;
        diverAlphaChannel;
        diverImageFlipped;
        diverAlphaChannelFlipped;
        diverImageObject;
        chestImage;
        chestAlphaChannel;
        chestImageObject;
        score;
        scoreObject;
        moveStepSize; 
        scoreDistance;
        scoreStarted;
        scoreStartTime;       
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
            
            obj.moveStepSize = 15;
            
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
        end
        
        function obj = setup(obj)
            obj.gameFigure = figure('Name', 'DiverGame', 'NumberTitle', 'off', 'Color', [0, 0.749, 1], 'Units', 'pixels', 'Resize', 'off', ...
            'Position', [100, 100, obj.xWindowSize, obj.yWindowSize], 'keyPressFcn', {@keyPressed, obj});       
            [a, ~, b] = imread('scuba75.png');
            obj.diverImage = a;
            obj.diverAlphaChannel = b;
            obj.diverImageFlipped = flip(a, 2);
            obj.diverAlphaChannelFlipped = flip(b, 2);
            [a, ~, b] = imread('tc75.png');
            obj.chestImage = a;
            obj.chestAlphaChannel = b;
            obj.chestIndex = obj.chestIndex + 1;
            paint(obj, obj.xChestCurrentPos, obj.yChestCurrentPos, 'chest');
            paint(obj, obj.xDiverCurrentPos, obj.yDiverCurrentPos, 'diver'); 
            paint(obj, 0, 0, 'score'); 
            function keyPressed(figure, KeyData, obj)
                switch(KeyData.Key)
                    case 'uparrow'
                        moveDiver(obj, 'up');
                    case 'downarrow'
                        moveDiver(obj, 'down');
                    case 'rightarrow'
                        moveDiver(obj, 'right');
                    case 'leftarrow'
                        moveDiver(obj, 'left');
                    otherwise
                        disp('command not recognized');
                end
            end
        end
        
        function obj = repaintDiver(obj)
            xPos = obj.xDiverCurrentPos;
            yPos = obj.yDiverCurrentPos;
            removeImageObject(obj, 'diver');
            paint(obj, xPos, yPos, 'diver');
        end
        
        function obj = repaintChest(obj)
            chestPos = 0;
            xPos = 0;
            yPos = 0;
            if(strcmp(obj.dir, 'R'))
                chestPos = obj.chestPatternR(obj.chestIndex + 1);
            else
                chestPos = obj.chestPatternL(obj.chestIndex + 1);
            end
            obj.chestIndex = mod(obj.chestIndex + 1, 11); % loop  
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
            
%             xPos = obj.xChestCurrentPos;
%             yPos = obj.yChestCurrentPos;
            removeImageObject(obj, 'chest');
            paint(obj, xPos, yPos, 'chest');
        end
        
        function obj = repaintScore(obj)
           removeImageObject(obj, 'score');
           paint(obj, 0, 0, 'score');
        end
         
        function obj = paint(obj, xPos, yPos, type) % type is 'diver', 'chest' or 'score'
            if(strcmp(type, 'score'))
                scoreText = sprintf('Score: %d', obj.score);
                axes('Position', [0.8, 0.95, 0, 0]);
                obj.scoreObject = text(0, 0, scoreText, 'FontSize', 18, 'Color', 'white');
                return
            end
            xPos = xPos / obj.xWindowSize;
            yPos = yPos / obj.yWindowSize;         
            if(strcmp(type, 'diver'))
                axes('Position', [xPos, yPos + 0.02, obj.diverWidth/obj.xWindowSize, obj.diverHeight/obj.yWindowSize + 0.02]); % related to size & pos; it's normalized
                obj.diverImageObject = imshow(obj.diverImage);
                obj.diverImageObject.AlphaData = obj.diverAlphaChannel;              
            elseif(strcmp(type, 'chest'))
                axes('Position', [xPos, yPos, obj.chestWidth/obj.xWindowSize, obj.chestHeight/obj.yWindowSize]);
                obj.chestImageObject = imshow(obj.chestImage);
                obj.chestImageObject.AlphaData = obj.chestAlphaChannel; 
            else
                disp('object type not recognized in paint method');
            end   
        end
        
        function obj = removeImageObject(obj, type)
            if(strcmp(type, 'diver'))
                delete(obj.diverImageObject);           
            elseif(strcmp(type, 'chest'))
                delete(obj.chestImageObject);
            elseif(strcmp(type, 'score'))
                delete(obj.scoreObject);
            else
                disp('object type not recognized in remove method');
            end          
        end
        
        function obj = moveDiver(obj, command)
            if(checkBorder(obj, command))
                disp('diver cannot move further!');
                return
            end    
            xPos = obj.xDiverCurrentPos;
            yPos = obj.yDiverCurrentPos;
            switch(command)
                case 'up'
                    yPos = yPos + obj.moveStepSize;
                case 'down'
                    yPos = yPos - obj.moveStepSize;
                case 'right'
                    xPos = xPos + obj.moveStepSize;
                case 'left'
                    xPos = xPos - obj.moveStepSize;          
            end
            obj.xDiverCurrentPos = xPos;
            obj.yDiverCurrentPos = yPos;
            repaintDiver(obj);
            if(checkScored(obj))
                obj.score = obj.score + 1;  
                repaintChest(obj);
                obj.xDiverCurrentPos = obj.xWindowSize / 2;
                obj.yDiverCurrentPos = obj.yChestCurrentPos;
                repaintDiver(obj);
                repaintScore(obj);
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
            if((obj.xDiverCurrentPos <= obj.moveStepSize && strcmp(command, 'left')) || ...
              ((obj.xWindowSize - obj.xDiverCurrentPos - obj.diverWidth) <= obj.moveStepSize && strcmp(command, 'right')) || ...
              (obj.yDiverCurrentPos <= obj.moveStepSize && strcmp(command, 'down')) || ...
              ((obj.yWindowSize - obj.yDiverCurrentPos - obj.diverHeight) <= obj.moveStepSize && strcmp(command, 'up')))
                isBorder = true;
            else
                isBorder = false;
            end
        end    
        
        
    end
    
    methods(Static)
        
    end
end