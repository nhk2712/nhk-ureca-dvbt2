clear; % clear all variables in the workspace

% Initialization
N = 10^6;           % Number of symbols
M = 16;             % QAM order
k = log2(M);        % Number of bits per symbol
sps = 1;            % Number of samples per symbol (oversampling factor)
rotAngle = pi/2;   % Rotation angle in radians

dataIn = randi([0 1],N*k,1);        % Generate vector of binary data
dataSymbolsIn = bit2int(dataIn,k);  % Convert Binary Data to Integer-Valued Symbols

rayleighchan = comm.RayleighChannel('SampleRate', 1, ...
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
    % snr = ebno + 10*log10((bps*R)/sps);
    % bps = bits per symbol = k
    % R = coding rate = 1 (by default)
    % sps = samples per symbol
    
    % Add Rayleigh fading % Before AWGN
    [fadedSignal, pathgains] = rayleighchan.step(dataMod);
    
    % Add AWGN noise
    % receivedSignal = awgn(dataModRot,snr,'measured');
    noisySignal = awgn(fadedSignal,snr,'measured');
    
    % Undo rotation
    % receivedSignalUnrot = fadedSignal * exp(-1j * rotAngle);

    % Equalize Rayleigh fading, need this before demodulation (remove channel effects)
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
theory_ber = berfading(EbNo, 'qam', M, 1); % theoretical Rayleigh BER

% Plot results
close all
figure
semilogy(EbNo, theory_ber_awgn, 'g*-'); % theoretical AWGN,green asterisks
hold on
semilogy(EbNo, theory_ber, 'b.-'); % theoretical Rayleigh, blue dots
semilogy(EbNo, sim_ber, 'rx-'); % simulated, red crosses
axis([0 16 10^-8 0.5])
grid on
legend('Theoretical AWGN', 'Theoretical Rayleigh', 'Simulated');
xlabel('Eb/N0 (dB)');
ylabel('BER');
title(['BER vs SNR for ', num2str(M), '-QAM in Rayleigh']);