function vc(sourceWavFileName, sourcePMFileName, alpha, f0ratio, outputFileName)

[wav,fs,bits] = wavread(sourceWavFileName);

pm = load(sourcePMFileName);
pm = round(pm .* fs);
pm = [pm(1); diff(pm)];

if sum(pm)>length(wav)
    error('pm file is unsuitable for wav');
end

frames = splitWavByPm(wav, pm);
freqs = time2freq(frames);

warpedFreqs = vtln(freqs, 'asymmetric', alpha);

warpedWav = freq2time(warpedFreqs);
wavOut = psola(warpedWav, f0ratio);

wavwrite(wavOut, fs, bits, outputFileName);