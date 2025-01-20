function awgn_ber = awgn_qam(EbNo, M, rotAngle)
    % Initialization
    N = 10^6;           % Number of symbols
    k = log2(M);        % Number of bits per symbol
    sps = 1;            % Number of samples per symbol (oversampling factor)

    dataIn = randi([0 1],N*k,1);        % Generate vector of binary data
    dataSymbolsIn = bit2int(dataIn,k);  % Convert Binary Data to Integer-Valued Symbols

    % Modulation
    dataMod = qammod(dataSymbolsIn,M,'bin'); % Binary-encoded
    dataModRot = dataMod * exp(1j * rotAngle); % rotated = modulated * e^(j*angle), j is imaginary

    sim_ber = zeros(1, length(EbNo));

    for ii = 1:length(EbNo)
        snr = convertSNR(EbNo(ii),'ebno', samplespersymbol=sps, bitspersymbol=k);

        % Add AWGN noise
        receivedSignal = awgn(dataModRot,snr,'measured');

        % Undo rotation
        receivedSignalUnrot = receivedSignal * exp(-1j * rotAngle);

        % Demodulation
        dataSymbolsOut = qamdemod(receivedSignalUnrot,M,'bin'); % Binary-encoded data symbols

        dataOut = int2bit(dataSymbolsOut,k); % Convert Integer-Valued Symbols to Binary Data
        [~,ber] = biterr(dataIn,dataOut);

        sim_ber(ii) = ber; % simulated BER
    end

    awgn_ber = sim_ber;
end