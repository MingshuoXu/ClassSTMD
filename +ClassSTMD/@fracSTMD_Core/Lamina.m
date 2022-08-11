function Lamina(self)
    %Lamina lamina layer, by fractional derivative operator
    %   References:
    %   * M. Caputo, M. Fabrizio, A new definition of fractional derivative
    %   without singular kernel, Progress in Fractional Differentiation &
    %   Applications 1 (2) (2015) 73¨C85.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-11  
    
    % fractional derivative kernel
    self.Lamina_Output = ClassSTMD.ToolFun.Conv_3(...
        self.Matrix_Photoreceptors_Output,...
        self.FractionalDerivativeKernel );
    % The step size factor of the first derivative approximation.
    self.Lamina_Output = self.Lamina_Output .* self.SamplingFrequency;
    % This line of code has no impact on the detection performance of the model. 
    % In practice, it can be omitted to reduce the amount of calculation.
end

