function RecordOutput(self)
    %RECORDOUTPUT The function to record output
    self.Cell_Output{self.NowFrame} = self.Lobula_Output; 
end

