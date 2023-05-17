function Lobula(self)
    %Lobula lobula layer in feedback STMD
    
    % Correlation_Output_E
    self.Correlation_Output_E = ...
        conv2(self.ON_Channel.*self.Delay_OFF_Channel, self.W_e, 'same');
    
    % Recond D + E
    self.Cell_D_add_E(1) = [];
    self.Cell_D_add_E{end+1} = self.Correlation_Output_E;
    
    % calculate the feedback signal
    self.Feedback_signal...
        = self.alpha...
        .*  ClassSTMD.Cell_Conv_N_1(...
        self.Cell_D_add_E,      ...
        self.Gammakernel_4      );
    
    % calculate the Correlation_Output_D
    self.Correlation_Output_D = ...
        self.HalfWaveR( self.ON_Channel        - self.Feedback_signal) ...
        .* ...
        self.HalfWaveR( self.Delay_OFF_Channel - self.Feedback_signal);
    
    % Record D + E
    self.Cell_D_add_E{end} = ...
        self.Correlation_Output_E + self.Correlation_Output_D;
    
    % Lateral Inhibition Mechanism
    self.Lobula_Output = ...
        conv2(self.Correlation_Output_D, self.InhibitionKernel_W2, 'same');
    
    self.Lobula_Output = self.HalfWaveR(self.Lobula_Output);
end


