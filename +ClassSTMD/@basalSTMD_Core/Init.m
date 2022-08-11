function Init(self)
    %Init Initialize function
    
    % weakly dependent variable
    if isempty(self.Gammakernel_3_len)
        self.Gammakernel_3_len = 3 * ceil(self.Gammakernel_3_Tau);
    end
    if isempty(self.LMCs_len)
        self.LMCs_len = self.Gammakernel_3_Tau;
    end
    
    % Real-time detection, dead loop
    if self.EndFrame == 0
        self.StartFrame = 1;
        self.Isvisualize = 1;
        if isempty(self.IsRecondOutput)
            self.IsRecondOutput = 0;
        end
    elseif isempty(self.IsRecondOutput)
        self.IsRecondOutput = 1;
    end
    
    % init kernel
    self.init_GaussFilter();
    self.init_Gammakernel_3();
    self.ESTMD_Lateral_Inhibition_Kernel = ...
        ClassSTMD.ToolFun.Generalize_ESTMD_Lateral_InhibitionKernel();
    
    % gets the data set picture size
    self.NowFrame = self.StartFrame;
    self.Read_Image2gray();
    
    % allocate memory
    [self.IMAGE_H,self.IMAGE_W] = size(self.Input);
    self.Matrix_OFF_Channel = ...
        zeros(self.IMAGE_H,self.IMAGE_W,self.Gammakernel_3_len);
    self.Matrix_Photoreceptors_Output = ...
        zeros(self.IMAGE_H,self.IMAGE_W,self.LMCs_len);
    if self.IsRecondOutput
        self.Matrix_Output = ...
            zeros(self.IMAGE_H,self.IMAGE_W,self.EndFrame);
    end
    
    % instantiate the visualization class and assign the handle
    if self.Isvisualize == 1 ...
            || self.IsWaitbar == 1 ...
            || self.IsSaveAsVideo == 1
        class_ = whos('self');
        class_name = class_.class;
        self.H = ClassSTMD.visualization(class_name);
        if self.IsSaveAsVideo == 1
            % Save the visual output as a video
            self.H.IsSaveAsVideo = 1;
            self.Isvisualize = 1;
            self.H.SavePath = self.Video_Par{1};
            self.H.VideoName = self.Video_Par{2};
        end
        if self.Isvisualize == 1
            % Instantiate the figure handle class
            self.H.Establish_fig_handle();
            if ~isempty(self.visualize_Threshold)
                self.H.MaxOperation_Threshold = self.visualize_Threshold;
            end
        end
        if self.IsWaitbar == 1
            % Instantiate the figure handle class
            self.H.Establish_bar_handle();
        end
    end
    
    
    
end