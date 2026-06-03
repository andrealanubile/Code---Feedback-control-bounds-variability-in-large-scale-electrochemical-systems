%% ==================== SETUP ====================
clear; clc; close all;

% Paths / utils
addpath('functions')
addpath('variables')
set_plot_defaults_constant_font(16);

load("History_DeltaOCV_new_v2026.mat");
load("CapacityPartial.mat");
load("DataAugmentation_new_v2026.mat");
load("Temperature_Collection.mat");

% Trim first entries as in your original script
Day_beg(1) = []; 
Day_end(1) = [];

%% ==================== STATS ====================
[DeltaSOC_mean, ~, ~] = computeDeltaSOCStats(DeltaSOC_LC, corr_value, Day_end);

valid_indices = find( ...
    (mean(SOC_beg,2) >= 55 | mean(SOC_beg,2) <= 20) & ...
    (mean(SOC_end,2) >= 55 | mean(SOC_end,2) <= 20) & ...
    DeltaSOC_mean' >= 25 & Rest_beg' >= minutes(13) & Rest_end' >=minutes(13));

Date = datetime("1-May-2024");
valid_indices_1 = find( ...
    (mean(SOC_beg,2) >= 55 | mean(SOC_beg,2) <= 20) & ...
    (mean(SOC_end,2) >= 55 | mean(SOC_end,2) <= 20) & ...
    DeltaSOC_mean' >= 25 & (Day_end<Date)' & Rest_beg' >= minutes(5) & Rest_end' >=minutes(5)');
% valid_indices = find( ...
%     (mean(SOC_beg,2) >= 55 | mean(SOC_beg,2) <= 20) & ...
%     (mean(SOC_end,2) >= 55 | mean(SOC_end,2) <= 20) & ...
%     DeltaSOC_mean' >= 25 & (Day_end>Date)');

color_info_raw_matrix     = computeColorInfoMatrix(DeltaSOC_LC, DeltaSOC_mean, valid_indices);
[normalized_HI, ref_row]  = normalizeColorInfo(color_info_raw_matrix); %#ok<NASGU>
mean_HI                   = mean(color_info_raw_matrix, 1);            %#ok<NASGU>
std_HI                    = std(color_info_raw_matrix, 0, 1);          %#ok<NASGU>
std_HI_norm               = std(normalized_HI, 0, 1);                  %#ok<NASGU>

color_info_raw_matrix_1     = computeColorInfoMatrix(DeltaSOC_LC, DeltaSOC_mean, valid_indices_1);
[normalized_HI_1, ref_row_1]  = normalizeColorInfo(color_info_raw_matrix_1); %#ok<NASGU>
mean_HI_1                   = mean(color_info_raw_matrix_1, 1);            %#ok<NASGU>
std_HI_1                    = std(color_info_raw_matrix_1, 0, 1);          %#ok<NASGU>
std_HI_norm_1               = std(normalized_HI_1, 0, 1);                  %#ok<NASGU>

%% ==================== GLOBAL PLOT CONTROLS ====================
idx_to_plot   = [36, 29287];
idx_to_plot   = [valid_indices(1), valid_indices(end)];
lower_limit   = -1.5;
upper_limit   =  1.5;

% Colormap helpers
make_pastel = @(cmap, f) min(1, cmap + (1 - cmap) * f);
pastel_factor_hi   = 0.25;
pastel_factor_temp = 0.25;
N = 256;

% ---- HI colormap: Blue → (short) Grey → Red ----
grey_frac   = 0.05;                               % SHORT grey band (10% of scale)
base_cmap   = build_blue_grey_red(N, grey_frac);  % custom builder below
base_cmap   = flipud(base_cmap);                  % match your original visual direction
custom_cmap = make_pastel(base_cmap, pastel_factor_hi);
[cm, nColors] = prep_colormap_for_limits(custom_cmap, lower_limit, upper_limit, N);

% ---- Temperature colormap: mostly same, slightly darker at the very top ----
t = linspace(0,1,N)'; 

% Start near yellow [1,1,0] at bottom, fade to red [1,0,0]
low_yellow = [1 1 0];
high_red   = [1 0 0];

orange_red = [ ...
    ones(N,1), ...                          % R always 1
    (1 - t).*low_yellow(2) + t.*high_red(2), ... % G fades 1 → 0
    (1 - t).*low_yellow(3) + t.*high_red(3)];    % B fades 0 → 0 (stays 0)

% Darken only the very top 15%
darkening        = ones(N,1);
top_mask         = (t >= 0.85);
darkening(top_mask) = linspace(1, 0.85, sum(top_mask))';
orange_red       = orange_red .* darkening;

cmap_temp_pastel = make_pastel(orange_red, pastel_factor_temp);

%% ==================== PLOTS ====================
% --- Per-event distributions / profiles ---
for ii = 1:numel(idx_to_plot)
    ev_idx   = idx_to_plot(ii);
    DeltaSOC = DeltaSOC_LC(ev_idx, :);
    mu       = mean(DeltaSOC);
    vec      = (mu - DeltaSOC) ./ max(DeltaSOC, eps) * 100; % robust to zero
    
    % Distribution (colored by HI)
    plot_event_distribution(vec, ev_idx, lower_limit, upper_limit, cm, nColors);
    colormap(custom_cmap); caxis([lower_limit upper_limit]); colorbar;

end

% --- IQR sticks (colored by HI) ---
M_pct    = color_info_raw_matrix * 100;
lower_p  = 25;
higher_p = 75;

% For the first half
M_pct_1    = color_info_raw_matrix_1 * 100;
lower_p  = 25; 
higher_p = 75;

plot_iqr_sticks_colored(M_pct, lower_limit, upper_limit, cm, custom_cmap, lower_p, higher_p);
colormap(custom_cmap); caxis([lower_limit upper_limit]); colorbar;

% --- Capacity vs median(HI) ---
% First Lab test vs First portion of data
p50_1 = prctile(M_pct_1, 50, 1);
plot_capacity_vs_median(Capacity_partial,      p50_1, custom_cmap, -1, 1);
corrcoef((Capacity_partial-mean(Capacity_partial))./Capacity_partial,p50_1)

load('CapacityPartial_2.mat')
p50 = prctile(M_pct, 50, 1);
plot_capacity_vs_median(Capacity_partial_C3,   p50, custom_cmap, -1, 1);
corrcoef((Capacity_partial_C3-mean(Capacity_partial_C3))./Capacity_partial_C3,p50)


%% ==================== Temperature-colored plots ====================
T_collection    = [T_collection_driving, T_collection_charging];
T_mean_per_cell = mean(T_collection_driving, 2, 'omitnan');
T_median_per_cell = median(T_collection_driving, 2, 'omitnan');
T_std_per_cell  = std(T_collection_driving, 0, 2, 'omitnan');

num_cells = size(M_pct,2);
assert(numel(T_mean_per_cell)==num_cells && numel(T_std_per_cell)==num_cells, ...
    'Temperature vectors must have length == number of cells.');

% Color limits
clim_mean = [min(T_median_per_cell) max(T_median_per_cell)];
clim_std  = [min(T_std_per_cell)  max(T_std_per_cell)];

% Percentiles to show
p_low  = lower_p;
p_high = higher_p;

plot_temperature_row_percentiles(T_collection_driving, p_low, p_high)

plot_Hid_vs_t_median(p50,  T_median_per_cell, cmap_temp_pastel, 19, 21);
corrcoef(p50,  T_mean_per_cell)



%% ==================== HELPERS ====================
function cmap = build_blue_grey_red(n, grey_frac)
%BUILD_BLUE_GREY_RED  Blue → Grey → Red with adjustable grey width (short band).
%   n         : number of colors (e.g., 256)
%   grey_frac : fraction of the scale used for grey (e.g., 0.05–0.15)

    % Clamp and split
    grey_frac = max(0, min(0.4, grey_frac));
    frac_blue = (1 - grey_frac)/2;
    frac_red  = frac_blue;

    nB = max(1, round(n*frac_blue));
    nG = max(1, round(n*grey_frac));
    nR = max(1, n - nB - nG);

    blue = [0 0 1];
    grey = [0.85 0.85 0.85];
    red  = [1 0 0];

    % Blue → Grey (ramp)
    part1 = [linspace(blue(1),grey(1),nB)', linspace(blue(2),grey(2),nB)', linspace(blue(3),grey(3),nB)'];
    % Flat Grey band (short)
    part2 = repmat(grey, nG, 1);
    % Grey → Red (ramp)
    part3 = [linspace(grey(1),red(1),nR)', linspace(grey(2),red(2),nR)', linspace(grey(3),red(3),nR)'];

    cmap = [part1; part2; part3];
end
