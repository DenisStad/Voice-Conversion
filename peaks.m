function[Pitch, Merit] = peaks(Data, delta, maxpeaks, Prm)
%PEAKS  find peaks in SHC 
%
%   [Pitch,Merit] = peaks(Data, delta, maxpeaks, Prm)
%   computes peaks in a frequency domain function
%   associated with the peaks found in each frame based on the
%   correlation sequence.
%
%INPUTS:
%   Data:  The input signal(either autocorrelated/normalized cross correlated).
%   delta: The resolution of spectrum
%   maxpeaks: The max number of peaks picked 
%   Prm:   Parameters
%
%OUTPUTS: 
%   Pitch:  The Pitch/Pitch values for the peaks found for each frame.
%   Merit:  The Merit values of the peaks found in each frame.

%  Creation date:   March 1, 2006
%  Revision dates:  March 11, 2006,  Jun 26, 2006, July 27, 2007
%  Programmer: S.A.Zahorian, Princy  Dikshit, Hongbing Hu

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

%-- PARAMETERS ----------------------------------------------------------------
% Threshold for max avaliable peak
PEAK_THRESH1 = Prm.shc_thresh1;
    
% Threshold for available peaks
PEAK_THRESH2 = Prm.shc_thresh2;

%-- COMPUTED VARIABLES --------------------------------------------------------
epsilon = .00000000000001;

% Length in Hz of range(must be largest to be a peak)
width   = fix(Prm.shc_pwidth/delta);     % Window width in sample
% The center of the window is defined as the peak location.
center = fix(width/2); 

% Lowest frequency at which F0 is allowed
min_lag  = fix(Prm.f0_min/delta - width/4);
% Highest frequency at which F0 is allowed
max_lag  = fix(Prm.f0_max/delta + width/4);

if (min_lag < 1)
    min_lag = 1;
    warning('min_lag is too low and adjusted (%d)', min_lag); 
end
if max_lag > (length(Data) - width)
    max_lag = length(Data) - width;
    warning('max_lag is too high and adjusted (%d)', max_lag);
end


%-- INITIALIZATION -----------------------------------------------------------
Pitch     = zeros(1, maxpeaks);         % Peak(Pitch) candidates
Merit     = zeros(1, maxpeaks);         % Merits for peaks

%-- MAIN ROUTINE --------------------------------------------------------------
% Normalize the signal so that peak value = 1
max_data = max(Data(min_lag:max_lag));
if (max_data > epsilon)
    Data = Data/max_data;
end

% If true there are no large peaks and we assume that signal is unvoiced
avg_data = mean(Data(min_lag:max_lag));
if (avg_data > 1/PEAK_THRESH1)    
%    numpeaks = 0;
    Pitch    = zeros(1, maxpeaks);
    Merit    = ones (1, maxpeaks);
    % force an early end for unoviced frame 
    return
end

% Step 1
% Find all peaks for search range
% a "peak" must be the higher than a specfied number of
% points on either side of point.  Peaks are further "cleaned"
% up, to retain only best peaks i.e. peaks which do not meet certain
% criteria are eliminated.

numpeaks = 0;
for n = min_lag:max_lag
    [y, lag]  = max(Data(n:(n+width-1)));
    % find peaks which are larger than threshold   
    if (lag == center) && y>(PEAK_THRESH2*avg_data)
        
        % Note Pitch(1) = delta, Pitch(2) = 2*delta
        % Convert FFT indices to Pitch in Hz
        numpeaks = numpeaks + 1;
        Pitch (numpeaks)  = (n+center)*delta;
        Merit(numpeaks)  = y;
    end
end

% Step 2
% Be sure there is large peak
if (max(Merit)/avg_data < PEAK_THRESH1)
%   numpeaks = 0;
    Pitch      = zeros(1, maxpeaks);
    Merit     = ones (1, maxpeaks);
    return
end
    
% Step 3    
% Order the peaks according to size,  considering at most maxpeaks
[Merit, Idx] = sort(Merit, 'descend');
Pitch = Pitch(Idx);
% keep the number of peaks not greater than max number
numpeaks = min(numpeaks, maxpeaks);
Pitch  = Pitch(1:numpeaks);
Merit = Merit(1:numpeaks);

% Step 4
% Insert candidates to reduce pitch doubling and pitch halving, if needed
if (numpeaks > 0)
    % if best peak has F < this, insert peak at 2F
    if (Pitch(1) > Prm.f0_double)   
        numpeaks = min(numpeaks+1, maxpeaks);
        Pitch(numpeaks) = Pitch(1)/2.0;
        % Set merit for inserted peaks
        Merit(numpeaks) = Prm.merit_extra;
    end

    % If best peak has F > this, insert peak at half F
    if (Pitch(1) < Prm.f0_half)     
        numpeaks = min(numpeaks+1, maxpeaks);
        Pitch(numpeaks) = 2.0*Pitch(1);
        Merit(numpeaks) = Prm.merit_extra;
    end
    
    % Fill in  frames with less than maxpeaks with best choice
    if (numpeaks < maxpeaks)
        Pitch(numpeaks+1:maxpeaks)  = Pitch(1);
        Merit(numpeaks+1:maxpeaks) = Merit(1);
    end
else 
    Pitch    = zeros(1, maxpeaks);
    Merit    = ones (1, maxpeaks);
end      
    
%==============================================================================

