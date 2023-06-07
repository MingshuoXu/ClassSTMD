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
        
        %% STMD neural network
        self.Retina(); % retina layer
        
        self.count = 0;
        while true
            
            self.Feedback_Pathway(); % feedback pathway
            self.Lamina(); % lamina layer
            self.Medulla(); % medulla layer
            self.Lobula(); % lobula layer
            
            if self.count > 0
                norm_error = norm(self.Lobula_Output - last_Op);
                if norm_error < self.Iterative_threshold ...
                        || self.count > self.max_count
                    break;
                end
            end
            
            last_Op = self.Lobula_Output;
            self.count = self.count + 1;
        end

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