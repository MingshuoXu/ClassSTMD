function Output = Cell_Conv_N_1(Input, Kernal, head_pointer)
    % Input: a cell where each element has the same dimension
    % Kernal: a vector
    % head_pointer: head pointer of Input
    k1 = length(Input);
    if ~exist('head_pointer','var')
        % 设置头指针为了节省其他步骤的存储矩阵的计算用时
        head_pointer = k1;
    end
    Kernal = squeeze(Kernal);
    if ~isvector(Kernal)
        error('The Kernel must be a vector! ');
    end
    
    k2 = length(Kernal);
    len = min(k1,k2);
    if isempty(Input{head_pointer})
        return
    else
        Output = zeros(size(Input{head_pointer}));
    end
    
    for t = 1:len
        j = mod(head_pointer-t, k1);
        if abs(Kernal(t)) > 1e-16 && ~isempty(Input{j+1})
            % mod后的取值范围最小为0，
            % 但是MATLAB的数组下标从1开始，因此统一加1
            Output = Output + Input{j+1} * Kernal(t);
        end
    end
    
end