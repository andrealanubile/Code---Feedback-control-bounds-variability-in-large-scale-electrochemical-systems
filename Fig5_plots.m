%% ==================== SETUP ====================
clear; clc; close all;



addpath(fullfile('functions/'));
set_plot_defaults_constant_font(14);   % ok if missing


% ---- ONE KNOB for text size (pt) ----
font_size = 14;       % <- change this; labels default to +2

%% ==================== LOAD DATA ====================
load("CapacityPartial.mat");        % -> Capacity_partial
Capacity_full_1 = Capacity_partial ./ (0.9761 - 0.0331); %#ok<NASGU>

load("CapacityPartial_2.mat");    % -> Capacity_partial_C3
Capacity_full_2 = Capacity_partial_C3; %#ok<NASGU>

% OCV → SOC mapping (given)
OCV_25 = [3.328 3.420 3.457 3.505 3.543 3.578 3.599 3.615 3.631 3.650 ...
          3.674 3.723 3.778 3.827 3.877 3.929 3.983 4.040 4.098 4.159 4.228];
SOC    = 0:5:100;

% Compute SOH normalization factors
Q_nom_1 = 244.8*(0.977 - 0.033);
Capacity_partial_SOH = Capacity_partial ./ Q_nom_1;

SOC_down = interp1(OCV_25, SOC, 3.3789) / 100;   % fraction
SOC_up   = interp1(OCV_25, SOC, 4.1941) / 100;   % fraction
Q_nom_2  = 244.8*(SOC_up - SOC_down);
Capacity_partial_SOH_2 = Capacity_partial_C3 ./ Q_nom_2;


%% ==================== COLORS ====================
blue_pastel = [0.65 0.79 0.94];   % scatter points
line_navy   = [0.20 0.35 0.70];   % identity line
% line_grey = [0.55 0.55 0.55];   % (spare neutral)

teal_pastel   = [0.62 0.83 0.78]; % histogram #1
orange_soft   = [0.98 0.72 0.56]; % histogram #2

%% ==================== SCATTER: SOH1 vs SOH2 ====================
xlim_vec = [0.93 0.96];
ylim_vec = [0.93 0.96];

% Prepare data (align lengths, remove NaNs/Infs)
x = Capacity_partial_SOH(:);
y = Capacity_partial_SOH_2(:);
n = min(numel(x), numel(y));
x = x(1:n); y = y(1:n);
mask = isfinite(x) & isfinite(y);
x = x(mask); y = y(mask);

% Interleaved groups by index: 1,4,7 | 2,5,8 | 3,6,9
g1 = 1:3:numel(x);
g2 = 2:3:numel(x);
g3 = 3:3:numel(x);

% Colors (and a fallback for the identity line color)
grp_colors = [0.20 0.45 0.70;   % Group 1
              0.90 0.50 0.30;   % Group 2
              0.30 0.70 0.45];  % Group 3
c1 = grp_colors(1,:); c2 = grp_colors(2,:); c3 = grp_colors(3,:);
if ~exist('line_navy','var'), line_navy = [0.15 0.20 0.30]; end

figS = figure('Color','w'); axS = axes('Parent',figS,'Color','w'); hold(axS,'on')

% Points (three groups)
h1 = scatter(axS, x(g1), y(g1), 36, 'filled', ...
    'MarkerFaceColor', c1, 'MarkerEdgeColor','k', ...
    'MarkerFaceAlpha',0.9, 'MarkerEdgeAlpha',0.4, ...
    'DisplayName','\it Cells Pos 1');

h2 = scatter(axS, x(g2), y(g2), 36, 'filled', ...
    'MarkerFaceColor', c2, 'MarkerEdgeColor','k', ...
    'MarkerFaceAlpha',0.9, 'MarkerEdgeAlpha',0.4, ...
    'DisplayName','\it Cells Pos 2');

h3 = scatter(axS, x(g3), y(g3), 36, 'filled', ...
    'MarkerFaceColor', c3, 'MarkerEdgeColor','k', ...
    'MarkerFaceAlpha',0.9, 'MarkerEdgeAlpha',0.4, ...
    'DisplayName','\it Cells Pos 3');

% Identity line
xx  = linspace(xlim_vec(1), xlim_vec(2), 200);
hId = plot(axS, xx, xx, '-', 'Color', line_navy, 'LineWidth', 1.3, ...
    'DisplayName','y = x');

% Axes / labels / formatting
xlim(axS, xlim_vec); ylim(axS, ylim_vec);
set(axS, 'XTick', linspace(xlim_vec(1), xlim_vec(2), 4), 'XTickMode','manual');
set(axS, 'YTick', linspace(ylim_vec(1), ylim_vec(2), 4), 'YTickMode','manual');
xtickformat(axS, '%.3f'); ytickformat(axS, '%.3f');
axis(axS,'normal');
set(axS,'DataAspectRatioMode','auto','PlotBoxAspectRatioMode','auto');

