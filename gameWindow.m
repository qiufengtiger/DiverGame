classdef gameWindow < handle
    % the game window is 650 by 650
    % variable obj refers to the gameWindow object
    properties
        xWindowSize;
        yWindowSize;
        xDiverInitialPos;
        yDiverInitialPos;
        xDiverCurrentPos;
        yDiverCurrentPos;
        gameFigure;
        diverImage;
        map;
        alphaChannel;
        imageObject;
    end
    
    methods
        function obj = gameWindow()
            obj.xWindowSize = 650;
            obj.yWindowSize = 650;
            obj.xDiverInitialPos = 325;
            obj.yDiverInitialPos = 325;
            obj.xDiverCurrentPos = obj.xDiverInitialPos;
            obj.yDiverCurrentPos = obj.yDiverInitialPos;
%             setup(obj);
        end
        
        function obj = setup(obj)
            obj.gameFigure = figure('Name', 'DiverGame', 'NumberTitle', 'off', 'Color', 'cyan', 'Units', 'pixels', 'Resize', 'off', ...
            'Position', [100, 100, obj.xWindowSize, obj.yWindowSize], 'keyPressFcn', {@keyPressed, obj});       
            [a, b, c] = imread('scuba75.png');
            obj.diverImage = a;
            obj.map = b;
            obj.alphaChannel = c;
            paintDiver(obj, obj.xDiverInitialPos, obj.yDiverInitialPos);
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
            removeDiver(obj);
            paintDiver(obj, xPos, yPos);
        end
        
        function obj = paintDiver(obj, xPos, yPos)
            xPos = xPos / obj.xWindowSize;
            yPos = yPos / obj.yWindowSize;
            axes('Position', [xPos, yPos, 0.115, 0.0676]); 
            obj.imageObject = imshow(obj.diverImage);
            obj.imageObject.AlphaData = obj.alphaChannel;
        end
        
        function obj = removeDiver(obj)
            delete(obj.imageObject);
        end
        
        function obj = moveDiver(obj, command)
            xPos = obj.xDiverCurrentPos;
            yPos = obj.yDiverCurrentPos;
            switch(command)
                case 'up'
                    yPos = yPos + 10;
                case 'down'
                    yPos = yPos - 10;
                case 'right'
                    xPos = xPos + 10;
                case 'left'
                    xPos = xPos - 10;          
            end
            obj.xDiverCurrentPos = xPos;
            obj.yDiverCurrentPos = yPos;
            repaintDiver(obj);
        end
    end
    
    methods(Static)
        
    end
end