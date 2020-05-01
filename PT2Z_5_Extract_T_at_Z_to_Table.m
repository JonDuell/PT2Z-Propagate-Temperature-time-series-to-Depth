function ModelData = PT2Z_5_Extract_T_at_Z_to_Table(ModelData)
% This is to output the temperautre at the chosen depth into the output
% folder 
%%
clc
fprintf('----------------------- Running PT2Z_5 ------------------------\n')

%% Define some temporary variables to keep the equations clean looking 

Depths = ModelData.Extract_to_Table.input.Depths;
z_list = ModelData.Depth_Data.zlist ;

%% Extract the depths of interest at the original dt step: 
fprintf('[PT2Z_5] Extractng T(Z) for the original time step dt = %gs\n',ModelData.Extract_to_Table.input.dt)

for d = 1:size(ModelData.Diffusivity_Data.Diffusivities,1)                  % For the number of diffusivities
ModelData.Extract_to_Table.Raw_T_at_spec_Depth(d).Name = ModelData.Diffusivity_Data.Names(d); % Extract the diffusivity name 
for i = 1:length(Depths)                                                    % For the number of depths defined
D_idx = find(ModelData.Depth_Data.zlist	 == Depths(i));                     % Find the index of the depths of interest within the depth range
ModelData.Extract_to_Table.Raw_T_at_spec_Depth(d).T_at_spec_Depths(i).Depths = Depths(i)      ;                                       % Print the Depth into the structure
ModelData.Extract_to_Table.Raw_T_at_spec_Depth(d).T_at_spec_Depths(i).T_at_spec_Depths = ModelData.outputSinusoidData(d).T(D_idx,:); % Extract the depth 	 
end
end

if ModelData.Extract_to_Table.input.dt ~= ModelData.Date_Data.Dt  
fprintf('[PT2Z_5] Interpolating dt = %gs to new dt = %gs\n',ModelData.Extract_to_Table.input.dt,ModelData.Date_Data.Dt)
end

ModelData.Extract_to_Table.NewDate_Vect = ModelData.Date_Data.t1:seconds(ModelData.Extract_to_Table.input.dt):ModelData.Date_Data.t2;

for d = 1:size(ModelData.Diffusivity_Data.Diffusivities,1)
ModelData.Extract_to_Table.interpOutputs_T_at_spec_Depth(d).Name = ModelData.Diffusivity_Data.Names(d); % Extract the diffusivity name     
    for i = 1:length(Depths)       
ModelData.Extract_to_Table.interpOutputs_T_at_spec_Depth(d).T_at_spec_Depths(i).Depths = Depths(i);
ModelData.Extract_to_Table.interpOutputs_T_at_spec_Depth(d).T_at_spec_Depths(i).T_at_spec_dt_and_Depths_Z = interp1(ModelData.Date_Data.Date_Vect,ModelData.Extract_to_Table.Raw_T_at_spec_Depth(d).T_at_spec_Depths(i).T_at_spec_Depths,ModelData.Extract_to_Table.NewDate_Vect);
    end 
end


%% Save the outputs to an output folder automatically: 

% Genarate an output folder 

% Temporarily generate the output folder name made in PT2Z_2 - to check if
% it is already made:
ParentDir = pwd;
FolderName = 'Propagate_Temp_To_Depth_Z_OutputFolder';
t = datetime;
t.Format = 'yyyy-MM-dd';
t = string(t);
FolderName = strcat(FolderName,{'_'},t);

% Check if it exists - if it doesn't, generate it 
if 7 ~= exist(FolderName,'dir')
mkdir(char(FolderName))
end

% Genreate Daughter Folder within the script output folder for PT2Z data
direc = dir;
[ismem,whichone] = ismember(FolderName,{direc.name});
Path1 = {direc(1).folder};
Path = strcat(Path1,{'\'},direc(whichone).name);
cd(Path{:})
% Get the path to the folder 

Path1 = {direc(1).folder};
DaughterFolder1 = 'PT2Z_5_Output_T_Extract_at_Z_Tables';
if 7 ~= exist(DaughterFolder1,'dir')
mkdir(Path{:},DaughterFolder1);
end
PathDaughterFolder1 = char(strcat(Path,{'\'},DaughterFolder1));
cd(PathDaughterFolder1) % Go inside the daughter directory 

% Generate tables Output files to .txt 

% Generate all the variable names, need to gen a date table and variable
% table as then concatenate them:
DateTable = array2table(ModelData.Extract_to_Table.NewDate_Vect','VariableNames',{'Data'});
DepthNames = strrep(string(Depths),'.','p');
DiffusivityNames = strrep(ModelData.Diffusivity_Data.Names,' ','_');

for i = 1:length(Depths)
    variablenames{i} = sprintf('Depth_%sm',DepthNames(i));
end 

for d = 1:size(ModelData.Diffusivity_Data.Diffusivities,1)
FileName = sprintf('PT2Z_%g_OBT_prop_%gm-%gm_in_%s_dt_%gs.txt',ModelData.Date_Data.Year,min(Depths),max(Depths),DiffusivityNames{d},ModelData.Extract_to_Table.input.dt);   
fprintf('[PT2Z_5] SAVING: %s\n',FileName)   
    for i = 1:length(Depths)
        % Generate filename % Diffusivity name; Diffusivity
        % Genreate temporary temperature array
        TempForm_d_time_t(:,i) = ModelData.Extract_to_Table.interpOutputs_T_at_spec_Depth(d).T_at_spec_Depths(i).T_at_spec_dt_and_Depths_Z;
    end
TempTTable = array2table(TempForm_d_time_t,'VariableNames',variablenames);
ModelData.Extract_to_Table.OutputTables.(DiffusivityNames{d}) = [DateTable,TempTTable] ;  
writetable(ModelData.Extract_to_Table.OutputTables.(DiffusivityNames{d}),sprintf('PT2Z_5_%s_at_%g_depths.txt',DiffusivityNames{d},length(DepthNames)))
end

cd(ParentDir)

fprintf('[PT2Z_5] Finished Saving Tables \n')
fprintf('----------------------- PT2Z_5 Finished ------------------------\n')
end