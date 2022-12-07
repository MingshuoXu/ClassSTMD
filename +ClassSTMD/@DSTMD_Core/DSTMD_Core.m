classdef DSTMD_Core < ClassSTMD.basalSTMD_Core
    %DSTMD_Core Directional Small Target Motion Detectors
    %
    %    api:
    %    addpath('[the parent folder of ClassSTMD]');
    %    import ClassSTMD.*;
    %    obj = DSTMD_Core();
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
    %   * Wang H, Peng J, Yue S. A directionally selective small target
    %   motion detecting visual neural network in cluttered backgrounds[J].
    %   IEEE transactions on cybernetics, 2018, 50(4): 1541-1555.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-11
    
    properties
        DSTMD_Directions = 8;
        DSTMD_Dist = 3;
    end
    properties(Hidden)
        Gammakernel_1_Order = 2;
        Gammakernel_1_Tau = 3;
        Gammakernel_2_Order = 6;
        Gammakernel_2_Tau = 9;
        Gammakernel_1_len;
        Gammakernel_2_len;
        
        Gammakernel_4_Order = 3;
        Gammakernel_4_Tau = 15;
        Gammakernel_5_Order = 5;
        Gammakernel_5_Tau = 25;
        Gammakernel_6_Order = 8;
        Gammakernel_6_Tau = 40;
        Gammakernel_4_len;
        Gammakernel_5_len;
        Gammakernel_6_len;
        Gammakernel_4;
        Gammakernel_5;
        Gammakernel_6;
        
        Lamina_Filter;
        Lamina_Inhibition;
        
        DSTMD_Directional_Inhibition_Kernel;
        Delay_ON_Channel;
        Delay_OFF_Channel_1;
        Delay_OFF_Channel_2;
        
    end
    
    methods
        % Constructor function
        function self = DSTMD_Core()
            self = self@ClassSTMD.basalSTMD_Core();
            self.Lamina_Inhibition = ClassSTMD.Lamina_Lateral_Inhibition();
        end
        % Some initialization kernel function
        function init_Gammakernel_in_DSTMD(self)
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
            self. Gammakernel_5 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Gammakernel_5_Order,...
                self.Gammakernel_5_Tau,...
                self.Gammakernel_5_len);
            self. Gammakernel_6 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Gammakernel_6_Order,...
                self.Gammakernel_6_Tau,...
                self.Gammakernel_6_len);
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
            if isempty(self.Gammakernel_5_len)
                self.Gammakernel_5_len = 3 * self.Gammakernel_5_Tau;
            end
            if isempty(self.Gammakernel_6_len)
                self.Gammakernel_6_len = 3 * self.Gammakernel_6_Tau;
            end
            
            % Initialization of inherited functions
            Init@ClassSTMD.basalSTMD_Core(self);
            % init kernel
            self.init_Gammakernel_in_DSTMD();
            self.DSTMD_Directional_Inhibition_Kernel = ...
                ClassSTMD.ToolFun.Generalize_DSTMD_Directional_InhibitionKernel();
            % Regenerate the inhibitory Kernel
            self.InhibitionKernel_W2 = ...
                ClassSTMD.ToolFun.Generalize_Lateral_InhibitionKernel_W2(...
                15, 1.25, 2.5, 1.2, 0, 1, 3.5);
            % allocate memory
            self.Cell_ON_Channel = cell(self.Gammakernel_4_len, 1);
            self.Cell_OFF_Channel...
                = cell(max(self.Gammakernel_5_len,self.Gammakernel_6_len), 1);
            [self.Correlation_Output,self.Lateral_Inhibition_Output,...
                self.Lobula_Output] = ...
                deal(zeros(self.IMAGE_H,self.IMAGE_W,self.DSTMD_Directions ));
        end
    end % end methods
    
    methods % The function body is outside the class function
        Lamina(self); % lamina layer
        Lobula(self); % lobula layer
        Visualize(self);
        RecordOutput(self);
    end % end methods
    
    methods(Static)
        function Output = Directional_Inhibition(Input, Kernel)
            Kernel = squeeze(Kernel);
            if ~isvector(Kernel)
                error('the Kernel is not a vector');
            end
            
            len_1 = size(Input,3);
            len_2 = length(Kernel);
            if mod(len_2,2) == 0
                error('The kernel must have an even number of elements');
            end
            
            certer = ceil(len_2/2);
            
            RR = min( floor(len_1/2), certer-1 );
            if mod(len_1,2) ~= 0
                LL = - RR;
            else
                LL = - RR + 1;
            end
            
            Output = zeros(size(Input));
            for i = 1:len_1
                for j = LL : RR
                    k = mod(i-j,len_1);
                    if k == 0
                        k = len_1;
                    end
                    Output(:,:,i)...
                        = Output(:,:,i) ...
                        + Input(:,:,k) * Kernel(j+certer);
                end
            end
            
        end
        
        function Output = Calculate_Direction(Input)  
            [m,n,kk] = size(Input);
            [Output_cos,Output_sin] = deal(zeros(m,n));
            for i = 1:kk
                Output_cos = Output_cos + Input(:,:,i)*cos((i-1)*2*pi/kk);
                Output_sin = Output_sin + Input(:,:,i)*sin((i-1)*2*pi/kk);
            end
            Output = atan2(Output_sin, Output_cos);
            Output = Output + pi;
        end
    end
    
end

