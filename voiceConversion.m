function voiceConversion(inputWavFileName, outputWavFileName)
% Converts a the voice of the speech of a wav file into another voice
% inputWavFileName: File name of the wav that will be converted
% outputWavFileName: File name of the output wav that is written to

[inputWav, fs, bps] = wavread(inputWavFileName);
inputFrames = splitByPitchMarks(inputWav, fs);
inputFreqs = convertToFrequencyDomain(inputFrames);
outputFreqs = vtln(inputFreqs, 1.2, 'linear');
outputFrames = convertToTimeDomain(outputFreqs);
outputWav = concatenateFrames(outputFrames);
wavwrite(outputWav, fs, bps, outputWavFileName);
