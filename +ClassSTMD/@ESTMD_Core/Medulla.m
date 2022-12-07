function Medulla(self)
    %Medulla medulla layer
    
    % Tm3 cells
    self.ON_Channel = self.HalfWaveR(self.Lamina_Output);
    self.ON_Channel = ...
        conv2(self.ON_Channel, self.InhibitionKernel_W2,'same');
    self.ON_Channel = self.HalfWaveR(self.ON_Channel);
    % Tm2 cells
    self.OFF_Channel = self.HalfWaveR(-self.Lamina_Output);
    self.OFF_Channel = ...
        conv2(self.OFF_Channel, self.InhibitionKernel_W2,'same');
    self.OFF_Channel = self.HalfWaveR(self.OFF_Channel);
    
    % recond the output of Tm2 cells
    self.Cell_OFF_Channel(1) = [];
    self.Cell_OFF_Channel{end+1} = self.OFF_Channel;

    % delay Tm2 cells to obtain output of Tm1 cells
    self.Delay_OFF_Channel ...
        = ClassSTMD.Cell_Conv_N_1(self.Cell_OFF_Channel, self.Gammakernel_3);
    
end