xlabel(axS, 'SOH @ first testing [-]');
ylabel(axS, 'SOH @ second testing [-]');
set(axS,'TickDir','in','Box','on'); grid(axS,'off')
legend(axS, [h1 h2 h3 hId], 'Location','southeast', 'Box','off', 'Interpreter','tex');

% Keep fonts constant on resize (if your helper exists)
if exist('lock_fonts','file')
    lock_fonts(figS, font_size, font_size+2, font_size, font_size);
end

%% ==================== GROUPED SOH HISTOGRAMS (Style Matched to Resistance Plots) ====================
% This section creates the grouped SOH histograms with styling updated to match
% the appearance of the histograms in the 'plot_resistances_interleaved' function.

% --- Prepare Data & Styles ---
% (Data 'x', 'y' and groups 'g1', 'g2', 'g3' are from the
% 'SCATTER: SOH1 vs SOH2 (3 groups)' section above)

% ---- Colors and darker variants for fits ----
grp_colors = [0.20 0.45 0.70;   % Group 1
              0.90 0.50 0.30;   % Group 2
              0.30 0.70 0.45];  % Group 3

k_dark = 0.65; % Matched to the resistance plot function
dark_grp_colors = grp_colors * k_dark;

% Bins and font size are inherited from previous sections
if ~exist('edges','var'), edges = linspace(0.93, 0.96, 16); end
if ~exist('font_size','var'), font_size = 12; end


%% ---------------- Vertical Grouped Histogram (SOH @ first testing) ----------------
figV_grp = figure('Color','w');
axV_grp  = axes('Parent',figV_grp,'Color','w'); hold(axV_grp,'on');

% Plot the three histograms with matched styling
% 'HandleVisibility','off' prevents these from appearing in the legend
histogram(axV_grp, x(g1), 'BinEdges', edges, 'FaceColor', grp_colors(1,:), ...
    'EdgeColor','k', 'FaceAlpha', 0.45, 'EdgeAlpha', 0.20, 'HandleVisibility','off');

histogram(axV_grp, x(g2), 'BinEdges', edges, 'FaceColor', grp_colors(2,:), ...
    'EdgeColor','k', 'FaceAlpha', 0.45, 'EdgeAlpha', 0.20, 'HandleVisibility','off');

histogram(axV_grp, x(g3), 'BinEdges', edges, 'FaceColor', grp_colors(3,:), ...
    'EdgeColor','k', 'FaceAlpha', 0.45, 'EdgeAlpha', 0.20, 'HandleVisibility','off');

% --- Gaussian fit for each group (these will be in the legend) ---
bin_width  = mode(diff(edges));
xg_fit     = linspace(edges(1), edges(end), 400);

for i = 1:3
    data   = x(g1 + (i-1)); % Cycles through g1, g2, g3
    color  = dark_grp_colors(i,:);
    N      = numel(data);
    mu     = mean(data, 'omitnan');
    sigma  = std(data, 'omitnan');

    if isfinite(sigma) && sigma > eps
        pdf   = (1./(sigma*sqrt(2*pi))) .* exp(-0.5*((xg_fit-mu)/sigma).^2);
        yfit  = N * bin_width * pdf;
        lbl   = sprintf('\\it Cells Pos %d', i); % Legend entry for the fit line
        plot(axV_grp, xg_fit, yfit, '-', 'Color', color, 'LineWidth', 2, 'DisplayName', lbl);
    end
end

% --- Axes Formatting (matched to resistance plots) ---
xlabel(axV_grp,'SOH @ first testing [-]');
ylabel(axV_grp,'Count');
xlim(axV_grp, [0.93 0.96]);
ylim(axV_grp, [0, 36]);  % Fixed upper limit
set(axV_grp,'TickDir','in','Box','on'); grid(axV_grp,'off')
set(axV_grp, 'XTick', linspace(0.93, 0.96, 4));
xtickformat(axV_grp,'%.3f');
set(axV_grp, 'YAxisLocation', 'right'); % Y-axis on the right
legend(axV_grp, 'Location','northwest', 'Box','off', 'Interpreter','tex');

if exist('lock_fonts','file')
    lock_fonts(figV_grp, font_size, font_size+2, font_size, font_size);
end


%% ---------------- Horizontal Grouped Histogram (SOH @ second testing) ----------------
figH_grp = figure('Color','w');
axH_grp  = axes('Parent',figH_grp,'Color','w'); hold(axH_grp,'on');

