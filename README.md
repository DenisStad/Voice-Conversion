README

To convert a voice the following steps are neccessary:

If you want to use Praat as pitch tracker:

- Praat PraatToPitchMarks.praat Source.wav PitchMarksPraat.PointProcess
- perl convertPraatToMatlab.pl PitchMarksPraat.PointProcess PitchMarksMat.txt
- in octave: vc('Source.wav', alpha, fRatio, 'Output.wav', 'PitchMarksMat.txt')
   (alpha is the warping factor, fRatio is the ratio of the fundamental frequency for psola)

If you want to use the integrated pitch tracker:

- in octave: vc('Source.wav', alpha, fRatio, 'Output.wav')
   (alpha is the warping factor, fRatio is the ratio of the fundamental frequency for psola)



The test file ("sample.wav which is originally called ""NATOPhoneticAlphabet.wav") is from: "Michael R. Irwin at en.wikiversity" (Creative Commons)
