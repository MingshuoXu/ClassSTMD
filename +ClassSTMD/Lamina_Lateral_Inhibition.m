classdef Lamina_Lateral_Inhibition < handle
    %Gamma_Filter Gamma filter in lamina layer
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
    
    properties
        size_W1 = [15,15,7];
        sigma2 = 1.5;
        sigma3;
        lambda1 = 3;
        lambda2 = 9;
    end
    
    properties(Hidden)
        W_S_P;
        W_S_N;
        W_T_P;
        W_T_N;
        Cell_BP_W_S_P;
        Cell_BP_W_S_N;
    end
    
    methods
        function self = Lamina_Lateral_Inhibition(...
                size_W1, lambda1, lambda2, sigma2, sigma3)
            if nargin >= 1
                self.size_W1 = size_W1;
            end
            if nargin >= 2
                self.lambda1 = lambda1;
            end
            if nargin >= 3
                self.lambda2 = lambda2;
            end
            if nargin >= 4
                self.sigma2 = sigma2;
            end
            if nargin >= 5
                self.sigma3 = sigma3;
            end
            self.init_ESTMD_W1();
        end
        
        function init_ESTMD_W1(self)
            %W1 Inhibition kernal W1 in ESTMD
            if isempty(self.sigma3)
                self.sigma3 = 2 * self.sigma2;
            end
            G_sigma2 = fspecial('gaussian', self.size_W1(1:2), self.sigma2);
            G_sigma3 = fspecial('gaussian', self.size_W1(1:2), self.sigma3);
            temp = G_sigma2 - G_sigma3;
            self.W_S_P = max( temp, 0);
            self.W_S_N = max(-temp, 0);
            
            t = ( 1:self.size_W1(3) ) - 1;
            self.W_T_P = exp(-t/self.lambda1) / self.lambda1;
            self.W_T_N = exp(-t/self.lambda2) / self.lambda2;
            
            self.Cell_BP_W_S_P = cell(self.size_W1(3),1);
            self.Cell_BP_W_S_N = cell(self.size_W1(3),1);
        end
        
        function Lateral_Inhibition_Output = go(self, Input)
            % Lateral inhibition
            self.Cell_BP_W_S_P(1) = [];
            self.Cell_BP_W_S_P{end+1} = conv2(Input, self.W_S_P, 'same');
            self.Cell_BP_W_S_N(1) = [];
            self.Cell_BP_W_S_N{end+1} = conv2(Input, self.W_S_N, 'same');

            Lateral_Inhibition_Output...
                = ClassSTMD.Cell_Conv_N_1(self.Cell_BP_W_S_P, self.W_T_P)...
                + ClassSTMD.Cell_Conv_N_1(self.Cell_BP_W_S_N, self.W_T_N);
        end
    end
    
end




