README

To convert a voice the following steps are neccessary:

- /Path/To/Praat /Path/To/PraatToPitchMarks.praat /Path/To/Source.wav /Path/To/PitchMarksPraat.PointProcess
- perl /Path/To/convertPraatToMatlab.pl /Path/To/PitchMarksPraat.PointProcess /Path/To/PitchMarksMat.txt
- in octave: vc('/Path/To/Source.wav', '/Path/To/PitchMarksMat.txt', alpha, '/Path/To/Output.wav')
   (alpha is the warping factor)
