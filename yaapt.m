function[Pitch, numfrms, frmrate] = yaapt(Data, Fs, VU, ExtrPrm, fig)
% YAAPT Fundamental Frequency (Pitch) tracking
%
% [Pitch, numfrms, frmrate] = yaapt(Data, Fs, VU, ExtrPrm, fig)
%   , the function is to check input parameters and invoke a number of associated routines 
%   for the YAAPT pitch tracking.
%
% INPUTS: 
%   Data:       Input speech raw data
%   Fs:         Sampling rate of the input data
%   VU:         Whether to use voiced/unvoiced decision with 1 for True and 0 for 
%               False.The default is 1.
%   ExtrPrm:    Extra parameters in a struct type for performance control.
%               See available parameters defined in yaapt.m 
%               e.g., 
%               ExtrPrm.f0_min = 60;         % Change minimum search F0 to 60Hz 
%               ExtrmPrm.fft_length = 8192;  % Change FFT length to 8192
%   fig:        Whether to plot pitch tracks, spectrum, engergy, etc. The parameter
%               is 1 for True and 0 for False. The default is 0.   
%
% OUTPUTS:
%   Pitch:      Final pitch track in Hz. Unvoiced frames are assigned to 0s.
%   numfrms:    Total number of calculated frames, or the length of
%               output pitch track
%   frmrate:    Frame rate of output pitch track in ms

%  Creation Date:  June 2000
%  Revision date:  Jan 2, 2002 , Jan 13, 2002 Feb 19, 2002, Mar 3, 2002
%                  June 11, 2002, Jun 30, 2006, July 27, 2007
%                  May 20, 2012: Add the VU parameter for whether to use
%                  voiced/unvoiced decision. 
%  Authors:        Hongbing Hu, Stephen A.Zahorian

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     This file is a part of the YAAPT program, designed for a fundamental 
%   frequency tracking algorithm that is extermely robust for both high quality 
%   and telephone speech.  
%     The YAAPT program was created by the Speech Communication Laboratory of
%   the state university of New York at Binghamton. The program is available 
%   at http://www.ws.binghamton.edu/zahorian as free software. Further 
%   information about the program can be found at "A spectral/temporal 
%   method for robust fundamental frequency tracking," J.Acosut.Soc.Am. 123(6), 
%   June 2008.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-- PARAMETERS ----------------------------------------------------------------
% Preliminary input arguments check
if nargin<2
    error('No enough input arguments');
end

% Default values for the tracking with voiced/unvoiced decision
Prm_VU = struct(...
    'frame_length',   25, ... % Length of each analysis frame (ms)
    'frame_space',    10, ... % Spacing between analysis frame (ms)
    'f0_min',         60, ... % Minimum F0 searched (Hz)
    'f0_max',        400, ... % Maximum F0 searached (Hz)
    'fft_length',   8192, ... % FFT length
    'bp_forder',     150, ... % Order of bandpass filter
    'bp_low',         50, ... % Low frequency of filter passband (Hz)
    'bp_high',      1500, ... % High frequency of filter passband (Hz)
    'nlfer_thresh1',0.75, ... % NLFER boundary for voiced/unvoiced decisions
    'nlfer_thresh2', 0.1, ... % Threshold for NLFER definitely unvocied
    'shc_numharms',    3, ... % Number of harmonics in SHC calculation
    'shc_window',     40, ... % SHC window length (Hz)
    'shc_maxpeaks',    4, ... % Maximum number of SHC peaks to be found
    'shc_pwidth',     50, ... % Window width in SHC peak picking (Hz)
    'shc_thresh1',   5.0, ... % Threshold 1 for SHC peak picking
    'shc_thresh2',  1.25, ... % Threshold 2 for SHC peak picking
    'f0_double',     150, ... % F0 doubling decision threshold (Hz)
    'f0_half',       150, ... % F0 halving decision threshold (Hz)
    'dp5_k1',         11, ... % Weight used in dynaimc program
    'dec_factor',      1, ... % Factor for signal resampling
    'nccf_thresh1', 0.25, ... % Threshold for considering a peak in NCCF
    'nccf_thresh2',  0.9, ... % Threshold for terminating serach in NCCF
    'nccf_maxcands',   3, ... % Maximum number of candidates found
    'nccf_pwidth',     5, ... % Window width in NCCF peak picking
    'merit_boost',  0.20, ... % Boost merit
    'merit_pivot',  0.99, ... % Merit assigned to unvoiced candidates in
                          ... % defintely unvoiced frames
    'merit_extra',   0.4, ... % Merit assigned to extra candidates
                          ... % in reducing F0 doubling/halving errors
    'median_value',    7, ... % Order of medial filter
    'dp_w1',        0.15, ... % DP weight factor for V-V transitions
    'dp_w2',         0.5, ... % DP weight factor for V-UV or UV-V transitions
    'dp_w3',         0.1, ... % DP weight factor of UV-UV transitions
    'dp_w4',         0.9, ... % Weight factor for local costs
    'end', -1);

