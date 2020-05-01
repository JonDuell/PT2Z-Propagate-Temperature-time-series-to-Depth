function ModelData = PT2Z_2_ProcessOBT_Data(ModelData)
%
clc
fprintf('----------------------- Running PT2Z_2 ------------------------\n')

fprintf('[PT2Z_2] Sorting the input OBT data into years....\n')
%% Sort out the OBT - Input data - defining the inportant variables:
ModelData.InputOBT.OBT_RawTable = readtable(ModelData.InputOBT.OBTTimeSeries_FileName);
ModelData.InputOBT.OBT_RawTable = ModelData.InputOBT.OBT_RawTable(:,[2,3]);
ModelData.InputOBT.DateProcessing.DateVector = datevec(table2array(ModelData.InputOBT.OBT_RawTable(:,1)));
ModelData.InputOBT.DateProcessing.DateStats.FirstDate = ModelData.InputOBT.OBT_RawTable{1,1};
ModelData.InputOBT.DateProcessing.DateStats.LastDate = ModelData.InputOBT.OBT_RawTable{end,1};
ModelData.InputOBT.DateProcessing.DateStats.TimeStep = sprintf('dt = %g Day', mean(days(diff(ModelData.InputOBT.OBT_RawTable{:,1}))));
ModelData.InputOBT.DateProcessing.UniqueYears = unique(ModelData.InputOBT.DateProcessing.DateVector(:,1),'rows','first');

%% Generate a figure
formatspec = 'Input OBT: %s starts %s and ends %s at a time step of %s';
Figure1 = figure('Name',sprintf(formatspec,ModelData.InputOBT.OBTTimeSeries_FileName,ModelData.InputOBT.DateProcessing.DateStats.FirstDate,...
    ModelData.InputOBT.DateProcessing.DateStats.LastDate,ModelData.InputOBT.DateProcessing.DateStats.TimeStep));
for y = 1:length(ModelData.InputOBT.DateProcessing.UniqueYears)    
ModelData.InputOBT.DateProcessing.SortByYear(y).Year = ModelData.InputOBT.DateProcessing.UniqueYears(y);
ModelData.InputOBT.DateProcessing.SortByYear(y).Table_Data = ModelData.InputOBT.OBT_RawTable(ModelData.InputOBT.DateProcessing.DateVector(:,1) == ModelData.InputOBT.DateProcessing.UniqueYears(y),:) ;
P = plot(ModelData.InputOBT.DateProcessing.SortByYear(y).Table_Data{:,1},ModelData.InputOBT.DateProcessing.SortByYear(y).Table_Data{:,2}); hold on 
xlabel('Date');
ylabel('Temperature ({\circ}C)');
leg{y} = sprintf('Y%g: %g',y,ModelData.InputOBT.DateProcessing.UniqueYears(y));
end
legend(leg,'Location','northeastoutside')


%% Auto Save the figure:
ParentDir = pwd;
FolderName = 'Propagate_Temp_To_Depth_Z_OutputFolder';
t = datetime;
t.Format = 'yyyy-MM-dd';  
t = string(t);
FolderName = strcat(FolderName,{'_'},t);

% Check if it exists - if it doesn't, generate it 

FolderName = 'Propagate_Temp_To_Depth_Z_OutputFolder';
t = datetime;
t.Format = 'yyyy-MM-dd';
t = string(t);
FolderName = strcat(FolderName,{'_'},t);
if 7 ~= exist(FolderName,'dir')
mkdir(char(FolderName))
end

direc = dir;
[ismem,whichone] = ismember(FolderName,{direc.name});
Path1 = {direc(1).folder};
Path = strcat(Path1,{'\'},direc(whichone).name);
cd(Path{:})
DaughterFolder1 = 'PT2Z_Figures';
if 7 ~= exist(DaughterFolder1,'dir')
mkdir(Path{:},DaughterFolder1);
end
PathDaughterFolder1 = char(strcat(Path,{'\'},DaughterFolder1));
cd(PathDaughterFolder1)

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
formatspec = 'PT2Z_2_%s_OBT_Options.jpeg';
saveas(Figure1,sprintf(formatspec,strrep(ModelData.InputOBT.OBTTimeSeries_FileName,'.','_')))
cd(ParentDir)
%% Output some important info 
fprintf('[PT2Z_2] Input OBT Sorted and figure output\n')
fprintf('----------------------- PT2Z_2 Finished ------------------------\n')
fprintf(' \n')
fprintf('[USER] In Section 3 define ModelData.Auto_Fill_Data.UserChosenData.Y\n')
fprintf('       as the chosen year where [Y] = the number that year appears in') 
fprintf('the figure legend\n')
end


