clear, clc, close all;
% Example input/output data (you should replace these with actual data)
% input_struct = load('C:\Users\j.domingues\Desktop\jdomingues\medidasSinalGeradoKeysight\inputGeradoKeysight_gravadoVSA');
% output_struct = load('C:\Users\j.domingues\Desktop\jdomingues\medidasSinalGeradoKeysight\outputGeradoKeysight_gravadoVSA');
% 
% input_data = input_struct.Y;
% output_data = output_struct.Y;

input_struct = load('C:\Users\j.domingues\OneDrive - Universidade de Aveiro\PhD\Nonlinear System Identification\Trabalho Pratico\x.mat');
output_struct = load('C:\Users\j.domingues\OneDrive - Universidade de Aveiro\PhD\Nonlinear System Identification\Trabalho Pratico\y.mat');
input_struct_val = load('C:\Users\j.domingues\OneDrive - Universidade de Aveiro\PhD\Nonlinear System Identification\Trabalho Pratico\x_val.mat');
output_struct_val = load('C:\Users\j.domingues\OneDrive - Universidade de Aveiro\PhD\Nonlinear System Identification\Trabalho Pratico\y_val.mat');

input_data = input_struct.x;
output_data = output_struct.y;
input_data_val = input_struct_val.x_val;
output_data_val = output_struct_val.y_val;

args = 1;
[P,G] = AMxM(input_data,output_data,args);
Plevel = -60;
condP40_indices = find(P > Plevel);
input_data = input_data(condP40_indices);
output_data = output_data(condP40_indices);
[P,G] = AMxM(input_data,output_data,args);


% Example configuration parameters
params.order = 7;
params.memory_depth = 4;
params.noise_variance = 0;
params.add_lo_leakage = 0;
params.add_iq_imbalance = 0;

% Create the PowerAmplifier object
pa = PowerAmplifier(params);
% Learn the behavioral model
pa = pa.make_pa_model(input_data, output_data);
% Example input signal (replace with actual input signal)

% Simulate the transmission through the learned PA model
output_signal = pa.transmit(input_data);


% Calculate the NMSE
nmse = pa.calculate_nmse(output_data, output_signal);
nmse_dB = 10 * log10(nmse);


% Display the NMSE
fprintf('NMSE: %f\n', nmse_dB);


%% Meu memory polynomials

%Fits weights
[weights,sy] = fitWeights_memory(input_data./max(abs(input_data)),output_data./max(abs(output_data)),9,2)
sigOut_test = evaluateModel_memory(input_data./max(abs(input_data)), weights, sy, orderNonLin,2).*max(abs(output_data));
% [weights,sy] = fitWeights(inputSignal2,outputSignal2,orderNonLin)
% sigOut_test = evaluateModel(inputSignal2, weights, sy, orderNonLin);


NMSE = nmse(output_data,sigOut_test)