function Run(self)
    %Run the main function of basalESTMD, for a image sequence
    
    % initialize parameter
    self.Init();
    
    % Frame by frame work
    while true
        self.Read_Image2gray(); % matrix the input image
        
        % Set the stop statement
        if self.InputState == 0 || ...
                (self.EndFrame>0 && self.NowFrame > self.EndFrame)
            break;
        end        
        pause(0.0001);
        if self.Isvisualize
            if strcmpi(get(self.H.v_h,'CurrentCharacter'),'e')
                % detection exits the dead-loop mode:
                % click <e> of the keyboard in the graph window
                break;
            end
        end
        
        
        self.Retina(); % retina layer
        self.Lamina(); % lamina layer
        self.Medulla(); % medulla layer
        self.Lobula(); % lobula layer
        if self.IsRecondOutput
            % recond output
            self.RecondOutput();
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