function frames = splitWavByPm(wav, pm)

pmSum = 0;
frames = struct();
for i = 1:length(pm)
	frames(i).data = wav(pmSum+1:pmSum+pm(i));
   pmSum = pmSum + pm(i);
end
