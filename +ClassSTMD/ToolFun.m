classdef ToolFun < handle
    %TOOLFUN 此处显示有关此类的摘要
    %   此处显示详细说明
    methods(Static)
        % 类的静态方法，无法访问类的一般属性和方法
        function Gamma = Generalize_Gammakernel(Order,Tau,wide)
            % 本函数用于输出一个离散化的Gamma向量,自变量 t 的取值区间为[0，Wide-1]，一个Wide个值。
            % 注意，这里生成的核不适用系统的conv函数，因为这里的核不是对称的
            
            % 参数说明：
            % wide为向量长度；  Tau和Order为Gamma函数的参数；
            if wide <= 1
                wide = 2;
            end
            Gamma=zeros(1, wide); % 初始化
            for k = 1:wide
                t = k-1;
                Gamma(1,k) = (Order*t/Tau)^Order * exp(-Order*t/Tau) / ...
                    (factorial(Order-1)*Tau);
            end
            Gamma = Gamma / sum(Gamma(:)); %归一化
        end
        
        function kernel_F = Generalize_FractionalDerivativeKernel(alpha,wide)
            % 本函数用于输出一个离散化的Gamma向量,自变量 t 的取值区间为[0，Wide-1]，一个Wide个值。
            % 注意，这里生成的核不适用系统的conv函数，因为这里的核不是对称的
            %参数说明：wide为向量长度；  Tau和Order为Gamma函数的参数；
            if wide < 2
                wide = 2;
            end
            kernel_K = zeros(1, wide-1); %初始化
            kernel_F = zeros(1, wide);
            if alpha == 1
                kernel_K(1) = 1;
            elseif alpha > 0 && alpha < 1
                for k = 1:wide-1
                    t = k-1;
                    kernel_K(1,k) = exp(-alpha*t/(1-alpha)) / (1-alpha);
                end
                kernel_K = kernel_K / sum(kernel_K); %归一化
            else
                error('只接受alpha在(0,1]之间');
            end
            % 对卷积核kernel_K差分
            kernel_F(1) = kernel_K(1);
            kernel_F(2:end-1) = kernel_K(2:end) - kernel_K(1:end-1);
            kernel_F(end) = - kernel_K(end);
        end
        
        function ESTMD_InhibitionKernel = ...
                Generalize_ESTMD_Lateral_InhibitionKernel(...
                KernelSize,Sigma1,Sigma2,e,rho,A,B)
            % 函数说明
            % 该函数用于生成 DSTMD 的侧面抑制卷积核, DoG 形式
            % W(x,y) = A*[g_1(x,y)] - B[-g_1(x,y)]    % [x]   max(x,0)
            % g_1 = G_1(x,y) - e*G_2(x,y) - rho
            
            % 参数说明
            % KernelSize  Inhibition Kernel 的大小，一般为奇数
            % Sigma1      Gauss 函数 1 的 Sigma
            % Sigma2      Gauss 函数 2 的 Sigma
            % e           参数 e
            
            % Author: Hongxin Wang
            % Date: 2021-05-13
            % LastEdit: Mingshuo Xu
            % LastEditTime: 2022-07-11 
            %% ----------------------------------------------%
            % DoG
            if nargin < 1
                KernelSize = 15;
            end
            % 当物体大小为 size 5*5 pixels 时的最优参数（1.5，3.0）
            if nargin < 2
                Sigma1 = 1.25;
            end
            if nargin < 3
                Sigma2 = 2.5;
            end
            if nargin < 4
                e = 1.2;
            end
            if nargin < 5
                rho = 0;
            end
            if nargin < 6
                A = 1;
            end
            if nargin < 7
                B = 3.5;
            end
            % 将卷积核大小设置为奇数
            if mod(KernelSize,2) == 0
                KernelSize = KernelSize + 1;
            end
            % 确定卷积核的中心
            CenX = round(KernelSize/2);
            CenY = round(KernelSize/2);
            % 生成网格
            [X,Y] = meshgrid(1:KernelSize,1:KernelSize);
            % 网格平移
            ShiftX = X-CenX;
            ShiftY = Y-CenY;
            % 生成 Gauss 函数 1 和 2
            Gauss1 = (1/(2*pi*Sigma1^2))*exp(-(ShiftX.*ShiftX + ShiftY.*ShiftY)/(2*Sigma1^2));
            Gauss2 = (1/(2*pi*Sigma2^2))*exp(-(ShiftX.*ShiftX + ShiftY.*ShiftY)/(2*Sigma2^2));
            % 生成 DoG, 两高斯函数相减
            DoG_Filter = Gauss1 - e*Gauss2 - rho;
            % max(x,0)
            Positive_Component = max(DoG_Filter,0);
            Negative_Component = max(-DoG_Filter,0);
            % Inhibition Kernel
            ESTMD_InhibitionKernel = A*Positive_Component - B*Negative_Component;
            
        end
        
        function DSTMD_Directional_Inhibition_Kernel = ...
                Generalize_DSTMD_Directional_InhibitionKernel(...
                DSTMD_Directions,Sigma1,Sigma2)
            
            % 函数说明
            % 该函数用于生成沿着 Theta 方向的侧抑制核
            % 我们在这里采用一维 DoG 作为侧抑制核函数
            
            %% Parameter Setting
            
            if ~exist('DSTMD_Directions','var')
                DSTMD_Directions = 8;
                % 方向应为 4*k   k=1,2,3,4,5,6...
            end
            
            if ~exist('Sigma1','var')
                Sigma1 = 1.5;
            end
            
            if ~exist('Sigma2','var')
                Sigma2 = 3.0;
            end
            
            KernelSize = DSTMD_Directions;
            
            %% 对 DoG 进行采样
            
            % 计算 DoG 取值为零的两个点
            Zero_Point_DoG_X1 = ...
                -sqrt((log(Sigma2/Sigma1)*2*Sigma1^2*Sigma2^2)...
                /(Sigma2^2-Sigma1^2));
            Zero_Point_DoG_X2 = -Zero_Point_DoG_X1;
            % 计算 DoG 取最小值的两个点
            Min_Point_DoG_X1 = ...
                -sqrt((3*log(Sigma2/Sigma1)*2*Sigma1^2*Sigma2^2)...
                /(Sigma2^2-Sigma1^2));
            Min_Point_DoG_X2 = -Min_Point_DoG_X1;
            
            % 将卷积核大小设置为奇数
            if mod(KernelSize,2) == 0
                KernelSize = KernelSize +1;
            end
            
            Half_Kernel_Size = (KernelSize-1)/2;
            Quarter_Kernel_Size = (KernelSize-1)/4;
            % 中心区域 (>0 部分) 采样间隔
            Center_Range_DoG = Zero_Point_DoG_X2-Zero_Point_DoG_X1;
            Center_Step = Center_Range_DoG/Half_Kernel_Size;
            % 周围区域 (<0 部分) 采样间隔
            Surround_Range_DoG = Min_Point_DoG_X2-Zero_Point_DoG_X2;
            Surround_Step = 2*Surround_Range_DoG/Quarter_Kernel_Size;
            % 采样范围整合
            X_Smaller = Zero_Point_DoG_X1-(Quarter_Kernel_Size:-1:1)*Surround_Step;
            X_Larger = Zero_Point_DoG_X2+(1:Quarter_Kernel_Size)*Surround_Step;
            X_Center = Zero_Point_DoG_X1+(0:Half_Kernel_Size)*Center_Step;
            X = [X_Smaller,X_Center,X_Larger];
            % 采样
            Gauss1 = (1/(sqrt(2*pi)*Sigma1))*exp(-(X.^2)/(2*Sigma1^2));
            Gauss2 = (1/(sqrt(2*pi)*Sigma2))*exp(-(X.^2)/(2*Sigma2^2));
            
            Inhibition_Kernel = Gauss1 - Gauss2;
            
            %Inhibition_Kernel = Inhibition_Kernel(1:DSTMD_Directions);
            DSTMD_Directional_Inhibition_Kernel = reshape(Inhibition_Kernel,[1 1 KernelSize]);
        end
        
        function DSTMD_InhibitionKernel = ...
                Generalize_DSTMD_Lateral_InhibitionKernel(...
                KernelSize,Sigma1,Sigma2,e,rho,A,B)
            
            % 函数说明
            % 该函数用于生成 DSTMD 的侧面抑制卷积核, DoG 形式
            % W(x,y) = A*[g_1(x,y)] - B[-g_1(x,y)]    % [x]   max(x,0)
            % g_1 = G_1(x,y) - e*G_2(x,y) - rho
            
            % 参数说明
            % KernelSize  Inhibition Kernel 的大小，一般为奇数
            % Sigma1      Gauss 函数 1 的 Sigma
            % Sigma2      Gauss 函数 2 的 Sigma
            % e           参数 e
            
            %% ----------------------------------------------%
            % DoG
            if ~exist('KernelSize','var')
                KernelSize = 15;
            end
            
            % 当物体大小为 size 5*5 pixels 时的最优参数（1.5，3.0）
            if ~exist('Sigma1','var')
                Sigma1 = 1.25;
            end
            
            if ~exist('Sigma2','var')
                Sigma2 = 2.5;
            end
            
            if ~exist('e','var')
                e = 1.2;
            end
            
            if ~exist('rho','var')
                rho = 0;
            end
            
            if ~exist('A','var')
                A = 1;
            end
            
            if ~exist('B','var')
                B = 3.5;
            end
            
            
            % 将卷积核大小设置为奇数
            Flag = mod(KernelSize,2);
            if Flag == 0
                KernelSize = KernelSize +1;
            end
            
            % 确定卷积核的中心
            CenX = round(KernelSize/2);
            CenY = round(KernelSize/2);
            % 生成网格
            [X,Y] = meshgrid(1:KernelSize,1:KernelSize);
            % 网格平移
            ShiftX = X-CenX;
            ShiftY = Y-CenY;
            
            % 生成 Gauss 函数 1 和 2
            Gauss1 = (1/(2*pi*Sigma1^2))...
                * exp(-(ShiftX.*ShiftX + ShiftY.*ShiftY)/(2*Sigma1^2));
            Gauss2 = (1/(2*pi*Sigma2^2))...
                * exp(-(ShiftX.*ShiftX + ShiftY.*ShiftY)/(2*Sigma2^2));
            
            % 生成 DoG, 两高斯函数相减
            DoG_Filter = Gauss1 - e*Gauss2 - rho;
            
            % max(x,0)
            Positive_Component = (abs(DoG_Filter) + DoG_Filter)*0.5;
            Negative_Component = (abs(DoG_Filter) - DoG_Filter)*0.5;
            % Inhibition Kernel
            
            DSTMD_InhibitionKernel = A*Positive_Component - B*Negative_Component;
            
        end
        
        function Output = Conv_3(Input,Kernal)
            % 特别注意，这里输入三维矩阵，但是返回值只有二维！！！
            % 三维矩阵对时间维度的卷积，节省内存的实现方法（相对于convn）
            % 只计及返回Input(:,:,end)的卷积，但这个过程要用到其他的Input(:,:,t)
            % 注意到这里的Kernal是向量（MATLAB中的尺寸是1*k2）
            % Input(:,:,end)对应Kernal（1); Input(:,:,end-1)对应Kernal（2)...
            [m,n,k1] = size(Input);
            k2 = size(Kernal,2);
            length = min(k1,k2);
            Output = zeros(m,n);
            for t = 1:length
                if abs(Kernal(t)) > 1e-16
                Output = Output + Input(:,:,k1+1-t) * Kernal(t);
                end
            end
        end
        
    end % methods(Static)
    
end

