classdef ToolFun < handle
    %TOOLFUN �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    methods(Static)
        % ��ľ�̬�������޷��������һ�����Ժͷ���
        function Gamma = Generalize_Gammakernel(Order,Tau,wide)
            % �������������һ����ɢ����Gamma����,�Ա��� t ��ȡֵ����Ϊ[0��Wide-1]��һ��Wide��ֵ��
            % ע�⣬�������ɵĺ˲�����ϵͳ��conv��������Ϊ����ĺ˲��ǶԳƵ�
            
            % ����˵����
            % wideΪ�������ȣ�  Tau��OrderΪGamma�����Ĳ�����
            if wide <= 1
                wide = 2;
            end
            Gamma=zeros(1, wide); % ��ʼ��
            for k = 1:wide
                t = k-1;
                Gamma(1,k) = (Order*t/Tau)^Order * exp(-Order*t/Tau) / ...
                    (factorial(Order-1)*Tau);
            end
            Gamma = Gamma / sum(Gamma(:)); %��һ��
        end
        
        function kernel_F = Generalize_FractionalDerivativeKernel(alpha,wide)
            % �������������һ����ɢ����Gamma����,�Ա��� t ��ȡֵ����Ϊ[0��Wide-1]��һ��Wide��ֵ��
            % ע�⣬�������ɵĺ˲�����ϵͳ��conv��������Ϊ����ĺ˲��ǶԳƵ�
            %����˵����wideΪ�������ȣ�  Tau��OrderΪGamma�����Ĳ�����
            if wide < 2
                wide = 2;
            end
            kernel_K = zeros(1, wide-1); %��ʼ��
            kernel_F = zeros(1, wide);
            if alpha == 1
                kernel_K(1) = 1;
            elseif alpha > 0 && alpha < 1
                for k = 1:wide-1
                    t = k-1;
                    kernel_K(1,k) = exp(-alpha*t/(1-alpha)) / (1-alpha);
                end
                kernel_K = kernel_K / sum(kernel_K); %��һ��
            else
                error('ֻ����alpha��(0,1]֮��');
            end
            % �Ծ����kernel_K���
            kernel_F(1) = kernel_K(1);
            kernel_F(2:end-1) = kernel_K(2:end) - kernel_K(1:end-1);
            kernel_F(end) = - kernel_K(end);
        end
        
        function ESTMD_InhibitionKernel = ...
                Generalize_ESTMD_Lateral_InhibitionKernel(...
                KernelSize,Sigma1,Sigma2,e,rho,A,B)
            % ����˵��
            % �ú����������� DSTMD �Ĳ������ƾ����, DoG ��ʽ
            % W(x,y) = A*[g_1(x,y)] - B[-g_1(x,y)]    % [x]   max(x,0)
            % g_1 = G_1(x,y) - e*G_2(x,y) - rho
            
            % ����˵��
            % KernelSize  Inhibition Kernel �Ĵ�С��һ��Ϊ����
            % Sigma1      Gauss ���� 1 �� Sigma
            % Sigma2      Gauss ���� 2 �� Sigma
            % e           ���� e
            
            % Author: Hongxin Wang
            % Date: 2021-05-13
            % LastEdit: Mingshuo Xu
            % LastEditTime: 2022-07-11 
            %% ----------------------------------------------%
            % DoG
            if nargin < 1
                KernelSize = 15;
            end
            % �������СΪ size 5*5 pixels ʱ�����Ų�����1.5��3.0��
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
            % ������˴�С����Ϊ����
            if mod(KernelSize,2) == 0
                KernelSize = KernelSize + 1;
            end
            % ȷ������˵�����
            CenX = round(KernelSize/2);
            CenY = round(KernelSize/2);
            % ��������
            [X,Y] = meshgrid(1:KernelSize,1:KernelSize);
            % ����ƽ��
            ShiftX = X-CenX;
            ShiftY = Y-CenY;
            % ���� Gauss ���� 1 �� 2
            Gauss1 = (1/(2*pi*Sigma1^2))*exp(-(ShiftX.*ShiftX + ShiftY.*ShiftY)/(2*Sigma1^2));
            Gauss2 = (1/(2*pi*Sigma2^2))*exp(-(ShiftX.*ShiftX + ShiftY.*ShiftY)/(2*Sigma2^2));
            % ���� DoG, ����˹�������
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
            
            % ����˵��
            % �ú��������������� Theta ����Ĳ����ƺ�
            % �������������һά DoG ��Ϊ�����ƺ˺���
            
            %% Parameter Setting
            
            if ~exist('DSTMD_Directions','var')
                DSTMD_Directions = 8;
                % ����ӦΪ 4*k   k=1,2,3,4,5,6...
            end
            
            if ~exist('Sigma1','var')
                Sigma1 = 1.5;
            end
            
            if ~exist('Sigma2','var')
                Sigma2 = 3.0;
            end
            
            KernelSize = DSTMD_Directions;
            
            %% �� DoG ���в���
            
            % ���� DoG ȡֵΪ���������
            Zero_Point_DoG_X1 = ...
                -sqrt((log(Sigma2/Sigma1)*2*Sigma1^2*Sigma2^2)...
                /(Sigma2^2-Sigma1^2));
            Zero_Point_DoG_X2 = -Zero_Point_DoG_X1;
            % ���� DoG ȡ��Сֵ��������
            Min_Point_DoG_X1 = ...
                -sqrt((3*log(Sigma2/Sigma1)*2*Sigma1^2*Sigma2^2)...
                /(Sigma2^2-Sigma1^2));
            Min_Point_DoG_X2 = -Min_Point_DoG_X1;
            
            % ������˴�С����Ϊ����
            if mod(KernelSize,2) == 0
                KernelSize = KernelSize +1;
            end
            
            Half_Kernel_Size = (KernelSize-1)/2;
            Quarter_Kernel_Size = (KernelSize-1)/4;
            % �������� (>0 ����) �������
            Center_Range_DoG = Zero_Point_DoG_X2-Zero_Point_DoG_X1;
            Center_Step = Center_Range_DoG/Half_Kernel_Size;
            % ��Χ���� (<0 ����) �������
            Surround_Range_DoG = Min_Point_DoG_X2-Zero_Point_DoG_X2;
            Surround_Step = 2*Surround_Range_DoG/Quarter_Kernel_Size;
            % ������Χ����
            X_Smaller = Zero_Point_DoG_X1-(Quarter_Kernel_Size:-1:1)*Surround_Step;
            X_Larger = Zero_Point_DoG_X2+(1:Quarter_Kernel_Size)*Surround_Step;
            X_Center = Zero_Point_DoG_X1+(0:Half_Kernel_Size)*Center_Step;
            X = [X_Smaller,X_Center,X_Larger];
            % ����
            Gauss1 = (1/(sqrt(2*pi)*Sigma1))*exp(-(X.^2)/(2*Sigma1^2));
            Gauss2 = (1/(sqrt(2*pi)*Sigma2))*exp(-(X.^2)/(2*Sigma2^2));
            
            Inhibition_Kernel = Gauss1 - Gauss2;
            
            %Inhibition_Kernel = Inhibition_Kernel(1:DSTMD_Directions);
            DSTMD_Directional_Inhibition_Kernel = reshape(Inhibition_Kernel,[1 1 KernelSize]);
        end
        
        function DSTMD_InhibitionKernel = ...
                Generalize_DSTMD_Lateral_InhibitionKernel(...
                KernelSize,Sigma1,Sigma2,e,rho,A,B)
            
            % ����˵��
            % �ú����������� DSTMD �Ĳ������ƾ����, DoG ��ʽ
            % W(x,y) = A*[g_1(x,y)] - B[-g_1(x,y)]    % [x]   max(x,0)
            % g_1 = G_1(x,y) - e*G_2(x,y) - rho
            
            % ����˵��
            % KernelSize  Inhibition Kernel �Ĵ�С��һ��Ϊ����
            % Sigma1      Gauss ���� 1 �� Sigma
            % Sigma2      Gauss ���� 2 �� Sigma
            % e           ���� e
            
            %% ----------------------------------------------%
            % DoG
            if ~exist('KernelSize','var')
                KernelSize = 15;
            end
            
            % �������СΪ size 5*5 pixels ʱ�����Ų�����1.5��3.0��
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
            
            
            % ������˴�С����Ϊ����
            Flag = mod(KernelSize,2);
            if Flag == 0
                KernelSize = KernelSize +1;
            end
            
            % ȷ������˵�����
            CenX = round(KernelSize/2);
            CenY = round(KernelSize/2);
            % ��������
            [X,Y] = meshgrid(1:KernelSize,1:KernelSize);
            % ����ƽ��
            ShiftX = X-CenX;
            ShiftY = Y-CenY;
            
            % ���� Gauss ���� 1 �� 2
            Gauss1 = (1/(2*pi*Sigma1^2))...
                * exp(-(ShiftX.*ShiftX + ShiftY.*ShiftY)/(2*Sigma1^2));
            Gauss2 = (1/(2*pi*Sigma2^2))...
                * exp(-(ShiftX.*ShiftX + ShiftY.*ShiftY)/(2*Sigma2^2));
            
            % ���� DoG, ����˹�������
            DoG_Filter = Gauss1 - e*Gauss2 - rho;
            
            % max(x,0)
            Positive_Component = (abs(DoG_Filter) + DoG_Filter)*0.5;
            Negative_Component = (abs(DoG_Filter) - DoG_Filter)*0.5;
            % Inhibition Kernel
            
            DSTMD_InhibitionKernel = A*Positive_Component - B*Negative_Component;
            
        end
        
        function Output = Conv_3(Input,Kernal)
            % �ر�ע�⣬����������ά���󣬵��Ƿ���ֵֻ�ж�ά������
            % ��ά�����ʱ��ά�ȵľ������ʡ�ڴ��ʵ�ַ����������convn��
            % ֻ�Ƽ�����Input(:,:,end)�ľ�������������Ҫ�õ�������Input(:,:,t)
            % ע�⵽�����Kernal��������MATLAB�еĳߴ���1*k2��
            % Input(:,:,end)��ӦKernal��1); Input(:,:,end-1)��ӦKernal��2)...
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

