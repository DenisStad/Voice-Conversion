function frames = convertToTimeDomain(freqs)
% Converts a struct of frequency frames to a struct of audio frames
fullSpec = struct();
frames = struct();
for i = 1:length(freqs)
	freq = freqs(i).x;
	conjSpec = conj(freq(end-isreal(freq(end)):-1:2, :));
	fullSpec(i).x = [freq; conjSpec];
	frames(i).x = real(ifft(fullSpec(i).x));
end
