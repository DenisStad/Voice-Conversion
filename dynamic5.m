function [FinPitch] = dynamic5(Pitch_array, Merit_array, k1)
%  Dynamic programming on speech processing
%
% [FinPitch] =dynamic5(Pitch_array, Merit_array, k1);
% This routine is used to compute Local and Transition cost matrices
% to enable lowest cost tracking of pitch candidates;
% It uses NFLER from the spectrogram and the highly robust
% spectral F0 track, plus the merits, for
% computation of the cost matrices.

%   Creation date:   Spring 2001
%   Revision dates:   January 3, 2002, March 7, 2005
%   Programmer: Dr. Zahorian,Kavita Kasi, Lingyun Gu;

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

F0_min = 60;

% some initializations.
[numcands, numframes] = size(Pitch_array);


%The following weighting factors are used to differentially weight
% the various types of transitions which can occur, as well as weight
% the relative value of transition costs and local costs
%forming the local cost matrix
Local = 1 - Merit_array;

%initialization for the formation of the transition cost matrix
Trans  = zeros(numcands, numcands, numframes);


%the transition cost matrix is proportional to frequency differences
%between successive candidates.
for i = 2:numframes
   for j = 1:numcands
      for k = 1:numcands
            Trans(k,j,i)  = (abs(Pitch_array(j,i) - Pitch_array(k,i-1)))/ F0_min ;
            Trans(k,j,i) =  0.05*Trans(k,j,i) + Trans(k,j,i)^2;
      end;
   end;
end;

% Overal balance between Local and Transition costs
Trans = k1 * Trans;

% search the best path
Path = path1(Local, Trans);

% Extract the final vocied F0 track which has the lowest cost
% At this point, VSpec_F0 is the spectral pitch track for voiced frames
FinPitch = zeros(1,numframes);
for n=1:numframes
    FinPitch(n) = Pitch_array(Path(n), n);
end;




