clear; % clear all variables in the workspace

% Initialization
EbNo = [0:16];      % Eb/N0 vector
M = 16;             % QAM order
rotAngle = pi/2;    % Rotation angle in radians

sim_ber = awgn_qam(EbNo, M, rotAngle);

% Calculate bit error
theory_ber = berawgn(EbNo, 'qam', M); % theoretical

% Plot results
close all
figure
semilogy(EbNo, theory_ber, 'b.-'); % theoretical, blue dots
hold on
semilogy(EbNo, sim_ber, 'rx-'); % simulated, red crosses
axis([0 16 10^-8 0.5])
grid on
legend('Theoretical', 'Simulated');
xlabel('Eb/N0 (dB)');
ylabel('BER');
title(['BER vs SNR for ', num2str(M), '-QAM']);