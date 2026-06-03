clear all
close all
clc
%% Add path

addpath('functions')
addpath('variables')
set_plot_style;


load('Mileage.mat')
sel = Mileage_collection(:,2)>0;

%% Mileage with different colors according to the data aqusition/lab testing

% Use only positive-mileage samples (keep original units in Km)
sel = Mileage_collection(:,2) > 0;
d = dates_driving(sel);
y = Mileage_collection(sel,2);  % keep full km values

% Ensure datetime and sort
if ~isdatetime(d), d = datetime(d); end
[d, order] = sort(d);
y = y(order)/1000;

% Find break indices where gap > 2 calendar months
breaks = find(d(2:end) > d(1:end-1) + calmonths(2));
break_idx = [0, breaks(:).', numel(d)];

% Colors
blue  = [0 0.45 0.74];
green = [0 0.6 0];

% Plot
figure; hold on
lw = 5;

for i = 1:numel(break_idx)-1
    idx  = (break_idx(i)+1) : break_idx(i+1);
    dseg = d(idx);
    yseg = y(idx);

    % Blue filled area under the segment
    hA = area(dseg, yseg);
    set(hA, 'FaceColor', blue, 'FaceAlpha', 0.15, 'EdgeColor', 'none');

    % Blue line on top
    plot(dseg, yseg, 'Color', blue, 'LineWidth', lw);

    % If there is a following segment, add the green constant section
    if i < numel(break_idx)-1
        t0 = dseg(end);
        y0 = yseg(end);
        t1 = d(break_idx(i+1)+1);

        % Green filled area for the gap
        hG = area([t0 t1], [y0 y0]);
        set(hG, 'FaceColor', green, 'FaceAlpha', 0.2, 'EdgeColor', 'none');

        % Green constant line
        plot([t0 t1], [y0 y0], 'Color', green, 'LineWidth', lw);
    end
end

% === Extend green constant to end of August 2025 ===
endDate = datetime(2025,8,31);
t_last  = d(end);
y_last  = y(end);

if t_last < endDate
    hG2 = area([t_last endDate], [y_last y_last]);
    set(hG2, 'FaceColor', green, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    plot([t_last endDate], [y_last y_last], 'Color', green, 'LineWidth', lw);
end

% === Axis formatting: show in ×10³ km without changing data ===
% ax = gca;
% ax.YRuler.Exponent = 0;                 % no scientific notation
% ax.YTickLabel = string(ax.YTick/1000);  % show thousands of km
ylabel('Driven Distance [\times10^3 km]')
% 
% % Keep labels correct after zoom/pan
% z = zoom(gcf);
% p = pan(gcf);
% upd = @(~,~) set(ax, 'YTickLabel', string(ax.YTick/1000));
% z.ActionPostCallback = upd;
% p.ActionPostCallback = upd;

grid off; box on; set(gca,'TickDir','in')
