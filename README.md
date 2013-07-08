README

To convert a voice the following steps are neccessary:

- Praat PraatToPitchMarks.praat Source.wav PitchMarksPraat.PointProcess
- perl convertPraatToMatlab.pl PitchMarksPraat.PointProcess PitchMarksMat.txt
- in octave: vc('Source.wav', 'PitchMarksMat.txt', alpha, fRatio, 'Output.wav')
   (alpha is the warping factor, fRatio is the ratio of the fundamental frequency for psola)


The test file ("sample.wav which is originally called ""NATOPhoneticAlphabet.wav") is from: "Michael R. Irwin at en.wikiversity" (Creative Commons)
