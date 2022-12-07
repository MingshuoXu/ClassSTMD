function Lobula(self)
    %Lobula lobula layer for DSTMD
    %   References:
    %   * Wang H, Peng J, Yue S. A directionally selective small target
    %   motion detecting visual neural network in cluttered backgrounds[J].
    %   IEEE transactions on cybernetics, 2018, 50(4): 1541-1555.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-11
    
    % recond ON Channel output
    self.Cell_ON_Channel(1) = [];
    self.Cell_ON_Channel{end+1} = self.ON_Channel;
    
    % delay Mi1 for (x,y)
    self.Delay_ON_Channel...
        = ClassSTMD.Cell_Conv_N_1(self.Cell_ON_Channel, self.Gammakernel_4);
    % delay Tm1 for (x,y)
    self.Delay_OFF_Channel_1...
        = ClassSTMD.Cell_Conv_N_1(self.Cell_OFF_Channel, self.Gammakernel_5);
    % delay Tm1 for (x',y')
    self.Delay_OFF_Channel_2...
        = ClassSTMD.Cell_Conv_N_1(self.Cell_OFF_Channel, self.Gammakernel_6);
    
    % Correlation range
    CorrelationRegion_Row = (1+self.DSTMD_Dist):(self.IMAGE_H-self.DSTMD_Dist);
    CorrelationRegion_Col = (1+self.DSTMD_Dist):(self.IMAGE_W-self.DSTMD_Dist);
    % Correlation Output
    for k = 1:self.DSTMD_Directions
        % Correlation position
        X_Com = round( self.DSTMD_Dist * cos((k-1)*2*pi/self.DSTMD_Directions + pi/2 ) );
        Y_Com = round( self.DSTMD_Dist * sin((k-1)*2*pi/self.DSTMD_Directions + pi/2 ) );
        % Here, Correlation Output use the ON * (Delay_OFF + Delay_ON') * Delay_OFF'
        % The plane coordinate system is the matrix coordinate system
        % rotated 90 degrees counterclockwise.
        % Thus, we add pi/2 to the Angle of X_Com and Y_Com.
        self.Correlation_Output(CorrelationRegion_Row,CorrelationRegion_Col,k) = ...
            self.ON_Channel(CorrelationRegion_Row,CorrelationRegion_Col)...
            .* ( ...
            self.Delay_OFF_Channel_1(CorrelationRegion_Row,CorrelationRegion_Col)...
            + self.Delay_ON_Channel(CorrelationRegion_Row+X_Com,CorrelationRegion_Col+Y_Com)...
            ) .* ...
            self.Delay_OFF_Channel_2(CorrelationRegion_Row+X_Com,CorrelationRegion_Col+Y_Com);
    end
    
    % Lateral Inhibition Output
    for tt = 1:8
        self.Lateral_Inhibition_Output(:,:,tt)          ...
            = conv2(self.Correlation_Output(:,:,tt),    ...
            self.InhibitionKernel_W2, 'same'            );
    end
    % Half-wave Rectification
    self.Lateral_Inhibition_Output = self.HalfWaveR(self.Lateral_Inhibition_Output);
    
    % Second-order Lateral Inhibition
    Directional_Inhibition_Outputs...
        = ClassSTMD.DSTMD_Core.Directional_Inhibition(...
        self.Lateral_Inhibition_Output, ...
        self.DSTMD_Directional_Inhibition_Kernel);
    
    % Lobula Output
    self.Lobula_Output = self.HalfWaveR(Directional_Inhibition_Outputs);
    
    %% Output
    self.Output = max(self.Lobula_Output, [], 3);
    
    %% Direction
    self.Direction...
        = ClassSTMD.DSTMD_Core.Calculate_Direction(self.Lobula_Output);
end


