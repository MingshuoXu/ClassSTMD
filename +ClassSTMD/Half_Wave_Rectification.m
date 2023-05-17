function Y = Half_Wave_Rectification(X)
    %Half_Wave_Rectification
    Y = (X+abs(X))/2;
    %the fastest approch: max(X,0) and -min(X,0)
end
