function Lamina(self)
    %Lamina lamina layer, by first order difference
    
    if isempty(self.Cell_Photoreceptors_Output{end-1})
        self.Lamina_Output = self.Photoreceptors_Output;
    else
        % First order difference
        self.Lamina_Output...
            = self.Photoreceptors_Output ...
            - self.Cell_Photoreceptors_Output{end-1};
    end
end

