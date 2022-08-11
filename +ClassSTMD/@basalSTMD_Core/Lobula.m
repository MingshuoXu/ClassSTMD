function Lobula(self)
    %Lobula lobula layer
    % The output obtained by lateral suppression of Correlation_Output
    
    % Correlation_Output
    self.Correlation_Output = self.ON_Channel .* self.Delay_OFF_Channel;
    % Lateral Inhibition Mechanism
    self.Lateral_Inhibition_Output = ...
        conv2(self.Correlation_Output,self.ESTMD_Lateral_Inhibition_Kernel,'same');
    % Half-wave Rectification
    self.Lobula_Output = max(self.Lateral_Inhibition_Output,0);
end


