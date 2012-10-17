function frames = splitByPitchMarks(y, fs)
% Split a an audio signal by its pitch marks
% y: audio signal
% fs: is the sample frequency (44100)
% frames: struct with elements of frames

% Get the pitch marks
pms = findPitchMarks(y, fs);

% Split the audio into the frames
frames = struct();
for i = 1:length(pms)-1
	frames(i).x = y(pms(i):pms(i+1));
end

% Overlap frames for concatenation by PSOLA
overlappedFrames = struct();
for i = 1:length(frames)-1
	overlappedFrames(i).x = [frames(i).x; frames(i+1).x];
end
overlappedFrames(length(frames)).x = [frames(end).x; frames(end).x];
