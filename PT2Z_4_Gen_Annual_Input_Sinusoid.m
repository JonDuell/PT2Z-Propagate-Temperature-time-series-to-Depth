function ModelData = PT2Z_4_Gen_Annual_Input_Sinusoid(ModelData)
% PT2Z_2 takes the model inputs defined in section 2 and makes an
% annual input sinusoid for the rest of the modelling: 

%%
clc
fprintf('----------------------- Running PT2Z_4 ------------------------\n')

fprintf('[PT2Z_4] Genarating input sinusoid for chosen parameters\n')
%% Sort out the date data for the input sinusoid for min timestep of half hour:
if ModelData.Auto_Fill_Data.UserChosenData.Flag == 0
fprintf('[PT2Z_4] Manual inputs chosen\n')

ModelData.Date_Data.t1 = datetime(ModelData.Date_Data.Year,01,01,00,00,00);
ModelData.Date_Data.t2 = datetime(ModelData.Date_Data.Year,12,31,11,30,00);

ModelData.Date_Data.Min_Date = ModelData.Date_Data.t1 + caldays(ModelData.Date_Data.Minday);
ModelData.Date_Data.Date_Vect = ModelData.Date_Data.t1:seconds(ModelData.Date_Data.Dt):ModelData.Date_Data.t2;


elseif ModelData.Auto_Fill_Data.UserChosenData.Flag == 1
fprintf('[PT2Z_4] Auto inputs chosen\n')
ModelData.Date_Data.t1 = datetime(ModelData.Auto_Fill_Data.OBT_Derived.t1.Year,01,01,00,00,00);
ModelData.Date_Data.t2 = datetime(ModelData.Auto_Fill_Data.OBT_Derived.t1.Year,12,31,11,30,00);
ModelData.Date_Data.Min_Date = ModelData.Auto_Fill_Data.OBT_Derived.MinTemp_date;
ModelData.Date_Data.Date_Vect = ModelData.Date_Data.t1:seconds(ModelData.Date_Data.Dt):ModelData.Date_Data.t2;

ModelData.Temp_Data.MinTemp = ModelData.Auto_Fill_Data.OBT_Derived.MinTemp;        % The    min of temperature variation throughout the year
ModelData.Temp_Data.MaxTemp = ModelData.Auto_Fill_Data.OBT_Derived.MaxTemp;   % The max of temperature variation throughout the year
ModelData.Temp_Data.MeanTemp = ModelData.Auto_Fill_Data.OBT_Derived.MeanTemp;  % The mean of temperature variation throughout the year   
end

ModelData.Date_Data.tmin_Seconds = seconds(0);
ModelData.Date_Data.tmax_Seconds = -etime(datevec(ModelData.Date_Data.t1),datevec(ModelData.Date_Data.t2)); % max time (days)
ModelData.Date_Data.tlist_Seconds = ModelData.Date_Data.tmin_Seconds:seconds(ModelData.Date_Data.Dt):seconds(ModelData.Date_Data.tmax_Seconds);
ModelData.Temp_Data.Amplitude = (ModelData.Temp_Data.MaxTemp-ModelData.Temp_Data.MinTemp)/2;

    

%% Sort out the Z data 

ModelData.Depth_Data.zlist = ModelData.Depth_Data.zmin:ModelData.Depth_Data.dz:ModelData.Depth_Data.zmax ;

%% Form all the construction variables for each equation:

ModelData.Date_Data.Months = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
ModelData.Date_Data.Month_Color = [1 0 0;1 0.5 0;1 0.8 0;1 0.9 0;0.7 0.9 0;0 1 0;0 1 1;0 0.75 1;0 0.5 1;1 0.2 1;0.6 0.2 1;0.4 0 1];

