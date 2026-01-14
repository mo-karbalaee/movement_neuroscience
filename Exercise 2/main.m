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
ylabel('Motor Unit Number');

yyaxis right
plot(time, force_signal);
ylabel('Force (N)');

xlim([0, time(end)]);
title('Task 1.1: MU Spike Trains and Force Signal over Time');
xlabel('Time (s)');
grid on;