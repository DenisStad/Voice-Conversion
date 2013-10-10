function [Pitch, Merit] = cmp_rate(Phi, Fs, maxcands, lag_min, lag_max,Prm)
% CMP_RATE compute rate and merit from the autocorrelation sequence
%
% [Pitch, Merit] = cmp_rate(Phi,Fs,maxcands,lag_min,lag_max,Prm);
%  This routine computes Pitch estimates and the corresponding Merit values 
%  associated with the peaks found in each frame based on the correlation sequence.
%
%  INPUTS:
%   Phi     : The input signal(either auto correlated/normalized cross correlated).
%   Fs      : The sampling frequency.
%   lag_min : The lowest lag(== 1/F0_max) involved in the F0 estimation.
%   F0_max  : The highest lag(== 1/F0_min)  involved in the F0 estimation.
%             greater than the peak at F0 during the first pass of search.
%   maxcands: The maximum number of top candidates to be considered.
%
%  OUTPUTS:
%    Pitch  : The Rate/Pitch values for the peaks found for each frame.
%    Merit  : The Merit values of the peaks found in each frame.

%  Creation date:   2002
%  Revision dates:   March 26, 2002, December 24, 2005
%  Programmer: S.A.Zahorian,Kasi Kavita

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
%Width of the window used in first pass of peak picking.
width = Prm.nccf_pwidth;
% The center of the window is defined as the peak location.
center = round(width/2); 


% The threshold value used for the first pass of
% peak picking for each frame.any peaks found greater than this
% are chosen in the first pass.
Merit_thresh1 = Prm.nccf_thresh1;

%  The threshold value used to limit peak searching.
%  If a peak is found at least this great, no further  searching is
%  done increased from prev. value of 0.85.
Merit_thresh2 = Prm.nccf_thresh2;

%-- INITIALIZATION -----------------------------------------------------------
numpeaks  = 0;
Pitch     = zeros(1, maxcands);
Merit     = zeros(1, maxcands);


%-- MAIN ROUTINE --------------------------------------------------------------
%  Find all peaks for a (lag_min--to--lag_max) search range
%   a "peak" must be the higher than a specfied number of
%   points on either side of point.  Peaks are later "cleaned"
%   up, to retain only best peaks i.e. peaks which do not meet certain
%   criteria are eliminated.
%   and allowing only the peaks which are a certain amplitude over the rest.

for n = lag_min-center:lag_max
    [y, lag]  = max(Phi(n:n+width-1));
    if (lag == center) && (y > Merit_thresh1)
        
        numpeaks = numpeaks + 1;
        Pitch(numpeaks) = Fs/(n+lag-1);
        Merit(numpeaks) = y;
        
        if (y > Merit_thresh2)
            break;
        end;
    end;
end;

% consider the case when the number of peaks are more than the maxcands.
% Then take only the best maxcands peaks based on the Merit values .
[Merit,Idx]=sort(Merit, 'descend');
Pitch = Pitch(Idx);
numpeaks = min(numpeaks, maxcands);
Merit = Merit(1:numpeaks);
Pitch  = Pitch(1:numpeaks);

% if the number of peaks in the frame are less than the maxcands, then we 
% assign "null" values to remainder of peak and merit values in arrays
if (numpeaks < maxcands)
    Pitch(numpeaks+1:maxcands) = 0;
    Merit(numpeaks+1:maxcands) = 0.001;
end;

% Normlize merits
Max_Merit = max(Merit);
if (Max_Merit > 1.0)
    Merit = Merit/Max_Merit;
end

