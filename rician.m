clear; % clear all variables in the workspace

% Initialization
N = 10^6;           % Number of symbols
M = 16;             % QAM order
k = log2(M);        % Number of bits per symbol
sps = 1;            % Number of samples per symbol (oversampling factor)
rotAngle = pi/2;   % Rotation angle in radians
Kfactor = 17;        % Rician fading channel K factor

dataIn = randi([0 1],N*k,1);        % Generate vector of binary data
dataSymbolsIn = bit2int(dataIn,k);  % Convert Binary Data to Integer-Valued Symbols

ricianchan = comm.RicianChannel('KFactor',Kfactor,...
    'SampleRate', 1, ...
    'PathDelays', [0], ...
    'AveragePathGains', [0],...
    'PathGainsOutputPort', true); % Create Rayleigh fading channel

% Modulation
dataMod = qammod(dataSymbolsIn,M,'bin'); % Binary-encoded
% dataModRot = dataMod * exp(1j * rotAngle); % rotated = modulated * e^(j*angle), j is imaginary

EbNo = [0:16];
sim_ber = zeros(1, length(EbNo));

for ii = 1:length(EbNo)
    snr = convertSNR(EbNo(ii),'ebno', samplespersymbol=sps, bitspersymbol=k);
    
    % Add Rician fading
    [fadedSignal, pathgains] = ricianchan.step(dataMod);
    
    % Add AWGN noise
    % receivedSignal = awgn(dataModRot,snr,'measured');
    noisySignal = awgn(fadedSignal,snr,'measured');
    
    % Undo rotation
    % receivedSignalUnrot = fadedSignal * exp(-1j * rotAngle);

    % Equalize Rician fading, need this before demodulation (remove channel effects)
    equalizedSignal = noisySignal ./ pathgains;
    
    % Demodulation
    % dataSymbolsOut = qamdemod(receivedSignalUnrot,M,'bin'); % Binary-encoded data symbols
    dataSymbolsOut = qamdemod(equalizedSignal,M,'bin'); % Binary-encoded data symbols
    
    dataOut = int2bit(dataSymbolsOut,k); % Convert Integer-Valued Symbols to Binary Data
    [numErrors,ber] = biterr(dataIn,dataOut);
    
    sim_ber(ii) = ber; % simulated BER
end

% Calculate bit error
theory_ber_awgn = berawgn(EbNo, 'qam', M); % theoretical AWGN BER
theory_ber_rayleigh = berfading(EbNo, 'qam', M, 1); % theoretical Rayleigh BER
theory_ber = berfading(EbNo, 'qam', M, 1, Kfactor); % theoretical Rician BER, should lie between AWGN and Rayleigh

% Plot results
close all
figure
semilogy(EbNo, theory_ber_awgn, 'g*-'); % theoretical AWGN, green asterisks
hold on
semilogy(EbNo, theory_ber_rayleigh, 'm*-'); % theoretical Rayleigh, magenta asterisks
semilogy(EbNo, theory_ber, 'b.-'); % theoretical Rician, blue dots
semilogy(EbNo, sim_ber, 'rx-'); % simulated, red crosses
axis([0 16 10^-8 0.5])
grid on
legend('Theoretical AWGN', 'Theoretical Rayleigh', 'Theoretical Rician', 'Simulated');
xlabel('Eb/N0 (dB)');
ylabel('BER');
title(['BER vs SNR for ', num2str(M), '-QAM in Rician with K-factor of ', num2str(Kfactor)]);