classdef ToolFun < handle
    %TOOLFUN �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    methods(Static)
        % Static methods of a class that do not have access 
        % to general properties and methods of the class

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
        
        %Generalize_FractionalDifferenceKernel
        %{
        function varargout = Generalize_FractionalDifferenceKernel(alpha,wide)
            if wide < 2
                wide = 2;
            end
            kernel_K = zeros(1, wide); 
            kernel_F = zeros(1, wide+1);
            % Generalize Fractional Difference Kernel
            if alpha == 1
                kernel_K(1) = 1;
                sum_Kernel = 1;
            elseif 0 < alpha && alpha < 1
                for k = 1:wide
                    t = k-1;
                    kernel_K(1,k) = exp(-alpha*t/(1-alpha)) / (1-alpha);
                end
                sum_Kernel = 1/sum(kernel_K); % M(\alpha)
                kernel_K = kernel_K * sum_Kernel; % normalization
            else
                error('alpha must in the interval (0,1]. \n');
            end
            % difference for kernel_K
            kernel_F(1) = kernel_K(1);
            kernel_F(2:end-1) = kernel_K(2:end) - kernel_K(1:end-1);
            kernel_F(end) = - kernel_K(end);
            % output
            if nargout == 1
                varargout = {kernel_K};
            elseif nargout == 2
                varargout = {kernel_K, kernel_F};
            elseif nargout == 3
                varargout = {kernel_K, kernel_F, sum_Kernel};
            end
        end
        %}

        %Generalize_Lateral_InhibitionKernel_W2
        function InhibitionKernel_W2 = ...
                Generalize_Lateral_InhibitionKernel_W2(...
                KernelSize,Sigma1,Sigma2,e,rho,A,B)
            
            % �ú����������� DSTMD �Ĳ������ƾ����, DoG ��ʽ
            % W(x,y) = A*[g_1(x,y)] - B[-g_1(x,y)]    % [x]   max(x,0)
            % g_1 = G_1(x,y) - e*G_2(x,y) - rho
            %
            % ����˵��
            % KernelSize  Inhibition Kernel �Ĵ�С��һ��Ϊ����
            % Sigma1      Gauss ���� 1 �� Sigma
            % Sigma2      Gauss ���� 2 �� Sigma
            % e           ���� e
            %
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
                Sigma1 = 1.5;
            end
            if nargin < 3
                Sigma2 = 3;
            end
            if nargin < 4
                e = 1.0;
            end
            if nargin < 5
                rho = 0;
            end
            if nargin < 6
                A = 1;
            end
            if nargin < 7
                B = 3;
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
            InhibitionKernel_W2 = A*Positive_Component - B*Negative_Component;
            
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
        
        function Filters = Generalize_T1_Neural_Kernels(...
                W_T_FilterNum, FilterSize, Alpha, Sigma)
            % Ref: Construction and Evaluation of an Integrated Dynamical 
            % Model of Visual Motion Perception
            
            % ����˵��
            % �ú����������� STMDPlus �ĵ� T1 ��Ԫ�ľ����
            % ����Filter  = G(x-a*cos,y-a*sin)-G(x+a*cos,y+a*sin)
            
            % ����˵��
            % W_T_FilterNum     �˲�������
            % FilterSize        �˲��������ߴ�
            % Alpha             ��˹�����������˲������ĵľ���
            % Sigma             ��˹������ Sigma
            
            % ���ڴ�СΪ 5*5 �����壬
            % W_T_FilterNum = 4
            % FilterSize = 11
            % Sigma = 1.5
            % Alpha = 3
            
            %% Parameter Setting
            if nargin < 1
                W_T_FilterNum = 4;
            end
            if nargin < 2
                FilterSize = 11;
            elseif mod(FilterSize,2) == 0
                FilterSize = FilterSize + 1;
                %���˲�����СΪż������ǿ������Ϊ����
            end
            if nargin < 3
                Alpha = 3.0;
            end
            if nargin < 4
                Sigma = 1.5;
            end
            
            
            %% Main Function
            Theta = zeros(1,W_T_FilterNum);
            for i = 1:W_T_FilterNum
                Theta(i) = (i-1) * pi / W_T_FilterNum;
            end
            
            % ���ڴ洢���ɵ��˲���
            Filters = zeros(FilterSize,FilterSize,W_T_FilterNum);
            % ��������
            r = floor(FilterSize/2);
            [X,Y] = meshgrid(-r:r, -r:r);
            
            for k = 1:W_T_FilterNum
                % ȷ��������˹����������
                X1 = X - Alpha*cos(Theta(k));
                Y1 = Y - Alpha*sin(Theta(k));
                X2 = X + Alpha*cos(Theta(k));
                Y2 = Y + Alpha*sin(Theta(k));
                
                % ����������˹����
                Gauss1 = (1/(2*pi*Sigma^2))*(exp(-(X1.^2+Y1.^2)./(2*Sigma^2)));
                Gauss2 = (1/(2*pi*Sigma^2))*(exp(-(X2.^2+Y2.^2)./(2*Sigma^2)));
                
                % Filter = Gauss1 - Gauss2;
                Filters(:,:,k) = Gauss1 - Gauss2;
            end
            
        end
        
        function Attention_Kernal = Generalize_Attention_Kernal(...
                kernal_size, Zeta, Theta)
            %INIT_ATTENTION_KERNAL �˴���ʾ�йش˺�����ժҪ
            %   �˴���ʾ��ϸ˵��
            if nargin < 1
                kernal_size = 17;
            elseif mod(kernal_size,2) == 0
                kernal_size = kernal_size + 1;
            end
            if nargin < 2
                Zeta = [2, 2.5, 3, 3.5];
            end
            if nargin < 3
                Theta = [0, pi/4, pi/2, pi*3/4];
            end
            
            r = length(Zeta);
            s = length(Theta);
            
            Attention_Kernal = cell(r,s);
            
            Center = ceil(kernal_size/2);
            
            [Y,X] = meshgrid(1:kernal_size, 1:kernal_size);
            % ����ƽ��
            ShiftX = X-Center;
            ShiftY = Y-Center;
            % The plane coordinate system is the matrix coordinate system 
            % rotated 90 degrees counterclockwise.
            Theta = Theta + pi/2;
            
            for i = 1:r
                for j = 1:s
                    jj = mod(s-j+1,s)+1;
                    Attention_Kernal{i,jj} =  2 / pi / Zeta(i)^4                         ...
                        .* ( Zeta(i)^2 - (ShiftX*cos(Theta(j))+ShiftY*sin(Theta(j))).^2 ) ...
                        .* exp( -(ShiftX.^2+ShiftY.^2)/2/Zeta(i)^2 );
                end
            end

        end
        
        function Prediction_Kernal = Generalize_Prediction_Kernal(...
                Vel, Delta_t, filter_size, FilterNum, zeta, eta)
            
            if nargin < 1
                Vel = 0.25;
            end
            if nargin < 2
                Delta_t = 25;
            end
            if nargin < 3
                filter_size = 25;
            end
            if nargin < 4
                FilterNum = 8;
            end
            if nargin < 5
                zeta = 2;
            end
            if nargin < 6
                eta = 2.5;
            end
            
            Prediction_Kernal = cell(FilterNum, 1);
            [Prediction_Kernal{:}] = deal(zeros(filter_size, filter_size));
            Center = ceil(filter_size/2);
            
            [Y,X] = meshgrid(1:filter_size, 1:filter_size);
            % ����ƽ��
            ShiftX = X - Center;
            ShiftY = Y - Center;
              
            fai = atan2(ShiftY, ShiftX);   
            Delta_X =  Vel * Delta_t * cos(fai);
            Delta_Y =  Vel * Delta_t * sin(fai);
            
            for ii = 1:FilterNum
                temp = exp( ...
                    -((ShiftX-Delta_X).^2+(ShiftY-Delta_Y).^2)/2/zeta^2 ...
                    + eta * cos(fai-(FilterNum-ii+1)*2*pi/FilterNum ) ...
                    );
                temp(Center,Center) = 0;
                Prediction_Kernal{ii} = temp./ sum(temp(:));
            end

        end
        
        %Conv_3
        %{
        function Output = Conv_3(Input, Kernal, head_pointer)
            % �ر�ע�⣬����������ά���󣬵��Ƿ���ֵֻ�ж�ά������
            % ��ά�����ʱ��ά�ȵľ������ʡ��������ʵ�ַ����������convn��
            % ֻ�Ƽ�����Input(:,:,end)�ľ�������������Ҫ�õ�������Input(:,:,t)
            % ע�⵽�����Kernal��������MATLAB�еĳߴ���1*k2��
            % Input(:,:,end)��ӦKernal��1); Input(:,:,end-1)��ӦKernal��2)...


            [m,n,k1] = size(Input);
            if ~exist('head_pointer','var')
                % ����ͷָ��Ϊ�˽�ʡ��������Ĵ洢����ļ�����ʱ
                head_pointer = k1;
            end
            Kernal = squeeze(Kernal);
            if ~isvector(Kernal)
                error('The Kernel must be a vector! ');
            end

            k2 = length(Kernal);
            len = min(k1,k2);
            Output = zeros(m,n);

            for t = 1:len
                if abs(Kernal(t)) > 1e-16
                    j = mod(head_pointer-t, k1);
                    % mod���ȡֵ��Χ��СΪ0������MATLAB�������±��1��ʼ�����ͳһ��1
                    Output = Output + Input(:,:,j+1) * Kernal(t);
                end
            end

        end

        function Output = Conv_3_3(Input,Kernal)
            % �ر�ע�⣬����������ά���󣬵��Ƿ���ֵֻ�ж�ά������
            % ��ά�����ʱ�պ˵ľ������ʡ��������ʵ�ַ����������convn��
            % ֻ�Ƽ�����Input(:,:,end)�ľ�������������Ҫ�õ�������Input(:,:,t)
            % ע�⵽�����KernalҲ����ά��
            % Input(:,:,end)��ӦKernal��:,:,1); Input(:,:,end-1)��ӦKernal��:,:,2)...
            [m,n,k1] = size(Input);
            k2 = size(Kernal,3);
            length = min(k1,k2);
            Output = zeros(m,n);
            for t = 1:length
                Output = Output + conv2(Input(:,:,k1+1-t), Kernal(:,:,t), 'same');
            end
        end
        %}

    end % methods(Static)
    
end