% Plot the three histograms with matched styling
histogram(axH_grp, y(g1), 'BinEdges', edges, 'FaceColor', grp_colors(1,:), ...
    'EdgeColor','k', 'FaceAlpha', 0.45, 'EdgeAlpha', 0.20, 'Orientation', 'horizontal', 'HandleVisibility','off');

histogram(axH_grp, y(g2), 'BinEdges', edges, 'FaceColor', grp_colors(2,:), ...
    'EdgeColor','k', 'FaceAlpha', 0.45, 'EdgeAlpha', 0.20, 'Orientation', 'horizontal', 'HandleVisibility','off');

histogram(axH_grp, y(g3), 'BinEdges', edges, 'FaceColor', grp_colors(3,:), ...
    'EdgeColor','k', 'FaceAlpha', 0.45, 'EdgeAlpha', 0.20, 'Orientation', 'horizontal', 'HandleVisibility','off');

% --- Gaussian fit for each group ---
yg_fit = linspace(edges(1), edges(end), 400);

for i = 1:3
    data   = y(g1 + (i-1)); % Cycles through g1, g2, g3
    color  = dark_grp_colors(i,:);
    N      = numel(data);
    mu     = mean(data, 'omitnan');
    sigma  = std(data, 'omitnan');

    if isfinite(sigma) && sigma > eps
        pdf   = (1./(sigma*sqrt(2*pi))) .* exp(-0.5*((yg_fit-mu)/sigma).^2);
        xfit  = N * bin_width * pdf;
        lbl   = sprintf('\\it Cells Pos %d', i); % Legend entry for the fit line
        plot(axH_grp, xfit, yg_fit, '-', 'Color', color, 'LineWidth', 2, 'DisplayName', lbl);
    end
end

% --- Axes Formatting (matched to resistance plots) ---
ylabel(axH_grp,'SOH @ second testing [-]');
xlabel(axH_grp,'Count');
ylim(axH_grp, [0.93 0.96]);
xlim(axH_grp, [0, 36]); % Fixed upper limit
set(axH_grp,'TickDir','in','Box','on'); grid(axH_grp,'off')
set(axH_grp, 'YTick', linspace(0.93, 0.96, 4));
ytickformat(axH_grp,'%.3f');
set(axH_grp, 'XAxisLocation', 'top'); % X-axis on top
legend(axH_grp, 'Location','northwest', 'Box','off', 'Interpreter','tex');

if exist('lock_fonts','file')
    lock_fonts(figH_grp, font_size, font_size+2, font_size, font_size);
end

%% ==================== CAPACITY STATISTICS BY GROUP ====================
% This section calculates the mean, standard deviation, min, and max
% for the SOH of each cell group from both the first and second tests.
% The results are stored in three separate tables, one for each group.

% --- Define a helper function for calculating the stats ---
% This anonymous function takes a data vector and returns a 1x4 row of stats
% [mean, std, min, max], ignoring any NaN values.
f_stats = @(data) [mean(data, 'omitnan'), std(data, 'omitnan'), ...
                   min(data, [], 'omitnan'), max(data, [], 'omitnan')];

% --- Define the structure of the output tables ---
rowNames = {'SOH @ first testing', 'SOH @ second testing'};
varNames = {'Mean', 'Std_Dev', 'Min', 'Max'};

% --- Calculate statistics for each group ---
% For each group, we create a 2x4 matrix where:
% Row 1: Stats for the first test (data from 'x')
% Row 2: Stats for the second test (data from 'y')

% Group 1 Statistics
stats_g1 = [f_stats(x(g1)); ...
            f_stats(y(g1))];

% Group 2 Statistics
stats_g2 = [f_stats(x(g2)); ...
            f_stats(y(g2))];

% Group 3 Statistics
stats_g3 = [f_stats(x(g3)); ...
            f_stats(y(g3))];

% --- Create the output tables ---
T_cap_g1 = array2table(stats_g1, 'VariableNames', varNames, 'RowNames', rowNames);
T_cap_g2 = array2table(stats_g2, 'VariableNames', varNames, 'RowNames', rowNames);
T_cap_g3 = array2table(stats_g3, 'VariableNames', varNames, 'RowNames', rowNames);
%% ==================== OCV TRAJECTORIES ====================

load("OCV_GITT.mat")
SOC     = 0:5:100;
OCV_25  = [3.328 3.420 3.457 3.505 3.543 3.578 3.599 3.615 3.631 3.650 ...
           3.674 3.723 3.778 3.827 3.877 3.929 3.983 4.040 4.098 4.159 4.228];

Cell = [97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108];

