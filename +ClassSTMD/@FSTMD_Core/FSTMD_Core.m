classdef FSTMD_Core < ClassSTMD.basalSTMD_Core
    %FSTMD_Core  base Small Target Motion Detectors
    %
    %    api:
    %    addpath('[the parent folder of ClassSTMD]');
    %    import ClassSTMD.*;
    %    obj = FSTMD_Core();
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
    %   * Ling J, Wang H, Xu M, et al. Mathematical Study of Neural 
    %   Feedback Roles in Small Target Motion Detection[J]. Frontiers 
    %   in Neurorobotics, 203.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-09-20
    %   LastEditTime: 2022-09-22  
     
    properties
        a = 0.22;
        Iterative_threshold = 1e-3;
        max_count = 100;
    end
    properties(Hidden)
        Gammakernel_1_Order = 2;
        Gammakernel_1_Tau   = 3;
        Gammakernel_2_Order = 6;
        Gammakernel_2_Tau   = 9;
        Gammakernel_1_len;
        Gammakernel_2_len;
        
        Gammakernel_4_Order = 5;
        Gammakernel_4_Tau   = 10;
        Gammakernel_4_len;
        Gammakernel_4;
        
        Lamina_Filter;
        
        Time_Delay_Feedback;
        Cell_Lobula_Output;
        
        count;
    end
    
    methods
        function self = FSTMD_Core()
            self = self@ClassSTMD.basalSTMD_Core();
            self.Gammakernel_3_Order = 5;
            self.Gammakernel_3_Tau = 25;
        end
        % Some initialization kernel function
        function init_Gammakernel_in_FSTMD(self)
            self.Lamina_Filter = ClassSTMD.Gamma_Filter(...
                self.Gammakernel_1_Order,...
                self.Gammakernel_1_Tau,...
                self.Gammakernel_1_len,...
                self.Gammakernel_2_Order,...
                self.Gammakernel_2_Tau,...
                self.Gammakernel_2_len  );
            self.Gammakernel_4 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Gammakernel_4_Order,...
                self.Gammakernel_4_Tau,...
                self.Gammakernel_4_len);
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
                self.LMCs_len = max(self.Gammakernel_1_len,self.Gammakernel_2_len);
            end
            if isempty(self.Gammakernel_4_len)
                self.Gammakernel_4_len = 3 * self.Gammakernel_4_Tau;
            end
            
            % Initialization of inherited functions
            Init@ClassSTMD.basalSTMD_Core(self);
            % init kernel
            self.init_Gammakernel_in_FSTMD();
            % allocate memory
            self.Cell_Lobula_Output = cell(self.Gammakernel_4_len ,1);
        end

    end
    methods
        Feedback_Pathway(self);
        Lamina(self)
        Medulla(self);
        Lobula(self);
        Run(self);
    end
    
end

