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

        self.Retina(); % retina layer
        
        %% Motion pathway
        self.Lamina(); % lamina layer
        self.Medulla(); % medulla layer
        self.Lobula(); % lobula layer
        
        %% Contrast pathway
        self.Contrast_Pathway();
        
        %% Mushroom body
        self.Mushroom_Body();

        %% recond output
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