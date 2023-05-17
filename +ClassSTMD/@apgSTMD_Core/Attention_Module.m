function Attention_Module(self)
    %ATTENTION_MODULE 此处显示有关此函数的摘要
    %   此处显示详细说明
    [r,s] = size(self.Attention_Kernal);

    for i = 1:r
        A_j = conv2(self.Photoreceptors_Output,...
            self.Attention_Kernal{i,1}, 'same');
        for j = 2:s
            A_j = min(A_j,...
                conv2(self.Photoreceptors_Output,...
                self.Attention_Kernal{i,j}, 'same')...
                );
        end
        if i == 1
            Attent = A_j;
        else
            Attent = max(Attent, A_j);
        end
    end

    if isempty(self.Cell_Prediction_map{1})
        self.P_e = self.Photoreceptors_Output;
    else
        self.P_e = self.Photoreceptors_Output ...
            + self.alpha * self.HalfWaveR(Attent) .* ...
            self.Cell_Prediction_map{1};
    end

    self.Cell_P_e(1) = [];
    self.Cell_P_e{end+1} = self.P_e;

end

