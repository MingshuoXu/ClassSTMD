function Retina(self)
    %Retina retina layer

    % perform GaussFilter to input
    self.Photoreceptors_Output = conv2(self.Input,self.GaussFilter,'same');
    % recond the photoreceptors output
    self.Matrix_Photoreceptors_Output(:,:,1:end-1) = self.Matrix_Photoreceptors_Output(:,:,2:end);
    self.Matrix_Photoreceptors_Output(:,:,end) = self.Photoreceptors_Output;
end