function [FinPitch] = dynamic(Pitch, Merit, Energy, Prm)
%DYNAMIC Dynamic programming for YAAPT pitch tracking
%
% [FinPitch] = dynamic(Pitch, Merit, Energy, Prm) is used
% to compute Local and Transition cost matrices
% to enable lowest cost tracking of pitch candidates;
% It uses NFLER from the spectrogram and the highly robust
% spectral F0 track, plus the merits, for
% computation of the cost matrices.
%
%INPUTS: 
%   Pitch:  Pitch array with elements arranged so that lowest
%                      index correponds to  highest merit
%   Merit:  Merit array with elements arranged as for pitch
%   Energy: NLFER energy ratio from the low frequency regions of spectrogram.
%   Prm:    Array of parameters used to control performance
%
%OUTPUTS:  
%   FinPitch: The final pitch track for the entire utterance pitch
%   values are in HZ.Unvoiced frames are assigned 0.

% Note:   This routine is intended for more through testing of
%    some thresholds used in dynamic6.   All the dp constants are
%    set to fixed values that worked well in testing
%    then the dp constants are used to specify the thresholds and other
%     constants

%   Creation date:   Spring 2001
%   Revision date:   January 3, 2002   June 16, 2007, July 27, 2007
%   Programmers: S. Zahorian,Kavita Kasi, Lingyun Gu, Hongbing Hu

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


%-- INITIALIZATION -----------------------------------------------------------
[numcands, numframes] = size(Pitch);

%Copy some arrays
BestPitch  = Pitch(numcands-1,:);
mean_pitch = mean(BestPitch(BestPitch>0));

%The following weighting factors are used to differentially weight
% the various types of transitions which can occur, as well as weight
% the relative value of transition costs and local costs
dp_w1 = Prm.dp_w1;
dp_w2 = Prm.dp_w2;
dp_w3 = Prm.dp_w3;
dp_w4 = Prm.dp_w4;


%-- MAIN ROUTINE --------------------------------------------------------------
% Forming the local cost matrix
Local = 1 - Merit;

% Initialization for the formation of the transition cost matrix
Trans  = ones(numcands,numcands,numframes);

% The transition cost matrix is proportional to frequency differences
% between successive candidates.
for i = 2:numframes
    for j = 1:numcands
        for k = 1:numcands
            % both candidates voiced
            if ((Pitch(j,i) > 0) && (Pitch(k,i-1) > 0) )        
                Trans(k,j,i) = dp_w1*(abs(Pitch(j,i)-Pitch(k,i-1))/mean_pitch);
            end
            
            % one candiate is unvoiced
            if (Pitch(j,i)==0 && Pitch(k,i-1)>0) || (Pitch(j,i)>0 && Pitch(k,i-1)==0)
                benefit = min(1, abs(Energy(i-1)-Energy(i)));
                Trans(k,j,i) =  dp_w2*(1-benefit);
            end
            
            % both candidates are unvoiced
            if ((Pitch(j,i) == 0) && (Pitch(k,i-1) == 0))
                Trans(k,j,i) =  dp_w3;
            end
        end
    end
end

% Overal balance between Local and Transition costs
Trans = Trans/dp_w4;

% Find the minimum cost path thru Pitch_Array using the Local and Trans costs
Path = path1(Local,Trans);

%extracting the pitch, using Path
FinPitch = zeros(1,numframes);
for i = 1:numframes
  FinPitch(i) = Pitch(Path(i),i);
end

