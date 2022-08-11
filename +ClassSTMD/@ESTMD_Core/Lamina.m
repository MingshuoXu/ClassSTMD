function Lamina(self)
    %Lamina lamina layer
    %   References:
    %   * S. D. Wiederman, P. A. Shoemarker, D. C. O¡¯Carroll, A model
    %   for the detection of moving targets in visual clutter inspired by
    %   insect physiology, PLoS ONE 3 (7) (2008) e2784¨C.
    %   * Wang H, Peng J, Yue S. A directionally selective small target
    %   motion detecting visual neural network in cluttered backgrounds[J].
    %   IEEE transactions on cybernetics, 2018, 50(4): 1541-1555.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-11
    
    
    % Band Pass Filter = Gamma Function1 - Gamma Function2
    
    % GammaFun1 output
    self.GammaFun1_Output = ...
        ClassSTMD.ToolFun.Conv_3(self.Matrix_Photoreceptors_Output,self.Gammakernel_1);
    % GammaFun2 output
    self.GammaFun2_Output = ...
        ClassSTMD.ToolFun.Conv_3(self.Matrix_Photoreceptors_Output,self.Gammakernel_2);
    % Band Pass output
    self.Lamina_Output = self.GammaFun1_Output - self.GammaFun2_Output;
end

