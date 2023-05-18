%PowerAmplifier Example
%Example of how to use the PowerAmplifier class to model a PA and TX through
%the model.
%
% Author: Chance Tarver
% Website: http://www.chancetarver.com
% July 2018;

%% ------------- BEGIN CODE --------------
clear all, close all, clc;
% Setup the PA
params.order = 7;          % Order must be odd
params.memory_depth = 4;
params.noise_variance = 0;
params.add_lo_leakage = 0;
params.add_iq_imbalance = 0;
pa = PowerAmplifier(params);

% Setup TX Signal
tx_length = 2^17;
ts_tx = 1/40e6;
t = [0:ts_tx:((tx_length - 1) * ts_tx)].';   % Create time vector (Sample Frequency is ts_tx (Hz))
tx_Data = 0.6 * exp(1i*2*pi * 2e6 * t) + 0.2 * exp(1i*2*pi * -3e6 * t);

% Transmit through the PA
rx_Data = pa.transmit(tx_Data);

% Model a new PA based on this fake RX Data.
pa.make_pa_model(tx_Data, rx_Data);
disp('New Coeffs:');
disp(pa.poly_coeffs);

nmse = pa.calculate_nmse(tx_Data, rx_Data);
nmse_dB = 10 * log10(nmse);



fprintf('NMSE of fit: %f dB\n',nmse_dB);

%% Plot the time domain input/output.
% Create figure
figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
plot(real(tx_Data), 'DisplayName', 'TxData');
hold on;
plot(real(rx_Data), 'DisplayName', 'RxData');
xlabel('Sample')
ylabel('Magnitude')
hold on;
legend(gca,'show');
grid on;
xlim(axes1,[-0 500]);
ylim(axes1,[-1 1]);
