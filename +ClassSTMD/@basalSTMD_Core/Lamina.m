function Lamina(self)
    %Lamina lamina layer, by first order difference
    
    % first order difference
    self.Lamina_Output = ...
        self.Matrix_Photoreceptors_Output(:,:,end) - ...
        self.Matrix_Photoreceptors_Output(:,:,end-1) ;
end

