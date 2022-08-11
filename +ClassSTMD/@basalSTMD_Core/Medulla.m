function Medulla(self)
    %Medulla medulla layer
    
    % Tm3 cells
    self.ON_Channel = max(self.Lamina_Output,0);
    % Tm2 cells
    self.OFF_Channel = max(-self.Lamina_Output,0);
    % recond the output of Tm2 cells
    self.Matrix_OFF_Channel(:,:,1:end-1) = self.Matrix_OFF_Channel(:,:,2:end);
    self.Matrix_OFF_Channel(:,:,end) = self.OFF_Channel;
    % delay Tm2 cells to obtain output of Tm1 cells
    self.Delay_OFF_Channel = ClassSTMD.ToolFun.Conv_3(self.Matrix_OFF_Channel,self.Gammakernel_3);
end