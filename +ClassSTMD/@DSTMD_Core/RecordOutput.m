function RecordOutput(self)
    %RecordOutput Record output
    self.Cell_Output{self.NowFrame} = self.Output;
    self.Cell_Direction{self.NowFrame} = self.Direction;
end

