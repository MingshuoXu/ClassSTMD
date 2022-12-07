function Lobula(self)
    %Lobula lobula layer
    % The output obtained by lateral suppression of Correlation_Output
    
    % Correlation_Output
    self.Correlation_Output = self.ON_Channel .* self.Delay_OFF_Channel;
    % Lateral Inhibition Mechanism
    self.Lateral_Inhibition_Output = ...
        conv2(self.Correlation_Output, self.InhibitionKernel_W2, 'same');
    % Half-wave Rectification
    self.Lobula_Output = self.HalfWaveR(self.Lateral_Inhibition_Output);
end