ModelData.inputSinusoidData.Omega = 2*pi/(365*24*60*60);
ModelData.inputSinusoidData.P_i = 365*(24*60*60); % Period of term i (365)
ModelData.inputSinusoidData.shift = (365/2) + ModelData.Date_Data.Minday;
ModelData.inputSinusoidData.shiftmuller = (365/2) - ModelData.Date_Data.Minday;
ModelData.inputSinusoidData.phi_i = (ModelData.inputSinusoidData.shift/365)*2*pi; % Phase of term i
ModelData.inputSinusoidData.phi_i_muller = (ModelData.inputSinusoidData.shiftmuller/365)*2*pi;

%% Form all the construction variables for each equation:

%Just making temporary variables to keep the equations neat:
TMP_z_list = ModelData.Depth_Data.zlist;
TMP_t_list = seconds(ModelData.Date_Data.tlist_Seconds);
TMP_G = ModelData.Temp_Data.Geotherm; % Undisturbed geothermal gradient (K/m)

TMP_A = ModelData.Temp_Data.Amplitude;
TMP_Tmean = ModelData.Temp_Data.MeanTemp;
TMP_P_i = 365*(24*60*60); % Period of term i
TMP_shift = (365/2) + ModelData.Date_Data.Minday; %Hammamoto and Worzky
TMP_phi_i = (TMP_shift/365)*2*pi; % Phase of term i

TMP_Diffusivities = ModelData.Diffusivity_Data.Diffusivities;
fprintf('[PT2Z_4] Genarating annual input OBT(t) sinusoid\n')

for Diffusivity = 1:size(TMP_Diffusivities,1)
    fprintf('[PT2Z_4] Propagating OBT(t) to T(Z,t) through: %s\n',ModelData.Diffusivity_Data.Names{Diffusivity,:})
    ModelData.outputSinusoidData(Diffusivity).Name = string(ModelData.Diffusivity_Data.Names(Diffusivity));
    % Calculate T(Z,t) using the (Hammamoto, 2005)and Worzky
    % Equations: 
    for t_index = 1:length(TMP_t_list)
        for z_index = 1:length(TMP_z_list)
            ModelData.outputSinusoidData(Diffusivity).T(z_index,t_index) = TMP_Tmean + TMP_G*TMP_z_list(z_index) + ...
                TMP_A*exp(-sqrt(pi/(TMP_Diffusivities(Diffusivity)*TMP_P_i))*TMP_z_list(z_index))*cos(2*pi*TMP_t_list(t_index)/TMP_P_i-TMP_phi_i-sqrt(pi/(TMP_Diffusivities(Diffusivity)*TMP_P_i))*TMP_z_list(z_index));
        end
    end

    
    for z_index = 1:length(TMP_z_list)
        ModelData.outputSinusoidData(Diffusivity).TGeotherm(z_index) = TMP_G*TMP_z_list(z_index);
    end
  
end

%% Generate a figure showing the generated inout sinusoid: 
fprintf('[PT2Z_4] Genarating input OBT(t) figure\n')

figure0 = figure('Name',sprintf('Generated input OBT for year = %g',ModelData.Date_Data.Year));
if ModelData.Auto_Fill_Data.UserChosenData.Flag == 1;
fprintf('[PT2Z_4] With input real input time series\n')

