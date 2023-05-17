function Feedback_Pathway(self)
    %Feedback_Pathway
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-11
    if ~self.count
        self.Cell_Lobula_Output(1) = [];
        self.Cell_Lobula_Output{end+1} = zeros(self.IMAGE_H, self.IMAGE_W);
    end
    
    self.Time_Delay_Feedback...
        = self.a...
        * ClassSTMD.Cell_Conv_N_1(self.Cell_Lobula_Output, self.Gammakernel_4);
    
    self.Cell_Photoreceptors_Output{end} ...
        = self.Photoreceptors_Output + self.Time_Delay_Feedback;
end