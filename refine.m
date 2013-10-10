function[Pitch, Merit] = refine(TPitch1, TMerit1, TPitch2, TMerit2, SPitch, Energy, VUVEnergy, Prm)
% REFINE Refine pitch candidates for YAAPT Pitch tracking
%
% [Pitch, Merit] = refine(TPitch1, TMerit1, TPitch2, TMerit2, SPitch, Energy, VUVEnergy, Prm)
%   refins pitch cadidates obtained from NCCF using spectral pitch
%   track and NLFER energy information.
%
% INPUTS: 
%   TPitch1:  Pitch candidates array 1
%   TMerti1:  Merits for pitch candidates array 1
%   TPitch2:  Pitch candidates array 2
%   TMerti2:  Merits for pitch candidates array 2
%   SPitch:   Smoothed spectral pitch track
%   Energy:   NLFER Energy information
%   VUVEnergy: Voiced/Unvoiced information determined by NLFER energy
%   Prm:      Parameters
%
% OUTPUTS:
%   Pitch:   Refined overall pitch candidates
%   Merit:   Merit for overall pitch candidates

%   Creation: July 27 2007
%   Author:   Hongbing Hu

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
% Threshold for NLFER energy
nlfer_thresh2  = Prm.nlfer_thresh2;
Merit_pivot = Prm.merit_pivot;


%-- MAIN ROUTINE --------------------------------------------------------------
% Merge pitch candidates and their merits from two types of the signal
Pitch = cat(1,TPitch1, TPitch2);
Merit = cat(1,TMerit1, TMerit2);

%  The rate/pitch arrays and the merit arrays are now arranged
%  according to the index of the sorted Merit.
[maxcands, numframes] = size(Pitch);
[Merit, Idx] = sort(Merit, 'descend');
for n=1:numframes
    Pitch(:,n) = Pitch(Idx(:,n),n);
end

% A best pitch track is generated from the best candidates
BestPitch = medfilt1(Pitch(1,:), Prm.median_value).*VUVEnergy;

% Refine pitch candidates
for i = 1:numframes
    if (Energy(i)<=nlfer_thresh2)       
        %Definitely unvoiced, all candidates will be unvoiced  with high merit
        Pitch(:,i) = 0;
        Merit(:,i) = Merit_pivot;
    else
        if (Pitch(1,i) > 0)       
            % already have the voiced candidate, Want to have at
            % least one unvoiced candidate
            Pitch(maxcands,i) = 0.0;
            Merit(maxcands,i) = (1 - Merit(1,i)) ;
            for j = 2:maxcands-1;
                if (Pitch(j,i) == 0)
                    Merit(j,i) = 0.0;
                end
            end
        else                        
            % there was no voiced candidate from nccf fill in
            % option for F0 from spectrogram
            Pitch(1,i)  = SPitch(i); 
            Merit(1,i) = min(1, Energy(i)/2);
            
            % all other candidates will be unvoiced
            % with low merit
            Pitch(2:maxcands,i) = 0.0;
            Merit(2:maxcands,i) = 1 - Merit(1,i);
        end
    end
end

%  Insert some good values  from the track that appears
%   the best, without dp, including both F0   and VUV info
for i = 1:numframes
    Pitch(maxcands-1,i) = BestPitch(1,i);
    
    %  if this candidate was voiced, already have it, along with merit
    %  if unvoiced, need to assign appropriate merit
    if (BestPitch(1,i) > 0)          % voiced
        Merit(maxcands-1,i) = Merit(1,i);
    else                                % unvoiced
        Merit(maxcands-1,i) = 1-min(1, Energy(i)/2);
    end
end

%  Copy over the SPitch array
Pitch(maxcands-2,:) = SPitch;
Merit(maxcands-2,:) = Energy/5;

%==============================================================================
