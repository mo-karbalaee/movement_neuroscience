%% Task 1: Discharge Timings and Force Signal

%%% Task 1.1: Spike Trains and Force (All MUs)
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

%%% Task 1.2: Sorted Spike Trains (Recruitment Order)
% Determine recruitment order (first firing)
first_firing_samples = cellfun(@min, MUPulses);
[~, sortIdx] = sort(first_firing_samples, 'ascend');
MUPulses_sorted = MUPulses(sortIdx); % Use this from now on

MUPulses_sec_sorted = cell(size(MUPulses_sorted));
for i = 1:length(MUPulses_sorted)
    MUPulses_sec_sorted{i} = (double(MUPulses_sorted{i}) - 1) / fsamp;
end

figure;
yyaxis left
plotSpikeRaster(MUPulses_sec_sorted, 'PlotType', 'vertline', 'VertSpikeHeight', 0.9);
set(gca, 'YDir', 'normal');
ylabel('Motor Unit Number (Sorted)');
yyaxis right
plot(time, force_signal);
ylabel('Force (N)');
xlim([0, time(end)]);
title('Task 1.2: Sorted MU Spike Trains and Force Signal');
grid on;

%%% Task 1.3: Instantaneous Discharge Rate (IDR)
% Plotting the first two sorted MUs
mu_idx1 = 1; mu_idx2 = 2;
spikes1_sec = (double(MUPulses_sorted{mu_idx1}) - 1) / fsamp;
idr1 = 1 ./ diff(spikes1_sec);
spikes2_sec = (double(MUPulses_sorted{mu_idx2}) - 1) / fsamp;
idr2 = 1 ./ diff(spikes2_sec);

figure;
yyaxis left
h1 = scatter(spikes1_sec(1:end-1), idr1, 'filled', 'MarkerFaceColor', 'b'); hold on;
h2 = scatter(spikes2_sec(1:end-1), idr2, 'filled', 'MarkerFaceColor', 'r');
ylabel('Discharge Rate (Hz)');
yyaxis right
h3 = plot(time, force_signal, 'Color', [0 0.5 0], 'LineWidth', 1.5);
ylabel('Force (N)');
ax = gca; ax.YAxis(2).Color = [0 0.5 0];
legend([h1, h2, h3], {['MU ' num2str(mu_idx1)], ['MU ' num2str(mu_idx2)], 'Force'}, 'Location', 'northeast');
title('Task 1.3: IDR and Force Signal');
xlim([0, time(end)]);
grid on;

%% Task 2: Spike Triggered Averaging (STA)

%%% Task 2.1: MUAP Shapes (16 Channels)
STA_window_sec = 0.050; 
[STA_cell_output] = spikeTriggeredAveraging(EMGSig, MUPulses_sorted, STA_window_sec, fsamp);

mu_to_plot = 1; 
mu_data_cell = STA_cell_output{mu_to_plot}; 
muap_shapes = [cell2mat(mu_data_cell(:,1)); cell2mat(mu_data_cell(:,2))];

y_min = min(muap_shapes, [], 'all'); y_max = max(muap_shapes, [], 'all');
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
    if ch > 1, set(gca, 'XTickLabel', []); else, xlabel('Time (ms)'); end
end
sgtitle(['Task 2.1: MUAP Shapes (MU ' num2str(mu_to_plot) ')']);

%% Task 3: Amplitude Analysis

%%% Task 3.1: Calculate Max Peak-to-Peak
num_total_MUs = length(MUPulses_sorted);
ptp_muap = zeros(num_total_MUs, 1); % Variable name updated per tips

for mu = 1:num_total_MUs
    mu_cell = STA_cell_output{mu};
    mu_array = [cell2mat(mu_cell(:,1)); cell2mat(mu_cell(:,2))];
    ch_ptp = max(mu_array, [], 2) - min(mu_array, [], 2);
    ptp_muap(mu) = max(ch_ptp);
end

%%% Task 3.2: Regression Plot
recruitment_order = (1:num_total_MUs)';
figure;
scatter(recruitment_order, ptp_muap, 'filled', 'MarkerFaceColor', 'b'); hold on;
mdl = fitlm(recruitment_order, ptp_muap);
plot(recruitment_order, mdl.Fitted, 'r', 'LineWidth', 1.5);
title(['Task 3.2: Amplitude vs. Recruitment (R^2 = ' num2str(mdl.Rsquared.Ordinary, '%.3f') ')']);
xlabel('Recruitment Order'); ylabel('Max P2P Amplitude (mV)');
grid on;

%% Task 4: Spatial Distribution

%%% Task 4.1: Compute RMS Matrix
rms_muap = zeros(16, num_total_MUs); % Variable name updated per tips
for mu = 1:num_total_MUs
    mu_cell = STA_cell_output{mu};
    mu_array = [cell2mat(mu_cell(:,1)); cell2mat(mu_cell(:,2))];
    for ch = 1:16
        rms_muap(ch, mu) = rms(mu_array(ch, :));
    end
end

%%% Task 4.2: Heatmap Plot
figure;
imagesc(1:num_total_MUs, 1:16, rms_muap);
set(gca, 'YDir', 'normal'); 
colorbar; colormap('parula'); 
title('Task 4.2: MU Spatial Location Heatmap');
xlabel('Sorted Motor Unit'); ylabel('Electrode Channel');
xticks(1:num_total_MUs); yticks(1:16);
grid on;