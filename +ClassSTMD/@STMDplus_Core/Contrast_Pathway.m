function  Contrast_Pathway(self)
    %Contrast_Pathway �˴���ʾ�йش˺�����ժҪ
    %   �˴���ʾ��ϸ˵��
    for i = 1:self.W_T_FilterNum
        self.Contrast_Output(:,:,i) = ...
            conv2(self.Photoreceptors_Output , self.W_T(:,:,i), 'same');
    end
    
end

