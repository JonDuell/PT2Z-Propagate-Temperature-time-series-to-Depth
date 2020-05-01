function ModelData = PT2Z_6_Temp_To_DepthZ_Figure(ModelData)
%%
clc
fprintf('----------------------- Running PT2Z_6 ------------------------\n')
%
% Define some temporary variables so the equations are cleaner 
Depths = ModelData.T_at_Z_figure.input.Depths;
z_list = ModelData.Depth_Data.zlist;

for d = 1:size(ModelData.Diffusivity_Data.Diffusivities,1)                                          % For the number of diffusivities
ModelData.T_at_Z_figure.Raw_T_at_spec_Depth(d).Name = ModelData.Diffusivity_Data.Names(d);          % Extract the diffusivity name 
for i = 1:length(Depths)                                                                            % For the number of depths defined
D_idx = ModelData.Depth_Data.zlist == Depths(i);                                                    % Find the index of the depths of interest within the depth range
ModelData.T_at_Z_figure.Raw_T_at_spec_Depth(d).T_at_spec_Depths(i).Depths = Depths(i) ;                                           % Print the Depth into the structure
ModelData.T_at_Z_figure.Raw_T_at_spec_Depth(d).T_at_spec_Depths(i).T_at_spec_Depths = ModelData.outputSinusoidData(d).T(D_idx,:); % Extract the depth 	 
end
end
fprintf('[PT2Z_6] Plotting OBT propagated to Z depths through: %s\n',ModelData.Diffusivity_Data.Names{ModelData.T_at_Z_figure.input.f})        

if ModelData.Auto_Fill_Data.UserChosenData.Flag == 0
fprintf('[PT2Z_6] No raw OBT used')        

formatspec = 'OBT_%g_%s_%gm_to_%gm';
Figure1 = figure('Name',sprintf(formatspec,ModelData.Date_Data.Year,ModelData.Diffusivity_Data.Names{ModelData.T_at_Z_figure.input.f},min(ModelData.T_at_Z_figure.input.Depths),max(ModelData.T_at_Z_figure.input.Depths))) ;  

plot(ModelData.Date_Data.Date_Vect,ModelData.T_at_Z_figure.Raw_T_at_spec_Depth(ModelData.T_at_Z_figure.input.f).T_at_spec_Depths(1).T_at_spec_Depths,'Color','k','LineStyle','--'); hold on 
for i = 2:length(Depths)
R = plot(ModelData.Date_Data.Date_Vect,ModelData.T_at_Z_figure.Raw_T_at_spec_Depth(ModelData.T_at_Z_figure.input.f).T_at_spec_Depths(i).T_at_spec_Depths);  hold on
end
xlabel('Date')  
ylabel('Temperature ^{o}C')
set(gca,'box','off')
formatspec = '%gm';
for i = 1:length(Depths)
lgen{i,1} = sprintf(formatspec,Depths(i));
end
legend(lgen)

elseif ModelData.Auto_Fill_Data.UserChosenData.Flag == 1
fprintf('[PT2Z_6] Raw OBT plotted\n')       
formatspec = 'OBT_%g_%s_%gm_to_%gm';
Figure1 = figure('Name',sprintf(formatspec,ModelData.Date_Data.Year,ModelData.Diffusivity_Data.Names{ModelData.T_at_Z_figure.input.f},min(ModelData.T_at_Z_figure.input.Depths),max(ModelData.T_at_Z_figure.input.Depths)))  ; 
plot(ModelData.Auto_Fill_Data.UserChosenData.Chosen_Dataset.Table_Data{:,1},ModelData.Auto_Fill_Data.UserChosenData.Chosen_Dataset.Table_Data{:,2},'Color','k','LineStyle','-.'); hold on     
plot(ModelData.Date_Data.Date_Vect,ModelData.T_at_Z_figure.Raw_T_at_spec_Depth(ModelData.T_at_Z_figure.input.f).T_at_spec_Depths(1).T_at_spec_Depths,'Color','k','LineStyle','-'); hold on 
for i = 2:length(Depths)
R = plot(ModelData.Date_Data.Date_Vect,ModelData.T_at_Z_figure.Raw_T_at_spec_Depth(ModelData.T_at_Z_figure.input.f).T_at_spec_Depths(i).T_at_spec_Depths);  hold on
end
xlabel('Date')  
ylabel('Temperature ^{o}C')
set(gca,'box','off')

formatspec = 'Raw OBT for %g';
lgen{1,1} = sprintf(formatspec,ModelData.Date_Data.Year);
formatspec = '%gm';
for i = 2:length(Depths)+1
lgen{i,1} = sprintf(formatspec,Depths(i-1));
end
legend(lgen,'location','northeastoutside')
end
%%

ParentDir = pwd;
FolderName = 'Propagate_Temp_To_Depth_Z_OutputFolder';
t = datetime;
t.Format = 'yyyy-MM-dd';
t = string(t);
FolderName = strcat(FolderName,{'_'},t);
if ~exist(FolderName,'dir')   
mkdir(char(FolderName))
direc = dir;
[ismem,whichone] = ismember(FolderName,{direc.name});
Path1 = {direc(1).folder};
Path = strcat(Path1,{'\'},direc(whichone).name);
DaughterFolder1 = 'Figures';
mkdir(Path{:},DaughterFolder1);
PathDaughterFolder1 = char(strcat(Path,{'\'},DaughterFolder1));
cd(PathDaughterFolder1)
end

%%

ParentDir = pwd;
FolderName = 'Propagate_Temp_To_Depth_Z_OutputFolder';
t = datetime;
t.Format = 'yyyy-MM-dd';
t = string(t);
FolderName = strcat(FolderName,{'_'},t);
direc = dir;
[ismem,whichone] = ismember(FolderName,{direc.name});
Path1 = {direc(1).folder};
Path = strcat(Path1,{'\'},direc(whichone).name);
cd(Path{:})
DaughterFolder1 = 'PT2Z_Figures';
if ~exist(DaughterFolder1,'dir')
mkdir(Path{:},DaughterFolder1);
end
PathDaughterFolder1 = char(strcat(Path,{'\'},DaughterFolder1));

cd(PathDaughterFolder1)
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
formatspec = 'PT2Z_6_OBT_%g_%s_%gm_to_%gm.jpeg';
saveas(Figure1,sprintf(formatspec,ModelData.Date_Data.Year,ModelData.Diffusivity_Data.Names{ModelData.T_at_Z_figure.input.f},min(ModelData.T_at_Z_figure.input.Depths),max(ModelData.T_at_Z_figure.input.Depths)))
cd(ParentDir)
%%
fprintf('[PT2Z_6] Figure saved\n')       
fprintf('----------------------- PT2Z_6 Finished ------------------------\n')
end