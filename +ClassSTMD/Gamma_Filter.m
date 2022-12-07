classdef Gamma_Filter < handle
    %Gamma_Filter Gamma filter in lamina layer
    %   References:
    %   * S. D. Wiederman, P. A. Shoemarker, D. C. O¡¯Carroll, A model
    %   for the detection of moving targets in visual clutter inspired by
    %   insect physiology, PLoS ONE 3 (7) (2008) e2784¨C.
    %   * Wang H, Peng J, Yue S. A directionally selective small target
    %   motion detecting visual neural network in cluttered backgrounds[J].
    %   IEEE transactions on cybernetics, 2018, 50(4): 1541-1555.
    %   * De Vries B, Pr¨ªncipe J. A theory for neural networks with time delays[J].
    %   Advances in neural information processing systems, 1990, 3.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-11
    
    properties
        Order1 = 2;
        Tau1 = 3;
        Order2 = 6;
        Tau2 = 9;
        Len1;
        Len2;
    end
    properties(Hidden)
        Gammakernel_1;
        Gammakernel_2;
        GammaFun1_Output;
        GammaFun2_Output;
    end
    
    methods
        function self = Gamma_Filter(...
                Order1, Tau1, Len1,...
                Order2, Tau2, Len2)
            if nargin >= 1
                self.Order1 = Order1;
            end
            if nargin >= 2
                self.Tau1 = Tau1;
            end
            if nargin >= 3
                self.Len1 = Len1;
            end
            if nargin >= 4
                self.Order2 = Order2;
            end
            if nargin >= 5
                self.Tau2 = Tau2;
            end
            if nargin >= 6
                self.Len2 = Len2;
            end
            self.Init_Gamma_kernel();
        end
        
        function Init_Gamma_kernel(self)
            if isempty(self.Len1)
                self.Len1 = 3 * ceil(self.Tau1);
            end
            if isempty(self.Len2)
                self.Len2 = 3 * ceil(self.Tau2);
            end
            self.Gammakernel_1 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Order1, self.Tau1, self.Len1 );
            self.Gammakernel_2 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Order2, self.Tau2, self.Len2);
        end
        
        function Filter_Output = go(self, Input)
            % Band Pass Filter = Gamma Function1 - Gamma Function2
            
            % GammaFun1 output
            self.GammaFun1_Output...
                = ClassSTMD.Cell_Conv_N_1(Input, self.Gammakernel_1);
            % GammaFun2 output
            self.GammaFun2_Output...
                = ClassSTMD.Cell_Conv_N_1(Input, self.Gammakernel_2);
            % recond the Band Pass output
            Filter_Output = self.GammaFun1_Output - self.GammaFun2_Output;
        end
    end
    
end
