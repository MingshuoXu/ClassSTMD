classdef feedbackSTMD_Core < ClassSTMD.basalSTMD_Core
    
    %feedbackSTMD_Core feedback Small Target Motion Detectors
    %
    %	api:
    %	addpath('[the parent folder of ClassSTMD]');
    %	import ClassSTMD.*;
    %	obj = feedbackSTMD_Core();
    %	% full path of ImageName
    %
    %     obj.get_ImageName = ...
    %         @(path0,Imagetitle,Imagetype,NowFrame)...
    %         ['full file name'];
    %
    %	% Set parameters of Small Target Motion Detectors
    %	% obj.Gammakernel_3_Tau = 25;
    %	% ...
    %	obj.Run() % Program started
    %
    %   References:
    %   * H. Wang, H. Wang, J. Zhao, C. Hu, J. Peng, S. Yue,
    %   A time-delay feedback neural network for discriminating small,
    %   fastmoving targets in complex dynamic environments, IEEE
    %   Transactions on Neural Networks and Learning Systems.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-29
    
    properties
        
    end
    properties(Hidden)
        Gammakernel_1_Order = 4;
        Gammakernel_1_Tau = 8;
        Gammakernel_1_len;
        Gammakernel_2_Order = 16;
        Gammakernel_2_Tau = 32;
        Gammakernel_2_len;
        Gammakernel_4_Order = 10;
        Gammakernel_4_Tau = 25
        Gammakernel_4_len;
        
        Lamina_Filter;
        Gammakernel_4;
        
        alpha = 1;
        
        W_e;
        size_W_e = 3;
        eta = 1.5;
        
        Feedback_signal;
        
        Correlation_Output_D;
        Correlation_Output_E;
        
        Cell_D_add_E;
    end
    
    methods
        % Constructor function
        function self = feedbackSTMD_Core()
            self = self@ClassSTMD.basalSTMD_Core();
            
            self.Gammakernel_3_Order = 9;
            self.Gammakernel_3_Tau = 45;
        end
        % Some initialization kernel function
        function init_Gammakernel_in_feedbackSTMD(self)
            self.Lamina_Filter = ClassSTMD.Gamma_Filter(...
                self.Gammakernel_1_Order,...
                self.Gammakernel_1_Tau,...
                self.Gammakernel_1_len,...
                self.Gammakernel_2_Order,...
                self.Gammakernel_2_Tau,...
                self.Gammakernel_2_len  );
            self. Gammakernel_4 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Gammakernel_4_Order,...
                self.Gammakernel_4_Tau,...
                self.Gammakernel_4_len);
        end
        function init_W_e(self)
            % initialize the GaussFilter of retina layer
            self.W_e = fspecial('gaussian', self.size_W_e, self.eta);
        end
        
        % Initialize function
        function Init(self)
            % weakly dependent variable
            if isempty(self.Gammakernel_1_len)
                self.Gammakernel_1_len = 3 * ceil(self.Gammakernel_1_Tau);
            end
            if isempty(self.Gammakernel_2_len)
                self.Gammakernel_2_len = 3 * ceil(self.Gammakernel_2_Tau);
            end
            if isempty(self.LMCs_len)
                self.LMCs_len...
                    = max(self.Gammakernel_1_len,self.Gammakernel_2_len);
            end
            if isempty(self.Gammakernel_4_len)
                self.Gammakernel_4_len = 3 * ceil(self.Gammakernel_4_Tau);
            end
            
            % Initialization of inherited functions
            Init@ClassSTMD.basalSTMD_Core(self);
            
            % init kernel
            self.init_W_e();
            self.init_Gammakernel_in_feedbackSTMD();
            
            % allocate memory
            self.Cell_D_add_E = cell(self.Gammakernel_4_len, 1);           
        end
    end % end methods
    methods % The function body is outside the class function
        Lamina(self); % lamina layer
        Lobula(self); % lobula layer
    end % end methods
    
    
end

