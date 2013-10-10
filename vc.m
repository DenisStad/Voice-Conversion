function vc(sourceWavFileName, alpha, f0ratio, outputFileName, varargin)

[wav,fs,bits] = wavread(sourceWavFileName);

wav = wav(:,1);
wav = wav ./ max(wav); %normalize

if length(varargin)==0
    pm = findPM(wav, fs);
else
    pm = load(varargin(1));
    pm = round(pm .* fs);
    pm = [pm(1); diff(pm)];

    if sum(pm)>length(wav)
        error('pm file is unsuitable for wav');
    end
end

frames = splitWavByPm(wav, pm);
freqs = time2freq(frames);

warpedFreqs = vtln(freqs, 'asymmetric', alpha);

warpedWav = freq2time(warpedFreqs);
wavOut = psola(warpedWav, f0ratio);

wavwrite(wavOut, fs, bits, outputFileName);
% 
% 
% %print -depsc2 pm.eps;
