load('iEMG_contraction.mat');

numSamples = length(force_signal);
time = (0:numSamples-1) / fsamp;

figure;
plot(time, force_signal);
title('Task 1.1: Force Signal over Time');
xlabel('Time (s)');
ylabel('Force (N)');
grid on;

% Convert sample indices to seconds for each motor unit
MUPulses_sec = cell(size(MUPulses));
for i = 1:length(MUPulses)
    MUPulses_sec{i} = (double(MUPulses{i}) - 1) / fsamp;
end

% Plot using the cell array of times
figure;
plotSpikeRaster(MUPulses_sec, 'PlotType', 'vertline', 'VertSpikeHeight', 0.9);
title('Task 1.1: Motor Unit Spike Trains');
xlabel('Time (s)');
ylabel('Motor Unit Number');