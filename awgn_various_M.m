clear; % clear all variables in the workspace

% Initialization
EbNo = [0:16];      % Eb/N0 vector
rotAngle = pi/2;    % Rotation angle in radians

m_16_ber = awgn_qam(EbNo, 16, rotAngle);
m_64_ber = awgn_qam(EbNo, 64, rotAngle);
m_256_ber = awgn_qam(EbNo, 256, rotAngle);

% Plot results
close all
figure
semilogy(EbNo, m_16_ber, 'b.-'); % 16-QAM, blue dots
hold on
semilogy(EbNo, m_64_ber, 'rx-'); % 64-QAM, red crosses
semilogy(EbNo, m_256_ber, 'g*-'); % 256-QAM, green asterisks
axis([0 16 10^-8 0.5])
grid on
legend('16-QAM', '64-QAM', '256-QAM');
xlabel('Eb/N0 (dB)');
ylabel('BER');
title(['BER vs SNR for various M-QAM']);