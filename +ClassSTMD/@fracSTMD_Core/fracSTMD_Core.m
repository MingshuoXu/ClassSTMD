classdef fracSTMD_Core < ClassSTMD.basalSTMD_Core
    %fracSTMD_Core Fractional-order Small Target Motion Detectors
    %
    %    api:
    %    addpath('[the parent folder of ClassSTMD]');
    %    import ClassSTMD.*;
    %    obj = fracSTMD_Core();
    %    % full path of ImageName
    %
    %    obj.get_ImageName = ...
    %       @(path0,Imagetitle,Imagetype,NowFrame)...
    %       ['full file name'];
    %
    %    % Set parameters of Small Target Motion Detectors
    %    % obj.Gammakernel_3_Tau = 25; 
    %    % ...
    %    obj.Run() % Program started
    %
    %   References:
    %   * M. Caputo, M. Fabrizio, A new definition of fractional derivative
    %   without singular kernel, Progress in Fractional Differentiation &
    %   Applications 1 (2) (2015) 73¨C85.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-11  
    
    properties
        FractionalDerivative_Order;
        FractionalDerivativeKernel_len;
        
    end
    properties(Hidden)
        FractionalDerivativeKernel;  
        FD_Integral_Time = 0.1;
    end
    
    methods
        % Constructor function
        function self = fracSTMD_Core()
            self@ClassSTMD.basalSTMD_Core();
            self.Gammakernel_3_Order = 100;
        end
        
        % Some initialization kernel function
        function init_FractionalDerivativekernel(self)
            if isempty(self.FractionalDerivative_Order)
                self.FractionalDerivative_Order = ...
                    min(0.8, 100/self.SamplingFrequency+0.1);
            end
            self.FractionalDerivativeKernel = ...
                ClassSTMD.ToolFun.Generalize_FractionalDerivativeKernel(...
                self.FractionalDerivative_Order,...
                self.FractionalDerivativeKernel_len);
        end
        % Initialize function
        function Init(self)
            % weakly dependent variable
            if isempty(self.FractionalDerivativeKernel_len)
                self.FractionalDerivativeKernel_len = ...
                    ceil(self.FD_Integral_Time * self.SamplingFrequency);
            end
            if isempty(self.LMCs_len)
                self.LMCs_len = self.FractionalDerivativeKernel_len;
            end
            % init kernel
            self.init_FractionalDerivativekernel();
            % Initialization of inherited functions
            Init@ClassSTMD.basalSTMD_Core(self);
            self.ESTMD_Lateral_Inhibition_Kernel = ...
                ClassSTMD.ToolFun.Generalize_ESTMD_Lateral_InhibitionKernel(...
                15, 1.5, 3, 1.8, 0, 1, 3);
        end
        
    end% end methods
    methods % The function body is outside the class function
        Lamina(self); % lamina layer
    end% end methods
end
    
