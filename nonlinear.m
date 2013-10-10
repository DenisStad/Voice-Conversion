function[DataB, DataC, DataD, newFs] = nonlinear(DataA, Fs, Prm)
%NONLINEAR Create the nonlinear processed signal
%
%   [DataB, DataC, DataD, newFs] = nonlinear(DataA, Fs, Prm) creates
%   nonlinear signal (squared signal) and applys filtering.
%
% INPUTS: 
%   DataA: The original signal from read_audio.m 
%   Fs:    The sampling rate for the signal
%   Prm:   Array of parameters used to control performance
%
% OUTPUTS:
%   DataB: The original signal, bandpass filtered with F1.
%   DataC: The nonlinear signal, no filtering
%   DataD: The nonlinear signal, bandpass filtered with F1.
%   newFs: The sampling rate of the new signal 

%   Creation date:  Jun. 30, 2006
%   Programers:     Hongbing Hu, Princy, Zahorian

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

Fs_min = 1000;    % Do not decimate if Fs less than this

%  Parameters for filtering original signal, with a broader band
Filter_order = Prm.bp_forder;
F_hp = Prm.bp_low;
F_lp = Prm.bp_high;

if (Fs > Fs_min)
    dec_factor = Prm.dec_factor;
else
    dec_factor = 1;
end


% Creates the bandpass filters
lenDataA = length(DataA);

% filter F1
  w1  = (F_hp / (Fs/ 2));
  w2  = (F_lp/ (Fs/2));
  w   = [ w1 w2];
  b_F1 = fir1(Filter_order,w);
  a   = 1;


%filtering the original data with the bandpass filter,
% DataA   is original acoustic signal

% Original signal filtered with F1
tempData = filter(b_F1,a,DataA);
LenData_dec = fix ((lenDataA+dec_factor-1)/dec_factor);
DataB = tempData(1:dec_factor:lenDataA);


%   Create nonlinear version of signal

%   Original signal
%   DataC =  DataA;
%   Absoulte value of the signal
%   DataC =  abs(DataA);
%   Squared value of the signal
    DataC =  DataA .^2;


%   Nonlinear version filtered with F1
tempData = filter(b_F1,a,DataC);
LenData_dec = fix ((lenDataA+dec_factor-1)/dec_factor);
DataD = zeros(1, LenData_dec);
DataD = tempData(1:dec_factor:lenDataA);

newFs = Fs/dec_factor;

