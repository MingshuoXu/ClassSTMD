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
    self.Matrix_ON_Channel(:,:,1:end-1) = self.Matrix_ON_Channel(:,:,2:end);
    self.Matrix_ON_Channel(:,:,end) = self.ON_Channel;
    % delay Mi1 for (x,y)
    self.Delay_ON_Channel = ClassSTMD.ToolFun.Conv_3(...
        self.Matrix_ON_Channel,self.Gammakernel_4); 
    % delay Tm1 for (x,y)
    self.Delay_OFF_Channel_1 = ClassSTMD.ToolFun.Conv_3(...
        self.Matrix_OFF_Channel,self.Gammakernel_5); 
    % delay Tm1 for (x',y')
    self.Delay_OFF_Channel_2 = ClassSTMD.ToolFun.Conv_3(...
        self.Matrix_OFF_Channel,self.Gammakernel_6); 
    
    % Correlation range
    CorrelationRegion_Row = (1+self.DSTMD_Dist):(self.IMAGE_H-self.DSTMD_Dist);
    CorrelationRegion_Col = (1+self.DSTMD_Dist):(self.IMAGE_W-self.DSTMD_Dist);
    % Correlation Output
    for k = 1:self.DSTMD_Directions
        % Correlation position
        X_Com = round( self.DSTMD_Dist * cos((k-1)*2*pi/self.DSTMD_Directions ) );
        Y_Com = round( self.DSTMD_Dist * sin((k-1)*2*pi/self.DSTMD_Directions ) );
        % Here, Correlation Output use the ON * (Delay_OFF + Delay_ON') * Delay_OFF' 
        % The matrix is read first and then column, that is, Y before X
        % The direction of motion is opposite to the direction of the correlation
        % Here Y_com is positive and X_com is negative due to the index problem 
        %   of the matrix, which can be easily verified by calculation
        self.Correlation_Output(CorrelationRegion_Row,CorrelationRegion_Col,k) = ...
            self.ON_Channel(CorrelationRegion_Row,CorrelationRegion_Col)...
            .* ( ...
            self.Delay_OFF_Channel_1(CorrelationRegion_Row,CorrelationRegion_Col)...
            + self.Delay_ON_Channel(CorrelationRegion_Row+Y_Com,CorrelationRegion_Col-X_Com)...
            ) .* ...
            self.Delay_OFF_Channel_2(CorrelationRegion_Row+Y_Com,CorrelationRegion_Col-X_Com);
    end
    
    % Lateral Inhibition Output
    self.Lateral_Inhibition_Output = ...
        convn(self.Correlation_Output,self.DSTMD_Lateral_Inhibition_Kernel,'same');
    % Half-wave Rectification 
    self.Lateral_Inhibition_Output = max(self.Lateral_Inhibition_Output,0);
    
    % Second-order Lateral Inhibition
    Temp = repmat(self.Lateral_Inhibition_Output,[1,1,3]);
    Temp = convn(Temp,self.DSTMD_Directional_Inhibition_Kernel,'same');
    Directional_Inhibition_Outputs = ...
        Temp(:, :, self.DSTMD_Directions+1:2*self.DSTMD_Directions);
    % Lobula Output
    self.Lobula_Output = max(Directional_Inhibition_Outputs,0);
    
    %% Direction
    % Op = self.Correlation_Output;
    % Op = self.Lateral_Inhibition_Output;
    Op = self.Lobula_Output;

    [DSTMD_Output_cos,DSTMD_Output_sin] = ...
        deal(zeros(self.IMAGE_H,self.IMAGE_W));
    for i = 1:self.DSTMD_Directions
        DSTMD_Output_cos = DSTMD_Output_cos + ...
            Op(:,:,i) .* cos((i-1)*2*pi/self.DSTMD_Directions);
        DSTMD_Output_sin = DSTMD_Output_sin + ...
            Op(:,:,i) .* sin((i-1)*2*pi/self.DSTMD_Directions);
    end
    Direction_ = atan(DSTMD_Output_sin./DSTMD_Output_cos);
    Direction_(DSTMD_Output_cos<0) = Direction_(DSTMD_Output_cos<0) + pi;
    Direction_(Direction_<0) = Direction_(Direction_<0) + 2*pi;
    
    self.Direction = Direction_;
end

