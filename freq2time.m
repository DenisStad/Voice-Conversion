function time = freq2time(freqs)

time = struct();
for i = 1:length(freqs)
   freq = freqs(i).data;
   conjFreq = conj(freq(end-isreal(freq(end)):-1:2, :));
   fullFreq = [freq; conjFreq];
	time(i).data = real(ifft(fullFreq));
end
