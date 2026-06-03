%% Impedance Plot with Temperature-Based and Blue-Colored Curves %%

clear; clc; close all
set(0,'DefaultFigureWindowStyle','normal');

%% Setup and Paths
addpath('functions')
addpath('variables')
set_plot_defaults_constant_font(16);

load("CapacityPartial.mat")

% Recombine
LogData = struct([]);
Log_v   = [];
for k = 1:20
    fname = sprintf('variables/LogData_selected_%02d.mat', k);
    tmp   = load(fname);  % loads LogData_part, Log_v_part
    LogData = [LogData, tmp.LogData_part];
    Log_v   = [Log_v,   tmp.Log_v_part];
end

%% Some settings
plot_single_cell = 1;
set_plot_mileage = 0;
font_size = 16;

Capacity_Vector = 220:240;
delta_ind       = round(length(winter)/ length(Capacity_Vector));
hot_colors      = flipud(winter);
colors_p        = hot_colors(1:delta_ind:length(winter),:);

%% Generate Color Maps
T_min = 10;
T_max = 35;

N = length(Log_v);
green_pastel    = [0.40 0.75 0.55];
lavender_pastel = [0.70 0.65 0.90];
indigo_pastel   = [0.35 0.25 0.65];

colors = interp1([0 0.5 1], ...
               [green_pastel; lavender_pastel; indigo_pastel], ...
               linspace(0,1,N));

%% Initialization
Impedance_inter = {};
Energies = [];
Mileage  = [];
Temp     = [];
t_str      = strings(length(Log_v), 1);
t_datetime = NaT(length(Log_v), 1);
voltage_interp = 3.75:0.001:3.84;
d1 = designfilt("lowpassiir", FilterOrder=5, HalfPowerFrequency=0.0002, DesignMethod="butter");

%% Figures
f1 = figure(1); hold on;
xlabel('Voltage [V]'); ylabel('1/Z_1 [k\Omega^{-1}]');
colormap(figure(1), colors); cb1 = colorbar;
xlim([3.5,4.15]); ylim([0,20]);

f2 = figure(2); hold on;
xlabel('Voltage [V]'); ylabel('1/Z_108 [k\Omega^{-1}]');
colormap(figure(2), colors); cb1 = colorbar;
xlim([3.5,4.15]); ylim([0,20]);

f3 = figure(3); hold on;
xlabel('Voltage [V]'); ylabel('1/Z [\Omega^{-1}]');
colormap(figure(3), colors); cb1 = colorbar;

%% Main Loop

