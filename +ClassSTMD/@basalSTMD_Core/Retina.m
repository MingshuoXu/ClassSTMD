function Retina(self)
    %Retina retina layer
    
    % perform GaussFilter to input
    self.Photoreceptors_Output = conv2(self.Input, self.GaussFilter, 'same');
    % recond the photoreceptors output
    self.Cell_Photoreceptors_Output(1) = [];
    self.Cell_Photoreceptors_Output{end+1} = self.Photoreceptors_Output;
end