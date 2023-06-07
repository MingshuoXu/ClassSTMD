function Run(self)
    %Run the main function of basalESTMD, for a image sequence
    
    % initialize parameter
    self.Init();
    
    % Frame by frame work
    while true
        if self.EndFrame>0 && self.NowFrame > self.EndFrame
            break;
        else
            self.Read_Image2gray(); % gray the input image
            if ~self.InputState
                % Set the stop statement
                break;
            end
        end        
        
        if self.Isvisualize
            pause(0.00001);
            if strcmpi(get(self.H.v_h,'CurrentCharacter'),'e')
                % detection exits the dead-loop mode:
                % click <e> of the keyboard in the graph window
                break;
            end
        end

        %% Preprocessing Module
        self.Retina(); % retina layer

        %% Attention Module
        self.Attention_Module();
        
        %% STMD-based Neural Network
        self.Lamina(); % lamina layer
        self.Medulla(); % medulla layer
        self.Lobula(); % lobula layer

        %% Prediction Module
        self.Prediction_Module();
                
        %%
        if self.IsRecordOutput
            % recond output
            self.RecordOutput();
        end
        
        if self.IsWaitbar
            % display progress bar
            self.H.wait_BAR(self.NowFrame,self.StartFrame,self.EndFrame);
        end
        if self.Isvisualize
            % visualize the output
            self.Visualize();
        end
        self.NowFrame = self.NowFrame + 1;
    end
    
    % Release the object of the visual class
    self.H = [];
end