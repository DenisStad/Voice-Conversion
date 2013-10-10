function[Phi] = crs_corr(Data, lag_min, lag_max)
% CRS_CORR compute NCCF (Normalized cross correlation Function) 
%
%   [Phi] = crs_corr(Data, lag_min, lag_max) computes the
%   normalized cross correlation sequence based on the RAPT algorithm 
%   discussed by DAVID TALKIN.
%   "Assume that "S" is the input signal sequence, "Phi" is correlation sequence,
%       Phi(k)=SUM((S[j])*(S[j+k]))/sqrt((SUM(s[j]^2)*(S[j+k]^2)))
%       where 1 <= k <= Lag_max and 1 <= j <= N. Summation is based on j only
%       Phi(k) should range from -1 to 1".
%
% INPUTS:   
%   Data:     Data array of signal values.
%   lag_min:  minimum value of lag to consider
%   lag_max:  maximum value of lag to consider
%   Note that calculations will be based on (len-----lag_max)  points
%
% OUTPUTS:
%   Phi     : The normalized cross correlated
%
%   Note: The index of the first reasonable peak value of Phi is considered
%   to be the period of the input signal.

%  Programmer: S.A.Zahorian,Kasi Kavita.
%  Creation date:  2000
%  Revision date:  March 26, 2002

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

% Some initialization
eps1 = 0.0;

len  = length(Data); % The length of data
N = len-lag_max;    % range

Phi = zeros(1,len)  ;

% Remove DC level
Data = Data- mean(Data); 

x_j =  Data(1:N);     % s[j]   1 <= j <= N.
p = x_j' * x_j;

for k = lag_min:lag_max
    
    %  to calculate the dot product of the signal and displaced version.
    x_jr = Data(k:k+N-1);    % s[j]   -k <= j <= N+K-k-1.
    formula_nume = x_j' * x_jr;
    
    % the normalization factor for the denominator.
    q = x_jr' * x_jr;
    
    formula_denom= p*q;
    
    formula_denom = formula_denom+ eps1;
    
    % calculate the normalized crosscorrelation value using the TALKIN FORMULA.
    Phi(k)=((formula_nume)/(sqrt(formula_denom)));
end

%   To test using autocorrelation
%    Phi = xcorr(s);