% Default values for the tracking with all frames voiced
Prm_aV = struct(...
    'frame_length',   35, ... % Length of each analysis frame (ms)
    'frame_space',    10, ... % Spacing between analysis frame (ms)
    'f0_min',         60, ... % Minimum F0 searched (Hz)
    'f0_max',        400, ... % Maximum F0 searched (Hz)
    'fft_length',   8192, ... % FFT length
    'bp_forder',     150, ... % Order of bandpass filter
    'bp_low',         50, ... % Low frequency of filter passband (Hz)
    'bp_high',      1500, ... % High frequency of filter passband (Hz)
    'nlfer_thresh1',0.75, ... % NLFER boundary for voiced/unvoiced decisions
    'nlfer_thresh2', 0.0, ... % Threshold for NLFER definitely unvocied
    'shc_numharms',    3, ... % Number of harmonics in SHC calculation
    'shc_window',     40, ... % SHC window length (Hz)
    'shc_maxpeaks',    4, ... % Maximum number of SHC peaks to be found
    'shc_pwidth',     50, ... % Window width in SHC peak picking (Hz)
    'shc_thresh1',   5.0, ... % Threshold 1 for SHC peak picking
    'shc_thresh2',  1.25, ... % Threshold 2 for SHC peak picking
    'f0_double',     150, ... % F0 doubling decision threshold (Hz)
    'f0_half',       150, ... % F0 halving decision threshold (Hz)
    'dp5_k1',         11, ... % Weight used in dynaimc program
    'dec_factor',      1, ... % Factor for signal resampling
    'nccf_thresh1', 0.30, ... % Threshold for considering a peak in NCCF
    'nccf_thresh2', 0.90, ... % Threshold for terminating serach in NCCF
    'nccf_maxcands',   3, ... % Maximum number of candidates found
    'nccf_pwidth',     5, ... % Window width in NCCF peak picking
    'merit_boost',  0.20, ... % Boost merit
    'merit_pivot',  0.99, ... % Merit assigned to unvoiced candidates in
                          ... % defintely unvoiced frames
    'merit_extra',   0.4, ... % Merit assigned to extra candidates
                          ... % in reducing F0 doubling/halving errors
    'median_value',    7, ... % Order of medial filter
    'dp_w1',        0.15, ... % DP weight factor for V-V transitions
    'dp_w2',         0.5, ... % DP weight factor for V-UV or UV-V transitions
    'dp_w3',         100, ... % DP weight factor of UV-UV transitions
    'dp_w4',        0.02, ... % Weight factor for local costs
    'end', -1);
 
% Select parameter set 
if (nargin > 2 && ~isempty(VU) && VU == 0)
    Prm = Prm_aV;
else 
    Prm = Prm_VU;
end


% Overwrite parameters if they are passed from command line(ExtrPar)  
if ((nargin > 3) && isstruct(ExtrPrm))
    fdNames = fieldnames(ExtrPrm);
    for n = 1:length(fdNames)
        pName = char(fdNames(n));
        Prm.(pName) = ExtrPrm.(pName);
        %message('PT:det', 'Parameter %s replaced: %d', pName,Prm.(pName));
    end
end
%Prm

% Whether to plot pitch tracks, spectrum, engergy, etc.
GraphPar = 0;
if (nargin > 4 && ~isempty(fig))
    GraphPar = fig;
end

%-- MAIN ROUTINE --------------------------------------------------------------
%  Step 1. Preprocessing
%  Create the squared or absolute values of filtered speech data
[DataB, DataC, DataD, nFs] = nonlinear(Data, Fs, Prm);

%  Check frame size, frame jump and the number of frames for nonlinear singal
nframesize = fix(Prm.frame_length*nFs/1000);    
if (nframesize < 15)
    error('Frame length value %d is too short', Prm.frame_length);
end
if (nframesize > 2048)
    error('Frame length value %d exceeds the limit', Prm.frame_length);
end

%  Step 2. Spectral pitch tracking
%  Calculate NLFER and determine voiced/unvoiced frames with NLFER
[Energy, VUVEnergy]= nlfer(DataB, nFs, Prm);

%  Calculate an approximate pitch track from the spectrum.
%  At this point, SPitch is best estimate of pitch track from spectrum
[SPitch, VUVSPitch, pAvg, pStd]= spec_trk(DataD, nFs, VUVEnergy, Prm);


%  Step 3. Temporal pitch tracking based on NCCF
%  Calculate a pitch track based on time-domain processing
%  Pitch tracking from the filterd original signal 
[TPitch1, TMerit1] = tm_trk(DataB, nFs, SPitch, pStd, pAvg, Prm);

%  Pitch tracking from the filterd nonlinear signal 
[TPitch2, TMerit2] = tm_trk(DataD, nFs, SPitch, pStd, pAvg, Prm);


% Refine pitch candidates 
[RPitch, Merit] = refine(TPitch1, TMerit1, TPitch2, TMerit2, SPitch, ...
                        Energy, VUVEnergy, Prm);

% Step 5. Use dyanamic programming to determine the final pitch
Pitch  = dynamic(RPitch, Merit, Energy, Prm);
numfrms = length(Pitch);
frmrate = Prm.frame_space; 


%== FIGURE ====================================================================
%  Several plots to illustrate processing and performance
if (GraphPar)     
    pt_figs(DataB, DataD, nFs, SPitch, Energy, VUVEnergy, RPitch, Pitch, Prm);
end

%==============================================================================
