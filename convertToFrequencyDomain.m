function freqs = convertToFrequencyDomain(frames)
% Converts a struct of audio frames into a struct of frequency frames

freqs = struct();
for i = 1:length(frames)
	freqs(i).x = fft(frames(i).x);
	freqs(i).x = freqs(i).x(1:ceil((length(freqs(i).x)+1)/2));
end