for h = 1:N

    Impedence = LogData(h).data;   % <-- replaces load(fullfile(...))

    t_str(h)      = Impedence.DateTime;
    t_datetime(h) = datetime(Impedence.DateTime, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');

    c_blue = colors(h,:);

    Z_fil      = filtfilt(d1, Impedence.Z_chg_LC(:,1));
    Z_fil_pack = filtfilt(d1, Impedence.Z_chg);
    
    if h ~=84
        figure(1)
        plot(Impedence.V_chg_LC(10000:end,1), 1./Z_fil(10000:end)/1000, 'Color', c_blue)
    end 

    if h ~=84
        figure(2)
        Z_fil = filtfilt(d1, Impedence.Z_chg_LC(:,2));
        plot(Impedence.V_chg_LC(10000:end,1), 1./Z_fil(10000:end)/1000, 'Color', c_blue)
    end

    if h ~=84
        figure(3)
        plot(Impedence.V_chg(10000:end), 1./Z_fil_pack(10000:end)/1000, 'Color', c_blue)
    end
    
    Impedance_inter_tmp = zeros(length(voltage_interp), 108);

    indx = Impedence.V_chg_LC(:,1) >= 3.75 & Impedence.V_chg_LC(:,1) <= 3.84;

end

%% Colorbar date labels
tick_indices     = round(linspace(1, N, 5));
str_date         = datestr(t_datetime(tick_indices));
str_date         = str_date(:,1:11);
str_date_combined = [str_date(:,4:6), str_date(:,3), str_date(:,10:11)];

figure(1); cb1 = colorbar; cb1.Ticks = linspace(0,1,5);
cb1.TickLabels = cellstr(str_date_combined); grid off
figure(2); cb1 = colorbar; cb1.Ticks = linspace(0,1,5);
cb1.TickLabels = cellstr(str_date_combined); grid off
figure(3); cb1 = colorbar; cb1.Ticks = linspace(0,1,5);
cb1.TickLabels = cellstr(str_date_combined); grid off

lock_fonts(f1,font_size,font_size,font_size,font_size)
lock_fonts(f2,font_size,font_size,font_size,font_size)
lock_fonts(f3,font_size,font_size,font_size,font_size)

%% Load Processed Data
load("Impedance_Interpolated.mat")

%% Extract statistics
N = length(Impedance_inter);

features.beg_v = []; features.end_v = [];
features.beg_v_rel = []; features.end_v_rel = [];
features.peak_val = []; features.idx_peak = [];

for i = 1:N
    features.beg_v(i,:) = Impedance_inter{i}(1,:);
    features.end_v(i,:) = Impedance_inter{i}(end,:);
    features.beg_v_rel(i,:) = (Impedance_inter{i}(1,:)-Impedance_inter{1}(1,:))./Impedance_inter{1}(1,:);
    features.end_v_rel(i,:) = (Impedance_inter{i}(end,:)-Impedance_inter{1}(end,:))./Impedance_inter{1}(end,:);
    for cell_idx = 1:108
        [features.peak_val(i,cell_idx), features.idx_peak(i,cell_idx)] = max(Impedance_inter{i}(:,cell_idx));
    end
end

for i = 1:N
    features.mean_beg_v(i)    = mean(features.beg_v(i,:), 2);
    features.std_beg_v(i)     = std(features.beg_v(i,:), 0, 2);
    features.mean_end_v(i)    = mean(features.end_v(i,:), 2);
    features.std_end_v(i)     = std(features.end_v(i,:), 0, 2);
    features.mean_beg_v_rel(i)= mean(features.beg_v_rel(i,:), 2);
    features.std_beg_v_rel(i) = std(features.beg_v_rel(i,:), 0, 2);
    features.mean_end_v_rel(i)= mean(features.end_v_rel(i,:), 2);
    features.std_end_v_rel(i) = std(features.end_v_rel(i,:), 0, 2);
    features.mean_peak_val(i) = mean(features.peak_val(i,:), 2);
    features.std_peak_val(i)  = std(features.peak_val(i,:), 0, 2);
    features.mean_valley_val(i)= mean(1./features.peak_val(i,:), 2);
    features.std_valley_val(i) = std(1./features.peak_val(i,:), 0, 2);
    features.min_valley_val(i) = min(1./features.peak_val(i,:));
    features.max_valley_val(i) = max(1./features.peak_val(i,:));
    features.mean_peak_v(i)   = mean(voltage_interp(features.idx_peak(i,:)), 2);
    features.std_peak_v(i)    = std(voltage_interp(features.idx_peak(i,:)), 0, 2);
    features.min_peak_v(i)    = min(voltage_interp(features.idx_peak(i,:)));
    features.max_peak_v(i)    = max(voltage_interp(features.idx_peak(i,:)));
end

tick_indices      = round(linspace(1, N, 5));
str_date          = datestr(t_datetime(tick_indices));
str_date          = str_date(:,1:11);
str_date_combined = [str_date(:,4:6), str_date(:,3), str_date(:,10:11)];
features.str_date_combined = str_date_combined;

%% Plot zoomed peak

figure; hold on
for i = 1:N
    plot(voltage_interp, 1./Impedance_inter{i}(:,1)/1000, 'Color', colors(i,:))
end
xlabel('Voltage'); ylabel('1/Z_1 [k\Omega^{-1}]')
grid off

figure; hold on
for i = 1:N
    plot(voltage_interp, 1./Impedance_inter{i}(:,108)/1000, 'Color', colors(i,:))
end
xlabel('Voltage'); ylabel('1/Z_{108} [k\Omega^{-1}]')
grid off

%% Plot Results

Plot_Impedance_Results_Date_paper(features,colors,font_size)