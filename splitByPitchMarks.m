function frames = splitByPitchMarks(y, fs)
% Split a an audio signal by its pitch marks
% y: audio signal
% fs: is the sample frequency (44100)
% frames: struct with elements of frames

pm = findPitchMarks(y, fs);

