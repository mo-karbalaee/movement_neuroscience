load('iEMG_contraction.mat'); 

numMUs = size(MUPulses, 1);
numSamples = length(force_signal);
time_vec = (0:numSamples-1) / fsamp;

MUPulses_Seconds = cell(numMUs, 1);
for i = 1:numMUs
    MUPulses_Seconds{i} = MUPulses{i} / fsamp;
end

figure;

yyaxis left;
plotSpikeRaster(MUPulses_Seconds, 'PlotType', 'vertline', 'VertSpikeHeight', 0.9);
ylabel('Motor Unit Number');
ylim([0.5 numMUs + 0.5]);

yyaxis right;
plot(time_vec, force_signal);
ylabel('Force (N)');

xlabel('Time (s)');
title('Task 1.1: MU Spike Trains and Force Signal');
grid on;