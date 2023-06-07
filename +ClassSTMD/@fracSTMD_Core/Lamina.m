function Lamina(self)
    %Lamina lamina layer, by fractional derivative operator
    %   References:
    %   * M. Caputo, M. Fabrizio, A new definition of fractional derivative
    %   without singular kernel, Progress in Fractional Differentiation &
    %   Applications 1 (2) (2015) 73¨C85.
    %
    %   Author: Mingshuo Xu
    %   E-mail: mingshuoxu99@gmail.com
    %   Date: 2022-01-10
    %   LastEditTime: 2023-06-06

    
    Diff_Retine = ...
        self.Cell_Photoreceptors_Output{2} ...
        - self.Cell_Photoreceptors_Output{1};
    self.Lamina_Output = ...
        self.Lamina_cur * Diff_Retine...
        + self.Lamina_pre * self.Lamina_Output;

    %{
    % fractional derivative kernel
    self.Lamina_Output...
        = ClassSTMD.Cell_Conv_N_1(          ...
        self.Cell_Photoreceptors_Output,    ...
        self.FractionalDerivativeKernel     );
    % The step size factor of the first derivative approximation.
    self.Lamina_Output = self.Lamina_Output .* self.SamplingFrequency;
    % This line of code has no impact on the detection performance of the model. 
    % In practice, it can be omitted to reduce the amount of calculation.
    %}
end

