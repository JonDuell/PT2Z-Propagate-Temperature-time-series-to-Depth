function ModelData = PT2Z_3_AutoFill_PT2Z_4(ModelData)
%%
clc
fprintf('----------------------- Running PT2Z_3 ------------------------\n')

fprintf('[PT2Z_3] Calculating auto inputs to the rest of the script....\n')
%%
ModelData.Auto_Fill_Data.UserChosenData.Chosen_Dataset = ModelData.InputOBT.DateProcessing.SortByYear(ModelData.Auto_Fill_Data.UserChosenData.Y);

ChosenData =  ModelData.Auto_Fill_Data.UserChosenData.Chosen_Dataset.Table_Data;

fprintf(' \n')
ModelData.Auto_Fill_Data.OBT_Derived.Year = ModelData.Auto_Fill_Data.UserChosenData.Chosen_Dataset.Year;         % The year you are looking at in format (YYYY)
ModelData.Auto_Fill_Data.OBT_Derived.t1 = ChosenData{1,1};
ModelData.Auto_Fill_Data.OBT_Derived.t2 = ChosenData{end,1};
ModelData.Auto_Fill_Data.OBT_Derived.MinTemp_date = ChosenData{find(ChosenData{:,2} == min(ChosenData{:,2})),1};
ModelData.Auto_Fill_Data.OBT_Derived.Minday = abs(datenum(ModelData.Auto_Fill_Data.OBT_Derived.t1)-datenum(ModelData.Auto_Fill_Data.OBT_Derived.MinTemp_date)); % The day the minimum temperature was recorded

ModelData.Auto_Fill_Data.OBT_Derived.MinTemp = round(min(ChosenData{:,2}),2,'significant');        % The    min of temperature variation throughout the year
ModelData.Auto_Fill_Data.OBT_Derived.MaxTemp = round(max(ChosenData{:,2}),2,'significant');   % The max of temperature variation throughout the year
ModelData.Auto_Fill_Data.OBT_Derived.MeanTemp = round(mean(ChosenData{:,2}),2,'significant');  % The mean of temperature variation throughout the year 
%% Set the output 
fprintf('[PT2Z_3] Auto inputs for the rest of the script calculated\n')
fprintf('[PT2Z_3] The following auto inputs were derived From: %s year %g\n',ModelData.InputOBT.OBTTimeSeries_FileName,ModelData.Auto_Fill_Data.UserChosenData.Chosen_Dataset.Year)
fprintf(' \n')
fprintf('         Year: %g\n',ModelData.Auto_Fill_Data.OBT_Derived.Year)
fprintf('           t1: %s\n',ModelData.Auto_Fill_Data.OBT_Derived.t1)
fprintf('           t2: %s\n',ModelData.Auto_Fill_Data.OBT_Derived.t2)
fprintf(' MinTemp_Date: %s\n',ModelData.Auto_Fill_Data.OBT_Derived.MinTemp_date)
fprintf('       Minday: %g\n',ModelData.Auto_Fill_Data.OBT_Derived.Minday)
fprintf('      MinTemp: %g\n',ModelData.Auto_Fill_Data.OBT_Derived.MinTemp)
fprintf('      MaxTemp: %g\n',ModelData.Auto_Fill_Data.OBT_Derived.MaxTemp)
fprintf('     MeanTemp: %g\n',ModelData.Auto_Fill_Data.OBT_Derived.Year)
fprintf(' \n')
fprintf('----------------------- PT2Z_3 Finished ------------------------\n')
fprintf('[USER] To use these values as inputs to section 4, set the flag on line 116 to 1\n')

end