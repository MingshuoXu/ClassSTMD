function Prediction_Module(self)
    %PREDICTION_MODULE 此处显示有关此函数的摘要
    %   此处显示详细说明

    %% F
    temp = zeros(self.IMAGE_H, self.IMAGE_W);
    for k = 1 : self.DSTMD_Directions
        if isempty(self.Cell_Prediction_gain{1})
            self.Prediction_gain{k}...
                = conv2(...
                self.mu * self.Lobula_Output(:,:,k) ,...
                self.Prediction_Kernal{k},...
                'same' );
        else
            temp_1 = self.mu  * self.Lobula_Output(:,:,k) ...
                + (1-self.mu) * self.Cell_Prediction_gain{1,k};
            self.Prediction_gain{k}...
                = conv2(temp_1, self.Prediction_Kernal{k},'same');
        end
        temp = temp + self.Prediction_gain{1,k};
    end

    %% update the Prediction_map and Record Cell_Prediction_map
    self.Prediction_map = ( temp > max(temp(:)/5) );

    self.Cell_Prediction_map(1) = [];
    self.Cell_Prediction_map{end+1} = self.Prediction_map;

    %% Record Cell_Prediction_gain
    self.Cell_Prediction_gain(1,:) = [];
    [self.Cell_Prediction_gain{end+1,:}] = deal(self.Prediction_gain{1,:});

    %% Calculate Facilitated_STMD_Output
    for theta_ = 1 : self.DSTMD_Directions
    self.Facilitated_STMD_Output(:,:,theta_)...
        = self.Lobula_Output(:,:,theta_) ...
        + self.beta * ClassSTMD.Cell_Conv_N_1(  ...
        self.Cell_Prediction_gain(:,theta_),              ...
        self.Time_Attenuation                   );
    end
    %% Output
    self.Output = max(self.Facilitated_STMD_Output,[],3);
    %% Direction
    self.Direction...
        = ClassSTMD.DSTMD_Core.Calculate_Direction(...
        self.Facilitated_STMD_Output);
end
