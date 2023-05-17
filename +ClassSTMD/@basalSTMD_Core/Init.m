function Init(self)
    %Init Initialize function
    
    % Weakly dependent variable
    if isempty(self.Gammakernel_3_len)
        self.Gammakernel_3_len = 3 * ceil(self.Gammakernel_3_Tau);
    end
    if isempty(self.LMCs_len)
        self.LMCs_len = 2;
    end
    
    % Real-time detection, dead loop
    if self.EndFrame == 0
        self.StartFrame = 1;
        self.Isvisualize = true;
        if isempty(self.IsRecordOutput)
            self.IsRecordOutput = false;
        end
    elseif isempty(self.IsRecordOutput)
        self.IsRecordOutput = true;
    end
    
    % Init kernel
    self.init_GaussFilter();
    self.init_Gammakernel_3();
    self.InhibitionKernel_W2 = ...
        ClassSTMD.ToolFun.Generalize_Lateral_InhibitionKernel_W2();
    
    % Get the data set picture size
    self.NowFrame = self.StartFrame;
    self.Read_Image2gray();
    
    % Allocate memory
    [self.IMAGE_H,self.IMAGE_W] = size(self.Input);
    
    self.Cell_Photoreceptors_Output = cell(self.LMCs_len, 1);
    
    self.Cell_OFF_Channel = cell(self.Gammakernel_3_len, 1);
    
    if self.IsRecordOutput
        self.Cell_Output = cell(self.EndFrame, 1);
    end
    
    % Instantiate the visualization class and assign the handle
    if self.Isvisualize || self.IsWaitbar || self.IsSaveAsVideo
        class_ = whos('self');
        class_name = class_.class;
        self.H = ClassSTMD.visualization(class_name);
        if self.IsSaveAsVideo
            % Save the visual output as a video
            self.H.IsSaveAsVideo = true;
            self.Isvisualize = true;
            self.H.SavePath = self.Video_Par{1};
            self.H.VideoName = self.Video_Par{2};
        end
        if self.Isvisualize
            % Instantiate the figure handle class
            if self.IsTestPatterinVisualization
                self.H.IsTestPatter = true;
            end
            self.H.Establish_fig_handle();
            
            if ~isempty(self.visualize_Threshold)
                self.H.Show_Threshold = self.visualize_Threshold;
            end
        end
        if self.IsWaitbar
            % Instantiate the figure handle class
            self.H.Establish_bar_handle();
        end
    end
    
    
    
end