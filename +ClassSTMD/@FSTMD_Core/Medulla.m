function Medulla(self)
    %Medulla medulla layer
    
    % Tm3 cells
    self.ON_Channel = self.HalfWaveR(self.Lamina_Output);
    % Tm2 cells
    self.OFF_Channel = self.HalfWaveR(-self.Lamina_Output);
    % recond the output of Tm2 cells
    if ~self.count
        self.Cell_OFF_Channel(1) = [];
        self.Cell_OFF_Channel{end+1} = self.OFF_Channel;
    else
        self.Cell_OFF_Channel{end} = self.OFF_Channel;
    end
    
    
    % delay Tm2 cells to obtain output of Tm1 cells
    self.Delay_OFF_Channel...
        = ClassSTMD.Cell_Conv_N_1(self.Cell_OFF_Channel, self.Gammakernel_3);
end