plot(ModelData.Auto_Fill_Data.UserChosenData.Chosen_Dataset.Table_Data{:,1},ModelData.Auto_Fill_Data.UserChosenData.Chosen_Dataset.Table_Data{:,2},'Color','k','LineStyle','-.'); hold on     
box off
plot(ModelData.Date_Data.Date_Vect,ModelData.outputSinusoidData(1).T(1,:),'Color','k','LineStyle','-'); 
plot(ModelData.Date_Data.Date_Vect,repmat(mean(ModelData.outputSinusoidData(1).T(1,:)),size(ModelData.Date_Data.Date_Vect)),'Color','r','LineStyle','--'); 
plot(ModelData.Date_Data.Date_Vect,repmat(max(ModelData.outputSinusoidData(1).T(1,:)),size(ModelData.Date_Data.Date_Vect)),'Color','g','LineStyle','--'); 
sz = 20;
scatter(ModelData.Date_Data.Min_Date,min(ModelData.outputSinusoidData(1).T(1,:)),100,'x','k'); 
formatspec = 'Raw OBT for %g';
Leg{1} = sprintf(formatspec,ModelData.Date_Data.Year);
formatspec = 'Generated OBT for %g';
Leg{2} = sprintf(formatspec,ModelData.Date_Data.Year);
formatspec = 'Mean OBT = %g^{o}C';
Leg{3} = sprintf(formatspec,round(mean(ModelData.outputSinusoidData(1).T(1,:)),4,'significant'));
formatspec = 'Amplitude OBT = %g^{o}C';
Leg{4} = sprintf(formatspec,round(max(ModelData.outputSinusoidData(1).T(1,:))-mean(ModelData.outputSinusoidData(1).T(1,:)),2,'significant'));
formatspec = 'Min temp date = %s';
Leg{5} = sprintf(formatspec,ModelData.Date_Data.Min_Date);
leg = legend(Leg,'Location','northeastoutside');
xlabel('Date')
ylabel('Temperature ^{o}C')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif ModelData.Auto_Fill_Data.UserChosenData.Flag == 0
fprintf('[PT2Z_4] Without real input timeseries\n')

plot(ModelData.Date_Data.Date_Vect,ModelData.outputSinusoidData(1).T(1,:),'Color','k','LineStyle','-'); hold on
box off
plot(ModelData.Date_Data.Date_Vect,repmat(mean(ModelData.outputSinusoidData(1).T(1,:)),size(ModelData.Date_Data.Date_Vect)),'Color','r','LineStyle','--'); 
plot(ModelData.Date_Data.Date_Vect,repmat(max(ModelData.outputSinusoidData(1).T(1,:)),size(ModelData.Date_Data.Date_Vect)),'Color','g','LineStyle','--'); 
sz = 20;
scatter(ModelData.Date_Data.Min_Date,min(ModelData.outputSinusoidData(1).T(1,:)),100,'x','k'); 
formatspec = 'Generated OBT for %g';
Leg{1} = sprintf(formatspec,ModelData.Date_Data.Year);
formatspec = 'Mean OBT = %g^{o}C';
Leg{2} = sprintf(formatspec,round(mean(ModelData.outputSinusoidData(1).T(1,:)),4,'significant'));
formatspec = 'Amplitude OBT = %g^{o}C';
Leg{3} = sprintf(formatspec,round(max(ModelData.outputSinusoidData(1).T(1,:))-mean(ModelData.outputSinusoidData(1).T(1,:)),2,'significant'));
formatspec = 'Min temp date = %s';
Leg{4} = sprintf(formatspec,ModelData.Date_Data.Min_Date);
leg = legend(Leg,'Location','northeastoutside');
xlabel('Date')
ylabel('Temperature ^{o}C')
end
%%
ParentDir = pwd;
FolderName = 'Propagate_Temp_To_Depth_Z_OutputFolder';
t = datetime;
t.Format = 'yyyy-MM-dd';
t = string(t);
FolderName = strcat(FolderName,{'_'},t);
if 7 ~= exist(FolderName,'dir')   
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
if 7 ~= exist(DaughterFolder1,'dir')
mkdir(Path{:},DaughterFolder1);
end
PathDaughterFolder1 = char(strcat(Path,{'\'},DaughterFolder1));
cd(PathDaughterFolder1)

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
formatspec = 'PT2Z_4_Input_OBT_Y_%g_Sinusoid_Parameters.jpeg';
saveas(figure0,sprintf(formatspec,ModelData.Date_Data.Year))
cd(ParentDir)
fprintf('[PT2Z_4] T(Z,t) Genarated \n')
fprintf('[PT2Z_4] Figure output \n')
fprintf('----------------------- PT2Z_4 Finished ------------------------\n')
end