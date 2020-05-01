function PT2Z_7_Temp_vs_Depth_At_times_t_Figure(ModelData)
%%
clc
fprintf('----------------------- Running PT2Z_7 ------------------------\n')
%%
fprintf('[PT2Z_7] Extracting T(Z(%g:%gm)) t = %g/%s/%g : %g/%s/%g\n',min(ModelData.Depth_Data.zlist),max(ModelData.Depth_Data.zlist),ModelData.T_vs_Z_at_t_figure.Day,ModelData.Date_Data.Months{1,1},ModelData.Date_Data.Year,ModelData.T_vs_Z_at_t_figure.Day,ModelData.Date_Data.Months{1,12},ModelData.Date_Data.Year) 

for m = 1:12
Date(m,1) = datetime(ModelData.Date_Data.Year,m,ModelData.T_vs_Z_at_t_figure.Day,00,00,00);
Date_Idx(m,1) = find(ModelData.Date_Data.Date_Vect == Date(m,1));
ModelData.T_vs_Z_at_t_figure.Index_Data(m).By_t_Data = ModelData.outputSinusoidData(ModelData.T_vs_Z_at_t_figure.f).T(:,Date_Idx(m));
end

formatspec = 'OBT_%g_Extrap_through_%s_%gm_to_%gm';

z_list = ModelData.Depth_Data.zlist;
DiffusivityNames = strrep(ModelData.Diffusivity_Data.Names,' ','_');

figure2 = figure('Name',sprintf(formatspec,ModelData.Date_Data.Year,DiffusivityNames{ModelData.T_vs_Z_at_t_figure.f},min(z_list),max(z_list))) ;
fprintf('[PT2Z_7] Plotting T(Z(%g:%gm)) t = %g/%s/%g : %g/%s/%g\n',min(ModelData.Depth_Data.zlist),max(ModelData.Depth_Data.zlist),ModelData.T_vs_Z_at_t_figure.Day,ModelData.Date_Data.Months{1,1},ModelData.Date_Data.Year,ModelData.T_vs_Z_at_t_figure.Day,ModelData.Date_Data.Months{1,12},ModelData.Date_Data.Year) 
for i = 1:12
Q = plot(ModelData.T_vs_Z_at_t_figure.Index_Data(i).By_t_Data,ModelData.Depth_Data.zlist,'Color',ModelData.Date_Data.Month_Color(i,:)); hold on
end
A = ModelData.outputSinusoidData.TGeotherm  ;
B = mean(ModelData.outputSinusoidData(1).T(z_list == 0,:));
C = A + B;
fprintf('[PT2Z_7] Plotting Geotherm G(Z(%g:%gm))\n',min(ModelData.Depth_Data.zlist),max(ModelData.Depth_Data.zlist)) 
plot(C,z_list,'r','LineStyle','--')
xlabel('T ({\circ}C)'); ylabel('Depth (m)');
ax = gca; ax.TickDir = 'out'; ax.YDir = 'reverse';
L = legend({ModelData.Date_Data.Months{1:12},sprintf('%g K/m',ModelData.Temp_Data.Geotherm)},'location','SE'); 
set(gca,'box','off')

%%
% Temporarily generate the output folder name made in PT2Z_2 - to check if
% it is already made:
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
formatspec = 'PT2Z_7_OBT_%g_Monthly_Extrap_through_%s_%gm_to_%gm.jpeg';
saveas(figure2,sprintf(formatspec,ModelData.Date_Data.Year,DiffusivityNames{ModelData.T_vs_Z_at_t_figure.f},min(z_list),max(z_list)))
cd(ParentDir)
%%
fprintf('[PT2Z_7] Figure saved\n') 
fprintf('----------------------- PT2Z_7 Finished ------------------------\n')
end