% --- Pastel palette with golden-angle hues ---
n   = numel(Cell);
phi = 0.61803398875;                 % golden-angle spacing
hue_offset = 0.08;                    % small offset to avoid near-duplicates
H   = mod((0:n-1)'*phi + hue_offset, 1);
S   = 0.34*ones(n,1);                 % keep pastel (low sat)
V   = 0.92*ones(n,1);                 % high value (light)
pastel = hsv2rgb([H S V]);            % [n x 3]

% --- Nudge the most similar pair to be more different (RGB distance) ---
thr = 0.18;                           % min distance (0..1 scale)
best_d = inf; ii = 1; jj = 2;
for a = 1:n
    for b = a+1:n
        d = norm(pastel(a,:) - pastel(b,:));
        if d < best_d, best_d = d; ii = a; jj = b; end
    end
end
if best_d < thr
    hsv = rgb2hsv(pastel(jj,:));
    hsv(1) = mod(hsv(1) + 0.10, 1);   % shift hue
    hsv(2) = min(hsv(2)*1.15, 0.55);  % slightly more saturated
    pastel(jj,:) = hsv2rgb(hsv);
end

% --- Plot ---
fig3 = figure('Color','w'); ax = axes('Parent',fig3,'Color','w'); hold(ax,'on')
plot(SOC, OCV_25, '-', 'Color', [0.20 0.20 0.20], 'LineWidth', 2.0, ...
     'DisplayName','Fresh Cell');

for k = 1:n
    plot(SOC_points{k}, OCV_points{k}, '-', ...
        'Color', pastel(k,:), 'LineWidth', 2, ...
        'DisplayName', sprintf('\\it Cell #%d', Cell(k)));   % no markers
end

xlabel('SOC [%]'); ylabel('OCV [V]');
xlim([0 100]); ytickformat('%g');
legend('Location','northwest','Box','off','NumColumns',3);
set(ax, 'Box','on', 'TickDir','in'); grid(ax,'off');


lock_fonts(fig3, font_size, font_size+2, font_size, font_size);

idx = 1;
for i = 2.5 : 2.5 : 95
    for j = 1 : length(SOC_points)
    
        Voltage_value(idx,j) = interp1(SOC_points{j},OCV_points{j},i);

    end
    idx = idx+1;
end

avg_voltage = mean(Voltage_value,2);

OCV_deviation = [];
for i = 1:length(SOC_points)

    OCV_deviation(i) = mean(abs(avg_voltage-Voltage_value(:,i)));

end


for i = 1 : length(Voltage_value(:,1))-1
    std_voltage(i) = std(Voltage_value(i,:));
end

avg_std = mean(std_voltage)
max_std = max(std_voltage)
min_std = min(std_voltage)
soh_std = std(Capacity_partial_SOH_2(97:108))


%% ==================== RESISTANCES ================
lim_down = 1.6e-1;
lim_up = 2.45e-1;

load("R_table_1.mat")
load("R0dis_vec_SOC90.mat")
load("R0dis_vec_SOC65.mat")
load("R0dis_vec_SOC40.mat")

%% ==================== Resistances v2 — FULL SCRIPT (mΩ) ==================

lim_down = 1.6e-1;    % mΩ
lim_up   = 2.45e-1;   % mΩ
C_rate   = -195.84;   % A
SOC      = 90;        % %
dt       = 0.3;       % s

plot_resistances_interleaved(SOC, dt, C_rate, lim_down, lim_up, font_size)

SOC = 65;
plot_resistances_interleaved(SOC, dt, C_rate, lim_down, lim_up, font_size)

SOC = 40;
plot_resistances_interleaved(SOC, dt, C_rate, lim_down, lim_up, font_size)


%% ==================== HELPERS ====================
function lock_fonts(fig, baseFS, labelFS, legFS, cbFS)
% Keep fonts constant in point units; sizes configurable.
    if nargin==0 || ~ishandle(fig), fig = gcf; end
    % Read defaults if not provided
    if nargin<2 || isempty(baseFS),  baseFS  = get(groot,'DefaultAxesFontSize'); end
    if nargin<3 || isempty(labelFS), labelFS = baseFS + 2; end
    if nargin<4 || isempty(legFS)
        try, legFS = get(groot,'DefaultLegendFontSize'); catch, legFS = baseFS; end
    end
    if nargin<5 || isempty(cbFS)
        try, cbFS = get(groot,'DefaultColorbarFontSize'); catch, cbFS = baseFS; end
    end

    axs = findall(fig,'Type','axes');
    set(axs, 'FontUnits','points', 'FontSize', baseFS);
    for k = 1:numel(axs)
        ax = axs(k);
        if isprop(ax,'XLabel') && isprop(ax.XLabel,'FontUnits')
            ax.XLabel.FontUnits = 'points'; ax.XLabel.FontSize = labelFS;
        end
        if isprop(ax,'YLabel') && isprop(ax.YLabel,'FontUnits')
            ax.YLabel.FontUnits = 'points'; ax.YLabel.FontSize = labelFS;
        end
        if isprop(ax,'Title') && isprop(ax.Title,'FontUnits')
            ax.Title.FontUnits = 'points'; ax.Title.FontSize = labelFS;
        end
    end

    % Legend (older MATLAB: no FontUnits)
    lgd = findobj(fig,'Type','Legend');
    if ~isempty(lgd), set(lgd, 'FontSize', legFS); end

    % Colorbar (older MATLAB: no FontUnits)
    cb = findobj(fig,'Type','ColorBar');
    if ~isempty(cb), set(cb, 'FontSize', cbFS); end
end

function safe_export(fig, base)
% Export to PDF (vector) and PNG (300 dpi) with white background; robust.
    if nargin<2, base='figure'; end
    try
        exportgraphics(fig, [base '.pdf'], 'ContentType','vector');
        exportgraphics(fig, [base '.png'], 'BackgroundColor','w','Resolution',300);
    catch
        % Older MATLAB fallback
        set(fig,'PaperPositionMode','auto');
        print(fig, [base '.pdf'], '-dpdf');              % vector-ish
        print(fig, [base '.png'], '-dpng', '-r300');     % 300 dpi
    end
end


function plot_resistances_interleaved(SOC, dt, C_rate, lim_down, lim_up, font_size)
% plot_resistances_interleaved
%   Splits R-vectors into 3 interleaved groups (1,4,7 | 2,5,8 | 3,6,9),
%   then plots:
%     1) scatter of R0 (first lab) vs R0 (second lab) in mΩ (3 colors)
%     2) vertical histogram of first-lab R0 by group (overlay) + Gaussian fits (ymax=36)
%     3) horizontal histogram of second-lab R0 by group (overlay) + Gaussian fits (ymax=36)
%   Also adds:
%     4) NEW: one figure with 3 overlaid histograms for R1 (vertical, ymax=36)
%     5) NEW: one figure with 3 overlaid histograms for R2 (vertical, ymax=36)
%
% Inputs:
%   SOC, dt, C_rate, lim_down, lim_up, font_size
%
% Notes:
%   - Axis units are mΩ everywhere.
%   - Histogram count upper limit is fixed to 36.
%   - Expects on path: R_table_1.mat, R0dis_vec_SOC40/65/90.mat (R in Ω).

    % ---- Load data
    load("R_table_1.mat");      % R_table.SOC, R_table.I, R_table.dt, R_table.R (Ω)
    load("R0dis_vec_SOC90.mat");
    load("R0dis_vec_SOC65.mat");
    load("R0dis_vec_SOC40.mat");

    % Choose second-lab vector by SOC
    switch SOC
        case 90, R_2 = R0dis_vec_SOC90;
        case 65, R_2 = R0dis_vec_SOC65;
        case 40, R_2 = R0dis_vec_SOC40;
        otherwise
            error('No R0dis_vec available for SOC=%g (expected 40, 65, or 90).', SOC);
    end

    % First-lab selection (Ω) with tolerance on current and exact dt
    R_1 = R_table.R(R_table.SOC == SOC & abs(R_table.I - C_rate) < 1 & R_table.dt == dt);

    % ---- Align & group (indices 1,4,7 | 2,5,8 | 3,6,9)
    R1 = R_1(:);  R2 = R_2(:);
    n  = min(numel(R1), numel(R2));
    R1 = R1(1:n); R2 = R2(1:n);

    g1 = 1:3:n; g2 = 2:3:n; g3 = 3:3:n;

    % ---- Convert to mΩ for plotting (inputs are Ω)
    R1m = R1 * 1000;   % mΩ
    R2m = R2 * 1000;   % mΩ

    % ---- Axes and bins in mΩ
    xlim_m  = [lim_down, lim_up];
    ylim_m  = xlim_m;
    edges_m = linspace(lim_down, lim_up, 16);
    bw      = edges_m(2) - edges_m(1);   % uniform bin width

    % ---- Colors (groups) and darker variants for fits
    grp_colors = [0.20 0.45 0.70;   % Group 1
                  0.90 0.50 0.30;   % Group 2
                  0.30 0.70 0.45];  % Group 3
    c1 = grp_colors(1,:);  c2 = grp_colors(2,:);  c3 = grp_colors(3,:);
    darken = @(c,k) max(min(c*k,1),0);
    c1d = darken(c1,0.65); c2d = darken(c2,0.65); c3d = darken(c3,0.65);
    if ~exist('line_navy','var'), line_navy = [0.15 0.20 0.30]; end

    %% ==================== SCATTER ====================
    fig8 = figure('Color','w'); ax4 = axes('Parent',fig8,'Color','w'); hold(ax4,'on')

    scatter(ax4, R1m(g1), R2m(g1), 36, 'filled', ...
        'MarkerFaceColor', c1, 'MarkerEdgeColor','k', ...
        'MarkerFaceAlpha',0.90, 'MarkerEdgeAlpha',0.40, ...
        'DisplayName','\it Cells Pos 1');

    scatter(ax4, R1m(g2), R2m(g2), 36, 'filled', ...
        'MarkerFaceColor', c2, 'MarkerEdgeColor','k', ...
        'MarkerFaceAlpha',0.90, 'MarkerEdgeAlpha',0.40, ...
        'DisplayName','\it Cells Pos 2');

    scatter(ax4, R1m(g3), R2m(g3), 36, 'filled', ...
        'MarkerFaceColor', c3, 'MarkerEdgeColor','k', ...
        'MarkerFaceAlpha',0.90, 'MarkerEdgeAlpha',0.40, ...
        'DisplayName','\it Cells Pos 3');

    % Identity line
    xx = linspace(xlim_m(1), xlim_m(2), 200);
    plot(ax4, xx, xx, '-', 'Color', line_navy, 'LineWidth', 1.3, 'DisplayName','y = x');

    % Axes / labels
    xlim(ax4, xlim_m); ylim(ax4, ylim_m);
    set(ax4, 'XTick', linspace(xlim_m(1), xlim_m(2), 4), 'XTickMode','manual');
    set(ax4, 'YTick', linspace(ylim_m(1), ylim_m(2), 4), 'YTickMode','manual');
    xtickformat(ax4, '%.3f'); ytickformat(ax4, '%.3f');
    xlabel(ax4, 'R_0 @ first lab test [m\Omega]');
    ylabel(ax4, 'R_0 @ second lab test [m\Omega]');
    set(ax4,'TickDir','in','Box','on'); grid(ax4,'off')
    legend(ax4, 'Location','southeast', 'Box','off', 'Interpreter','tex');

    if exist('lock_fonts','file'), lock_fonts(fig8, font_size, font_size+2, font_size, font_size); end

    %% ==================== HISTOGRAM (vertical, R1m by group — overlay) ====================
    fig9 = figure('Color','w');
    ax7  = axes('Parent',fig9,'Color','w'); hold(ax7,'on')

    histogram(ax7, R1m(g1), 'BinEdges', edges_m, ...
        'FaceColor', c1, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'DisplayName','G1');
    histogram(ax7, R1m(g2), 'BinEdges', edges_m, ...
        'FaceColor', c2, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'DisplayName','G2');
    histogram(ax7, R1m(g3), 'BinEdges', edges_m, ...
        'FaceColor', c3, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'DisplayName','G3');

    xlabel(ax7,'R_0 @ first lab test [m\Omega]');
    ylabel(ax7,'Count');
    xlim(ax7, xlim_m);
    ylim(ax7, [0, 36]);                         % fixed upper limit
    set(ax7,'TickDir','in','Box','on'); grid(ax7,'off')
    set(ax7, 'XTick', linspace(xlim_m(1), xlim_m(2), 4));
    xtickformat(ax7,'%.3f');
    set(ax7, 'YAxisLocation','right');

    % Gaussian overlays per group (scaled to counts)
    xg = linspace(edges_m(1), edges_m(end), 400);
    for k = 1:3
        switch k
            case 1, dat = R1m(g1); col = c1d;
            case 2, dat = R1m(g2); col = c2d;
            case 3, dat = R1m(g3); col = c3d;
        end
        dat = dat(isfinite(dat));
        mu  = mean(dat,'omitnan');
        sg  = std(dat,'omitnan');
        N   = numel(dat);
        if isfinite(sg) && sg > eps
            pdf = (1./(sg*sqrt(2*pi))) .* exp(-0.5*((xg-mu)/sg).^2);
            yft = N * bw * pdf;   % scale to counts
            plot(ax7, xg, yft, '-', 'Color', col, 'LineWidth', 2);
        else
            plot(ax7, [mu mu], ylim(ax7), '-', 'Color', col, 'LineWidth', 2);
        end
    end
    if exist('lock_fonts','file'), lock_fonts(fig9, font_size, font_size+2, font_size, font_size); end

    %% ==================== HISTOGRAM (horizontal, R2m by group — overlay) ====================
    fig10 = figure('Color','w');
    ax8  = axes('Parent',fig10,'Color','w'); hold(ax8,'on')

    histogram(ax8, R2m(g1), 'BinEdges', edges_m, ...
        'FaceColor', c1, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'Orientation','horizontal', 'DisplayName','G1');
    histogram(ax8, R2m(g2), 'BinEdges', edges_m, ...
        'FaceColor', c2, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'Orientation','horizontal', 'DisplayName','G2');
    histogram(ax8, R2m(g3), 'BinEdges', edges_m, ...
        'FaceColor', c3, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'Orientation','horizontal', 'DisplayName','G3');

    ylabel(ax8,'R_0 @ second lab test [m\Omega]');
    xlabel(ax8,'Count');
    ylim(ax8, ylim_m);
    xlim(ax8, [0, 36]);                        % fixed upper limit
    set(ax8,'TickDir','in','Box','on'); grid(ax8,'off')
    set(ax8, 'YTick', linspace(ylim_m(1), ylim_m(2), 4));
    ytickformat(ax8,'%.3f');
    set(ax8, 'XAxisLocation','top');

    % Horizontal Gaussian overlays per group (scaled to counts)
    yg = linspace(edges_m(1), edges_m(end), 400);
    for k = 1:3
        switch k
            case 1, dat = R2m(g1); col = c1d;
            case 2, dat = R2m(g2); col = c2d;
            case 3, dat = R2m(g3); col = c3d;
        end
        dat = dat(isfinite(dat));
        mu  = mean(dat,'omitnan'); sg = std(dat,'omitnan'); N = numel(dat);
        if isfinite(sg) && sg > eps
            pdf  = (1./(sg*sqrt(2*pi))) .* exp(-0.5*((yg-mu)/sg).^2);
            xfit = N * bw * pdf;   % counts
            plot(ax8, xfit, yg, '-', 'Color', col, 'LineWidth', 2);
        else
            plot(ax8, xlim(ax8), [mu mu], '-', 'Color', col, 'LineWidth', 2);
        end
    end
    if exist('lock_fonts','file'), lock_fonts(fig10, font_size, font_size+2, font_size, font_size); end

    %% ==================== NEW FIGURE: R1 (3 overlaid histograms, vertical) ====================
    fig11 = figure('Color','w');
    ax9  = axes('Parent',fig11,'Color','w'); hold(ax9,'on')

    histogram(ax9, R1m(g1), 'BinEdges', edges_m, ...
        'FaceColor', c1, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'HandleVisibility','off');
    histogram(ax9, R1m(g2), 'BinEdges', edges_m, ...
        'FaceColor', c2, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'HandleVisibility','off');
    histogram(ax9, R1m(g3), 'BinEdges', edges_m, ...
        'FaceColor', c3, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'HandleVisibility','off');

    % Gaussian overlays
    for k = 1:3
        switch k
            case 1, dat = R1m(g1); col = c1d;
            case 2, dat = R1m(g2); col = c2d;
            case 3, dat = R1m(g3); col = c3d;
        end
        dat = dat(isfinite(dat)); mu = mean(dat,'omitnan'); sg = std(dat,'omitnan'); N = numel(dat);
        if isfinite(sg) && sg > eps
            pdf = (1./(sg*sqrt(2*pi))) .* exp(-0.5*((xg-mu)/sg).^2);
            yft = N * bw * pdf;
            lbl = sprintf('\\it Cells Pos %d', k);   % yields "\it Cells Pos 1"
            plot(ax9, xg, yft, '-', 'Color', col, 'LineWidth', 2, 'DisplayName',lbl);
        end
    end

    xlabel(ax9,'R_0 @ first lab test [m\Omega]'); ylabel(ax9,'Count');
    xlim(ax9, xlim_m); ylim(ax9, [0, 20]);
    set(ax9,'TickDir','in','Box','on'); grid(ax9,'off')
    set(ax9, 'XTick', linspace(xlim_m(1), xlim_m(2), 4)); xtickformat(ax9,'%.3f');
    legend(ax9, 'Location','northoutside', 'Orientation','horizontal', ...
             'NumColumns',3, 'Interpreter','tex', 'Box','off');
    if exist('lock_fonts','file'), lock_fonts(fig11, font_size, font_size+2, font_size, font_size); end

    %% ==================== NEW FIGURE: R2 (3 overlaid histograms, vertical) ====================
    fig12 = figure('Color','w');
    ax10  = axes('Parent',fig12,'Color','w'); hold(ax10,'on')

    histogram(ax10, R2m(g1), 'BinEdges', edges_m, ...
        'FaceColor', c1, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'HandleVisibility','off');
    histogram(ax10, R2m(g2), 'BinEdges', edges_m, ...
        'FaceColor', c2, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'HandleVisibility','off');
    histogram(ax10, R2m(g3), 'BinEdges', edges_m, ...
        'FaceColor', c3, 'EdgeColor','k', 'FaceAlpha',0.45, 'EdgeAlpha',0.20, ...
        'Normalization','count', 'HandleVisibility','off');

    % Gaussian overlays
    for k = 1:3
        switch k
            case 1, dat = R2m(g1); col = c1d;
            case 2, dat = R2m(g2); col = c2d;
            case 3, dat = R2m(g3); col = c3d;
        end
        dat = dat(isfinite(dat)); mu = mean(dat,'omitnan'); sg = std(dat,'omitnan'); N = numel(dat);
        if isfinite(sg) && sg > eps
            pdf = (1./(sg*sqrt(2*pi))) .* exp(-0.5*((xg-mu)/sg).^2);
            yft = N * bw * pdf;
            lbl = sprintf('\\it Cells Pos %d', k);   % yields "\it Cells Pos 1"
            plot(ax10, xg, yft, '-', 'Color', col, 'LineWidth', 2, 'DisplayName',lbl);
        end
    end

    xlabel(ax10,'R_0 @ second lab test [m\Omega]'); ylabel(ax10,'Count');
    xlim(ax10, xlim_m); ylim(ax10, [0, 20]);
    set(ax10,'TickDir','in','Box','on'); grid(ax10,'off')
    set(ax10, 'XTick', linspace(xlim_m(1), xlim_m(2), 4)); xtickformat(ax10,'%.3f');
    legend(ax10, 'Location','northoutside', 'Orientation','horizontal', ...
             'NumColumns',3, 'Interpreter','tex', 'Box','off');
    if exist('lock_fonts','file'), lock_fonts(fig12, font_size, font_size+2, font_size, font_size); end
