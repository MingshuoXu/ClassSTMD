classdef visualization < handle
    % a class to visualize the model output
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-05-06
    
    properties
        v_h; % figure handle
        wait_h; % waitbar handle
        Show_Threshold = 0.8;
        NMS_radius = 15;
        IsSaveAsVideo = false;
        SavePath;
        VideoName;
        STMD_class_name;
        IsTestPatter = false;
    end
    properties(Hidden)
        SaveState = false;
        VideoObj;
        tic_t0;
    end
    
    methods
        function self = visualization(class_name)
            if nargin == 1
                self.STMD_class_name = class_name;
            elseif nargin == 0
                self.STMD_class_name = 'none';
            else
                error(['The constructor of a visual class',...
                    ' takes at most one input parameter!']);
            end
        end
        
        function Establish_fig_handle(self)
            self.v_h = figure(...
                'Name'          , ['visualization--', self.STMD_class_name],...
                'NumberTitle'   , 'off',...
                'Position'      , [450,50,800,500] );
            if ~self.IsTestPatter
                set(self.v_h,'menubar','none','toolbar','none');
            end
            fprintf('visualizating the output, enter ''e'' to exit\n');
        end
        
        function Establish_bar_handle(self)
            self.wait_h = waitbar(...
                0           , 'Start running'       ,...
                'name'      , self.STMD_class_name  ,...
                'Position'  , [450,450,270,50]      );
            self.tic_t0 = tic;
        end
        
        function show_STMD(self, NowFrame, Original_Image, Output, Direction)
            figure(self.v_h);
            imshow(Original_Image);
            % This is to keep the window consistent when saving as video
            axis manual;
            title(['current frame = ',num2str(NowFrame)]);
            temp = Output;
            max_ = max(temp(:));
            if max_ > 0 % normalization
                temp = temp/max_;
            else
                return;
            end
            % NMS
            temp = ClassSTMD.NMS(temp, self.NMS_radius);
            
            [index_x, index_y] = find(temp > self.Show_Threshold); 
            hold on;
            plot(index_y, index_x   , '*'   ,...
                'MarkerEdgeColor'   , 'r'   ,...
                'MarkerSize'        ,  5    );
            
            if nargin > 4 % Direction
                U = cos(Direction);
                V = sin(Direction);
                
                linearInd_Direction = sub2ind(size(U),index_x,index_y);
                D_U = U(linearInd_Direction);
                D_V = V(linearInd_Direction);
                D_U( isnan(D_U) ) = 0;
                D_V( isnan(D_V) ) = 0;
                
                arrow_length = 20;
                % In the figure of imshow, the positive direction of
                %   the y axis is downward, that is 'axis IJ'.
                quiver(index_y,index_x,...
                    arrow_length * D_U,...
                    -arrow_length * D_V,...
                    0);
            end
            hold off;
            drawnow;
            if self.IsSaveAsVideo
                self.Save_Video();
            end
        end
        
        function Save_Video(self)
            if self.SaveState == 0
                if isempty(self.SavePath)
                    self.SavePath = pwd;
                elseif ~isfolder(self.SavePath)
                    mkdir(self.SavePath)
                    if ~isfolder(self.SavePath)
                        error([self.SavePath,...
                            ' is not a folder and',...
                            ' cannot be created automatically.']);
                    end
                end
                if isempty(self.VideoName)
                    self.VideoName = 'visualization_video.avi';
                end
                filename = fullfile(self.SavePath,self.VideoName);
                self.VideoObj = VideoWriter(filename);
                self.VideoObj.FrameRate = 10;
                
                filename = [filename,'.',self.VideoObj.FileFormat];
                fprintf('Visual output video is saved as ''%s''.\n',filename);
                open(self.VideoObj);
                self.SaveState = true;
            end
            currFrame = getframe(self.v_h);
            writeVideo(self.VideoObj,currFrame);
        end
        
        function wait_BAR(self,t,StartFrame,EndFrame)
            if EndFrame ~= 0
                wait_ = (t-StartFrame)/(EndFrame-StartFrame);
            else
                wait_ = 0;
            end
            
            TimeWithFrame = toc(self.tic_t0);
            waitbar_str = ...
                sprintf('current frame: %d; elapsed time: %.3f s/frame.',...
                t, TimeWithFrame);
            self.wait_h = waitbar(wait_,self.wait_h,waitbar_str);
            self.tic_t0 = tic;
        end
        
        function delete(self)
            close(self.VideoObj);
            try %#ok<TRYNC> 
                close(self.wait_h);
            end
            try %#ok<TRYNC> 
                close(self.v_h);
            end
        end
        
    end % end methods
end
