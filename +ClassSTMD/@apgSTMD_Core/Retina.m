function Retina(self)
    %Retina retina layer
    
    % perform GaussFilter to input
    self.Photoreceptors_Output = conv2(self.Input, self.GaussFilter, 'same');   
end