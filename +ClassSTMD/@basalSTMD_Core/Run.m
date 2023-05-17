function Run(self)
    %Run the main function of basalESTMD, for a image sequence
    
    % Initialize parameter
    self.Init();
    
    % Frame by frame work
    while true
        self.Read_Image2gray(); % matrix the input image
        
        %% Set the stop statement
        if ~self.InputState || ...
                (self.EndFrame>0 && self.NowFrame > self.EndFrame)
            break;
        end        
        pause(0.0001);
        if self.Isvisualize
            if strcmpi(get(self.H.v_h,'CurrentCharacter'),'e')
                % Detection exits the dead-loop mode:
                % Click <e> of the keyboard in the graph window
                break;
            end
        end
        
        %% STMD neural network
        self.Retina(); % retina layer
        self.Lamina(); % lamina layer
        self.Medulla(); % medulla layer
        self.Lobula(); % lobula layer
        
        %% Record output
        if self.IsRecordOutput
            self.RecordOutput();
        end
        
        %% display progress bar
        if self.IsWaitbar
            self.H.wait_BAR(self.NowFrame,self.StartFrame,self.EndFrame);
        end
        
        %% visualize the output
        if self.Isvisualize
            self.Visualize();
        end
        
        %% 
        self.NowFrame = self.NowFrame + 1;
    end
    
    % Release the object of the visual class
    self.H = [];
end