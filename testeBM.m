clear, clc, close all;

addpath(genpath(fullfile('..')))
%% Docked figures 
% Create docked group and figure handles
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
myGroup = desktop.addGroup('myGroup');
desktop.setGroupDocked('myGroup', 0);
myDim   = java.awt.Dimension(1, 1);   % 2 columns, 1 rows
desktop.setDocumentArrangement('myGroup', 2, myDim)
figH    = gobjects(1, 7);
warning("off");
% bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
% for iFig = 90:110
%    figH(iFig) = figure('WindowStyle', 'docked', ...
%       'Name', sprintf('Figure %d', iFig), 'NumberTitle', 'off');
% %    drawnow;
% %    pause(0.02);  % Magic, reduces rendering errors
%    set(get(handle(figH(iFig)), 'javaframe'), 'GroupName', 'myGroup');
% end


%% Example input/output data (you should replace these with actual data)
% input_struct = load('..\..\A_medicoesJD\jdomingues\medidasSinalGeradoKeysight\inputGeradoKeysight_gravadoSA10dBm');
% output_struct = load('..\..\A_medicoesJD\jdomingues\medidasSinalGeradoKeysight\outputGeradoKeysight_gravadoSA10dBm');

input_struct = load('C:\Users\jdomingues\Desktop\A_medicoesJD\inputPA\iq_5_0GHz.mat');
output_struct = load('C:\Users\jdomingues\Desktop\A_medicoesJD\Vdd4_5\iq_100MHz_fc5GHz_vdd4_5_0dbm.mat');

input_data_dirty = input_struct.Y./(max(abs(input_struct.Y)));
output_data_dirty = output_struct.Y./(max(abs(output_struct.Y)));


for lag = 0

% Sync the dirty signal with the reference signal
input_data = waveformSync(input_data_dirty,0);
output_data = waveformSync(output_data_dirty,-(lag));

% Calculate the time shift, lag, and cross-correlation between the corrected signal and the clean reference signal
[t_out_to_in_new,lag_out_to_in_new,C_out_to_in_new] = signalLagLead(output_data,input_data);



args = lag+100;
[P,G] = AMxM(input_data,output_data,args);

figH(args) = figure('WindowStyle', 'docked', ...
  'Name', sprintf('Figure %d', args), 'NumberTitle', 'off');
drawnow;
pause(0.02);  % Magic, reduces rendering errors
set(get(handle(figH(args)), 'javaframe'), 'GroupName', 'myGroup');


ax = gca;
plot(ax,P,20*log10(abs(G)),".")
grid(ax,'on');
hold(ax,'on');
ax.XLabel.String = 'Input Power (dBm)';
ax.YLabel.String = 'AMAM (dB)';
movegui('northwest');
    




Plevel = -20;
condP40_indices = find(P > Plevel);
input_data = input_data(condP40_indices);
output_data = output_data(condP40_indices);
[P,G] = AMxM(input_data,output_data,args);
plot(ax,P,20*log10(abs(G)),".")


% Example configuration parameters
params.order = 7;
params.memory_depth = 4;
params.noise_variance = 0;
params.add_lo_leakage = 0;
params.add_iq_imbalance = 0;

tic
% Create the PowerAmplifier object
pa = PowerAmplifier(params);
% Learn the behavioral model
pa = pa.make_pa_model(input_data, output_data);
output_signal = pa.transmit(input_data);
toc
% Calculate the NMSE
nmse = pa.calculate_nmse(output_data, output_signal);
nmse_dB = 10 * log10(nmse);


% Display the NMSE
fprintf('NMSE: %f\n', nmse_dB);


%% Meu memory polynomials

tic
%Fits weights
% [weights,sy] = fitWeights_memory(input_data./max(abs(input_data)),output_data./max(abs(output_data)),5,2);
% sigOut_test = evaluateModel_memory(input_data./max(abs(input_data)), weights, sy, 5,2).*max(abs(output_data));
[weights,sy] = fitWeights_memory(input_data,output_data,7,1);
sigOut_test = evaluateModel_memory(input_data, weights, sy, 7,1);
% [weights,sy] = fitWeights(inputSignal2,outputSignal2,orderNonLin)
% sigOut_test = evaluateModel(inputSignal2, weights, sy, orderNonLin);

toc

% Calculate the NMSE
% nmse = nmse(output_data, sigOut_test);

nmse = norm(output_data - sigOut_test)^2 / norm(output_data)^2;
nmse_dB = 10 * log10(nmse);

fprintf('NMSE: %f\n', nmse_dB);


% [P,G] = AMxM(input_data,output_signal,args);
[P,G] = AMxM(input_data,sigOut_test,args);
plot(ax,P,20*log10(abs(G)),".")
legend('Lab Measures','Lab Measures - Above Plevel','PA_{model} Memory Polynomial');
title(['NMSE = ' num2str(nmse_dB)])
end
warning("on")

figure('units','normalized','WindowState','maximized')
plot(abs(input_data),'-+')
hold on
plot(abs(output_data),'-x')
plot(abs(sigOut_test),'-o')
legend('Input PA','Output PA','Output BM PA')
grid on;
title(['NMSE = ' num2str(nmse_dB)])
axis([1.22875e6 1.228975e6 0 2.5])