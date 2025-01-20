clear; % clear all variables in the workspace

% Initialization
EbNo = [0:16];      % Eb/N0 vector
M = 256; % M-QAM

angle_0 = awgn_qam(EbNo, M, 0);
angle_pi_over_8 = awgn_qam(EbNo, M, pi/8);
angle_pi_over_2 = awgn_qam(EbNo, M, pi/2);

% Plot results
close all
figure
semilogy(EbNo, angle_0, 'b.-'); % Angle 0, blue dots
hold on
semilogy(EbNo, angle_pi_over_8, 'rx-'); % Angle pi/8 rads, red crosses
semilogy(EbNo, angle_pi_over_2, 'g*-'); % Angle pi/2 rads, green asterisks
axis([0 16 10^-8 0.5])
grid on
legend('0 rad', 'pi/8 rads', 'pi/2 rads');
xlabel('Eb/N0 (dB)');
ylabel('BER');
title(['BER vs SNR for various angles with 16-QAM']);