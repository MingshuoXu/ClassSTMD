function  Contrast_Pathway(self)
    %Contrast_Pathway 此处显示有关此函数的摘要
    %   此处显示详细说明
    for i = 1:self.W_T_FilterNum
        self.Contrast_Output(:,:,i) = ...
            conv2(self.Photoreceptors_Output , self.W_T(:,:,i), 'same');
    end
    
end

