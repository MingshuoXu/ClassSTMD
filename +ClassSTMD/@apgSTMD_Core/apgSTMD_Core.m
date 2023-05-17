classdef apgSTMD_Core < ClassSTMD.STMDplus_Core
    %DSTMD_Core Directional Small Target Motion Detectors
    %
    %	api:
    %	addpath('[the parent folder of ClassSTMD]');
    %	import ClassSTMD.*;
    %	obj = apgSTMD_Core();
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
    %   * H. Wang, J. Zhao, H. Wang, C. Hu, J. Peng, S. Yue, Attention
    %   and prediction-guided motion detection for low-contrast small
    %   moving targets, IEEE Transactions on Cybernetics.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-29
    
    properties
        alpha = 1;
        kappa = 0.02;
        mu = 0.25;
        beta = 1;
        apg_Delta_t = 25;
    end
    properties(Hidden)
       Attention_Kernal;
       Prediction_Kernal;
       P_e;
       Cell_P_e;
       h_pointer_P_e = 0;
       Prediction_map;
       Cell_Prediction_map;
       Prediction_gain;
       Facilitated_STMD_Output;
       Cell_Prediction_gain;
       Time_Attenuation;
    end 
    
    methods
        % Constructor function
        function self = apgSTMD_Core()
            self = self@ClassSTMD.STMDplus_Core();
        end
        % Some initialization kernel function
        
        % Initialize function
        function Init(self)
            % Initialization of inherited functions
            Init@ClassSTMD.STMDplus_Core(self);
            % Regenerate the inhibitory Kernel
            self.InhibitionKernel_W2 = ...
                ClassSTMD.ToolFun.Generalize_Lateral_InhibitionKernel_W2(...
                15, 1.25, 2.5, 1.2, 0, 1, 3.5);
            % init kernel
            self.Attention_Kernal...
                = ClassSTMD.ToolFun.Generalize_Attention_Kernal();
            self.Prediction_Kernal...
                = ClassSTMD.ToolFun.Generalize_Prediction_Kernal();
            self.Time_Attenuation...
                = exp( self.kappa*( -self.apg_Delta_t+1:0 ) );
            % allocate memory
            self.Cell_P_e = cell(self.LMCs_len, 1);
            self.Prediction_map = zeros(self.IMAGE_H, self.IMAGE_W);
            self.Prediction_gain = ...
                cell(1, self.DSTMD_Directions);
            self.Cell_Prediction_gain = ...
                cell(self.apg_Delta_t, self.DSTMD_Directions);
            self.Cell_Prediction_map = cell(self.apg_Delta_t, 1);
        end
    end % end methods
    methods % The function body is outside the class function
        Attention_Module(self);
        Retina(self);
        Lamina(self);
        Lobula(self);
        Prediction_Module(self);
        Run(self);
    end % end methods
    
    
end

