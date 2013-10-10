function[Energy, VUVEnergy]= nlfer(Data, Fs, Prm)
% NLFER  Normalized Low Frequency Energy Ratio
%
%   [Energy, VUVEnergy]= nlfer(Data, Fs, Prm) computes the
%   nromlized low frequency energy ratio.
%
% INPUTS:
%   Data:  Nonlinear, filtered signal for NLFER caculation
%   Fs:    The sampling frequency.
%   Prm:   Array of parameters used to control performance
%
% OUTPUTS:
%   Energy:     NLFER Energy of the data
%   VUVEnergy:  Voiced/Unvoiced decisions (optimum??)

%   Creation date:  Oct 17, 2006, July 13, 2007
%   Programers:     Hongbing Hu, S. Zahorian

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     This file is a part of the YAAPT program, designed for a fundamental 
%   frequency tracking algorithm that is extermely robust for both high quality 
%   and telephone speech.  
%     The YAAPT program was created by the Speech Communication Laboratory of
%   the state university of New York at Binghamton. The program is available 
%   at http://www.ws.binghamton.edu/zahorian as free software. Further 
%   information about the program could be found at "A spectral/temporal 
%   method for robust fundamental frequency tracking," J.Acosut.Soc.Am. 123(6), 
%   June 2008.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-- PARAMETERS: set up all of these parameters --------------------------------
nfftlength = Prm.fft_length;            % FFT length
nframesize = fix(Prm.frame_length*Fs/1000);    
nframejump = fix(Prm.frame_space*Fs/1000); 

% If normalized low-frequency energy is below this, assume unvoiced frame
nlfer_thersh1  = Prm.nlfer_thresh1;

% Low freqeuncy range for NLFER
N_F0_min = round ((Prm.f0_min*2/Fs) * nfftlength );
N_F0_max = round ((Prm.f0_max/Fs) * nfftlength );

%-- MAIN ROUTINE --------------------------------------------------------------

%  Spectrogram of the data
SpecData = specgram(Data,nfftlength,Fs,(nframesize),(nframesize-nframejump));

% Compute normalize low-frequency energy ratio 
FrmEnergy = sum(abs(SpecData(N_F0_min:N_F0_max,:)));
avgEnergy = mean(FrmEnergy);

Energy = FrmEnergy/avgEnergy;
% The frame is voiced if NLFER enery > threshold, otherwise is unvoiced.
VUVEnergy = (Energy > nlfer_thersh1);