end


function [Tg1,Tg2,Tg3] = resistance_stats_by_group(dt, C_rate)
% resistance_stats_by_group
% Returns 3 tables (g1,g2,g3). Each table has:
%   - 2 rows: First Lab Test, Second Lab Test
%   - columns: for each SOC in {40,65,90} -> mean, std, min, max
% Units: mΩ

    % ---- Load data (Ω)
    load("R_table_1.mat","R_table");
    load("R0dis_vec_SOC90.mat","R0dis_vec_SOC90");
    load("R0dis_vec_SOC65.mat","R0dis_vec_SOC65");
    load("R0dis_vec_SOC40.mat","R0dis_vec_SOC40");

    SOCs = [40 65 90];
    rowNames = {'First Lab Test','Second Lab Test'};

    % Preallocate numeric blocks: 2 rows x (3 SOC * 4 stats) = 12 columns
    G1 = nan(2, numel(SOCs)*4);
    G2 = nan(2, numel(SOCs)*4);
    G3 = nan(2, numel(SOCs)*4);

    varNames = strings(1, numel(SOCs)*4);
    c = 1;

    for s = 1:numel(SOCs)
        SOC = SOCs(s);

        % Second-lab vector by SOC (Ω)
        switch SOC
            case 90, R_2 = R0dis_vec_SOC90;
            case 65, R_2 = R0dis_vec_SOC65;
            case 40, R_2 = R0dis_vec_SOC40;
        end

        % First-lab selection (Ω)
        R_1 = R_table.R(R_table.SOC == SOC & abs(R_table.I - C_rate) < 1 & R_table.dt == dt);

        % Align, group
        R1 = R_1(:); R2 = R_2(:);
        n = min(numel(R1), numel(R2));
        R1 = R1(1:n); R2 = R2(1:n);

        g1 = 1:3:n; g2 = 2:3:n; g3 = 3:3:n;

        % Convert to mΩ
        R1m = 1000*R1;  R2m = 1000*R2;

        % helper: [mean std min max] with NaN safety
        fstats = @(x) local_stats(x);

        % Stats per group, per test (row1=lab1, row2=lab2)
        G1(:,c:c+3) = [fstats(R1m(g1)); fstats(R2m(g1))];
        G2(:,c:c+3) = [fstats(R1m(g2)); fstats(R2m(g2))];
        G3(:,c:c+3) = [fstats(R1m(g3)); fstats(R2m(g3))];

        % Variable names
        varNames(c+0) = "SOC"+SOC+"_mean";
        varNames(c+1) = "SOC"+SOC+"_std";
        varNames(c+2) = "SOC"+SOC+"_min";
        varNames(c+3) = "SOC"+SOC+"_max";

        c = c + 4;
    end

    Tg1 = array2table(G1, 'VariableNames', cellstr(varNames), 'RowNames', rowNames);
    Tg2 = array2table(G2, 'VariableNames', cellstr(varNames), 'RowNames', rowNames);
    Tg3 = array2table(G3, 'VariableNames', cellstr(varNames), 'RowNames', rowNames);
end

function s = local_stats(x)
% returns [mean std min max] for finite values; NaNs if empty
    x = x(isfinite(x));
    if isempty(x)
        s = [nan nan nan nan];
    else
        s = [mean(x,'omitnan'), std(x,'omitnan'), min(x), max(x)];
    end
end