%close all;
function plot_ROC(Folder_name,t1,t2,Error_Threshold,save_path)
import ClassSTMD.*;

if nargin < 2
    t1 = 200;
end
if nargin < 3
    t2 = 450;
end
if nargin < 4
    Error_Threshold = 5;
end

if t1>t2
    error('EndFrame < StartFrame, error! \n');
end

path0 = Folder_name.Data_Folder;

% main
load([path0,'\INDEX.mat']);
path1 = [path0(1:15),'\result',path0(16:end)];
if nargin < 5%~exist(save_path,'var')
    save_path = path1;
end

file = dir([path1,'\*.mat']);
close all;
figure(111111);
hold on;
fig_legend = cell(length(file),1);

if t2 > size(index,1) %#ok<*NODEF>
    t2 = size(index,1);
    if t2 - t1 < 100
        t1 = max(t2-100,1);
    end
end

for i = 1:length(file)
    load([path1,'\',file(i).name]);
    if strcmp(file(i).name(1:5),'ESTMD')
        [Detection_rate_E,False_drop_rate_E,~] = ...
            ROC(ESTMD.Matrix_Output(:,:,t1:t2),index(t1:t2,:),Error_Threshold);
        plot(False_drop_rate_E,Detection_rate_E,'b-o');
    elseif strcmp(file(i).name(1:6),'fESTMD')
        [Detection_rate_F,False_drop_rate_F,~] = ...
            ROC(fESTMD.Matrix_Output(:,:,t1:t2),index(t1:t2,:),Error_Threshold);
        plot(False_drop_rate_F,Detection_rate_F,'--',...
        'Color',[i/length(file),i/length(file),1-i/length(file)]);
    end
    fig_legend{i} = file(i).name;
end
    temp = strsplit(path1,'\');
    fig_title = temp{end};
    title(fig_title);
    set(gca,'YLim',[0,1]);
    grid on;
    hold off;
    legend(fig_legend,'Location','southeast')
    legend('boxoff')
    
    savefig([save_path,'\ROC_',num2str(t1),'_',num2str(t2),'.fig']);
end

