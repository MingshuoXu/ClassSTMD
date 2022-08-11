function RecondOutput(self)
    %RecondOutput recond output
    self.Matrix_Output(:,:,self.NowFrame) = max(self.Lobula_Output,[],3);
    self.Matrix_Direction(:,:,self.NowFrame) = self.Direction;
end

