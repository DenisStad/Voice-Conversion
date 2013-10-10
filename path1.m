function [PATH]=path1(Local,Trans)
%PATH1 find optimal path with the lowest cost
%
%This routine is used to find the optimal path with lowest cost if two matrice(Local cost matrix and Transition cost)
%are given.
%
% INPUTS: 
%   Local is the two dimentional cost matrix denating the local cost;
%   Trans is the three dimentional cost matrix denating the transition cost;
%
% OUTPUTS:
%   PATH is the lowest cost path of the given matrix;

%   Programmers: Dr. Zahorian, Lingyun Gu

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

[M,N]=size(Local);                              %getting the size of the local matrix;

if M>=500
    error('Stop in Dynamic due to M>100')         %if M is greater than 100, stop the routine;
end
if N>=5000                                      %if N is greater than 1000, stop the routine;
    error('Stop in Dynamic due to N>1000')
end


PRED=ones(M,N);                                 %initializing several desired matrix;
P=ones(1,N);
p=zeros(1,N);
%PATH=zeros(1,N);
PCOST = zeros(1,M);
CCOST = zeros(1,M);

for J=1:M                                     %initializing the previous costs;
    PCOST(J)=Local(J,1);     
end

for I=2:N                                       %this loop is doing the heart work of this routine. That means to
    for J=1:M
        CCOST(J)=1.0E+30;                        %get the lowest cost path;
        
        for K=1:M
            if PCOST(K)+Trans(K,J,I)<=CCOST(J)  %deciding the optimal path between two points in two next column; 
                CCOST(J)=PCOST(K)+Trans(K,J,I);
                PRED(J,I)=K;                     %this line is very importent, used to mark the chosen points;
            end
        end
        
        if CCOST(J)>=1.0E+30
            error('CCOST>1.0E+50, Stop in Dynamic')
        end
        
        CCOST(J)=CCOST(J)+Local(J,I);            %new cost is gotten by the adding of Local cost and current cost;
        
    end
    
    for J=1:M
        PCOST(J)=CCOST(J);                      %using the new current cost to update the previous cost;
    end
    
    p(I)=1;
    for J=2:M                                    %obtaining the points with lowest cost in every column;
        if CCOST(J)<=CCOST(1)
            CCOST(1)=CCOST(J);p(I)=J;
        end
    end
end

%  Determine ending state with lowest cost
%  Note that CCOST array is filled with costs of states for ending time step
%  at this point in code

%  IT would seem that following lines of code should be able
%  to be substituted for the above similar lines, which are used every iteration
%  However, results are same with clean speech, but slightly degraded with noisy
%  speech

%   p(N) = 1;
%   for J=2:M                   %obtaining the points with lowest cost in every column;
%     if CCOST(J)<=CCOST(1)
%          CCOST(1)=CCOST(J);p(N)=J;
%     end
%   end


P(N)=p(N);

for I=N-1:-1:1                   %using this loop to get the path finally; from the last point going
   P(I)=PRED(P(I+1),I+1);        %backward to find the previous points, etc;
end
PATH=P;                          %getting the final path. 


