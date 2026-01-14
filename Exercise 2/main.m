%Task 1%

load('iEMG_contraction.mat'); 

% Task 1.1: MU Spike Trains and Force Signal %

numMUs = length(MUPulses);
numSamples = length(force_signal);
firingMatrix = false(numMUs, numSamples);

for i = 1:numMUs
    firingMatrix(i, MUPulses{i}) = true;
end

time_vec = (0:numSamples-1) / fsamp;

figure;
hold on;

yyaxis left;
plotSpikeRaster(firingMatrix, 'PlotType', 'vertline', 'VertSpikeHeight', 0.9);
ylabel('Motor Unit Number');
ylim([0.5 numMUs + 0.5]);
set(gca, 'YDir', 'normal');

yyaxis right;
plot(time_vec, force_signal);
ylabel('Force (N)');

xlabel('Time (s)');
title('Task 1.1: MU Spike Trains and Force Signal');
grid on;