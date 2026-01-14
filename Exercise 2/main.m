%Task 1.1: MU Spike Trains and Force Signal over Time%

load('iEMG_contraction.mat');
numSamples = length(force_signal);
time = (0:numSamples-1) / fsamp;
MUPulses_sec = cell(size(MUPulses));
for i = 1:length(MUPulses)
    MUPulses_sec{i} = (double(MUPulses{i}) - 1) / fsamp;
end
figure;
yyaxis left
plotSpikeRaster(MUPulses_sec, 'PlotType', 'vertline', 'VertSpikeHeight', 0.9);
set(gca, 'YDir', 'normal');
ylabel('Motor Unit Number');
yyaxis right
plot(time, force_signal);
ylabel('Force (N)');
xlim([0, time(end)]);
title('Task 1.1: MU Spike Trains and Force Signal over Time');
xlabel('Time (s)');
grid on;

%Task 1.2: Sorted MU Spike Trains and Force Signal%

numSamples = length(force_signal);
time = (0:numSamples-1) / fsamp;

first_firing_samples = cellfun(@min, MUPulses);
[~, sortIdx] = sort(first_firing_samples, 'ascend');
MUPulses_sorted = MUPulses(sortIdx);

MUPulses_sec_sorted = cell(size(MUPulses_sorted));
for i = 1:length(MUPulses_sorted)
    MUPulses_sec_sorted{i} = (double(MUPulses_sorted{i}) - 1) / fsamp;
end

figure;

yyaxis left
plotSpikeRaster(MUPulses_sec_sorted, 'PlotType', 'vertline', 'VertSpikeHeight', 0.9);
set(gca, 'YDir', 'normal');
ylabel('Motor Unit Number (Sorted by Recruitment)');
ylim([0, length(MUPulses_sorted) + 1]);

yyaxis right
plot(time, force_signal);
ylabel('Force (N)');

title('Task 1.2: Sorted MU Spike Trains and Force Signal');
xlabel('Time (s)');
xlim([0, time(end)]);
grid on;


% Task 1.3: Instantaneous Discharge Rate of Two MUs and Force Signal %

mu_idx1 = 1; 
mu_idx2 = 2;

spikes1_sec = (double(MUPulses_sorted{mu_idx1}) - 1) / fsamp;
idr1 = 1 ./ diff(spikes1_sec);
time_idr1 = spikes1_sec(1:end-1);

spikes2_sec = (double(MUPulses_sorted{mu_idx2}) - 1) / fsamp;
idr2 = 1 ./ diff(spikes2_sec);
time_idr2 = spikes2_sec(1:end-1);

figure;
yyaxis left
h1 = scatter(time_idr1, idr1, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
hold on;
h2 = scatter(time_idr2, idr2, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
ylabel('Discharge Rate (Hz)');

yyaxis right
h3 = plot(time, force_signal, 'Color', [0 0.5 0], 'LineWidth', 1.5);
ylabel('Force (N)');
ax = gca;
ax.YAxis(2).Color = [0 0.5 0]; 

xlim([0, time(end)]);
title('Task 1.3: Instantaneous Discharge Rate of Two MUs and Force Signal');
xlabel('Time (s)');
legend([h1, h2, h3], {'MU #1', 'MU #2', 'Force Signal'}, 'Location', 'northeast');
grid on;


%Task 2.1: MUAP Shapes for 16 Channels%

mu_to_plot = 1; 
mu_data_cell = STA_cell_output{mu_to_plot}; 

muap_shapes = zeros(16, length(mu_data_cell{1,1}));
muap_shapes(1:8, :) = cell2mat(mu_data_cell(:,1)); 
muap_shapes(9:16, :) = cell2mat(mu_data_cell(:,2));

y_min = min(muap_shapes, [], 'all');
y_max = max(muap_shapes, [], 'all');

sta_samples = size(muap_shapes, 2);
sta_time = ((0:sta_samples-1) - floor(sta_samples/2)) / fsamp;

figure('Units', 'normalized', 'Position', [0.3, 0.05, 0.3, 0.85]);

for ch = 1:16
    subplot(16, 1, 17-ch); 
    plot(sta_time * 1000, muap_shapes(ch, :));
    ylim([y_min, y_max]);
    
    grid on;
    ylabel(['E', num2str(ch)], 'Rotation', 0, 'HorizontalAlignment', 'right');
    
    yticks([round(y_min, 1), 0, round(y_max, 1)]);
    set(gca, 'FontSize', 7);
    
    if ch > 1
        set(gca, 'XTickLabel', []);
    else
        xlabel('Time (ms)');
    end
end
sgtitle(['Task 2.1: MUAP Shapes for 16 Channels (MU #', num2str(mu_to_plot), ')']);


%Task 3.1: Use the highest peak-to-peak value from all channels%

num_total_MUs = length(MUPulses_sorted);
ptp_amplitudes = zeros(num_total_MUs, 1);

for mu = 1:num_total_MUs
    mu_cell = STA_cell_output{mu};
    
    mu_array = [cell2mat(mu_cell(:,1)); cell2mat(mu_cell(:,2))];
    
    ch_ptp = max(mu_array, [], 2) - min(mu_array, [], 2);
    
    ptp_amplitudes(mu) = max(ch_ptp);
end

%Task 3.2: Task 3.2: MUAP Amplitude vs. Recruitment Order%


recruitment_order = 1:length(ptp_amplitudes);

figure;
scatter(recruitment_order, ptp_amplitudes, 'filled', 'MarkerFaceColor', 'b');
hold on;

mdl = fitlm(recruitment_order, ptp_amplitudes);
plot(recruitment_order, mdl.Fitted, 'r', 'LineWidth', 1.5);

r_squared = mdl.Rsquared.Ordinary;
title(['Task 3.2: MUAP Amplitude vs. Recruitment Order (R^2 = ', num2str(r_squared, '%.3f'), ')']);
xlabel('Physiological Recruitment Order (Sorted)');
ylabel('Max Peak-to-Peak Amplitude (mV)');
legend('Motor Units', 'Linear Regression');
grid on;

fprintf('The R^2 value for Task 3.2 is: %.4f\n', r_squared);