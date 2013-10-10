function warpedFreqs = vtln(frames, warpFunction, alpha)

if ~(strcmp(warpFunction, 'asymmetric') || strcmp(warpFunction, 'symmetric') || ...
     strcmp(warpFunction, 'power') || strcmp(warpFunction, 'quadratic') || ...
     strcmp(warpFunction, 'bilinear') ...
    )
    error('Invalid warp function');
end

warpedFreqs = struct();

%frames = struct();
%frames(1).data = 1:100;
 
%figure(1);
%clf;
%hold on;

%for k = 1:6
 
%alpha = 1.4;

%if k==2
%        warpFunction = 'asymmetric';
%end
%if k==1
%        warpFunction = 'symmetric';
%end
%if k==3
%        warpFunction = 'power';
%        alpha = 0.6;
%end
%if k==4
%        warpFunction = 'quadratic';
%end
%if k==5
%        warpFunction = 'bilinear';
%        alpha = 0.4;
%end
%if k==6
%   warpFunction = 'symmetric';
%   alpha = 1;
%end
%k

for j = 1:length(frames)
   m = length(frames(j).data);
   omega = (1:m) ./ m .* pi;
   omega_warped = omega;
   %plotopts = ''; 
   %if k==6
   %   warpFunction
   %   plotopts = "-k";
   %end
   if strcmp(warpFunction, 'asymmetric') || strcmp(warpFunction, 'symmetric')
      omega0 = 7/8 * pi;
      %plotopts = "--r";
      if strcmp(warpFunction, 'symmetric') && alpha > 1
         omega0 = 7/(8*alpha) * pi;
         %plotopts = ":b";
         %k+10
         %if k==7
         %   plotopts = "k"
       %     1
         %end
      end
      omega_warped(find(omega <= omega0)) = alpha .* omega(find(omega <= omega0));
      omega_warped(find(omega > omega0)) = alpha * omega0 + ((pi - alpha * omega0)/(pi - omega0)) .* (omega(find(omega > omega0)) - omega0);

      omega_warped(find(omega_warped >= pi)) = pi - 0.00001 + 0.00001 * (omega_warped(find(omega_warped >= pi))); 

   elseif strcmp(warpFunction, 'power')
      omega_warped = pi .* (omega./pi) .^ alpha;
%       plotopts = ":r";
   elseif strcmp(warpFunction, 'quadratic')
      omega_warped = omega + alpha .* (omega./pi - (omega./pi).^2);
%       plotopts = "--b";
   elseif strcmp(warpFunction, 'bilinear')
      z = exp(omega .* i);
      omega_warped = abs(-i .* log((z - alpha)./(1 - alpha.*z)));
%       plotopts = ":k";
   end


%if k==6
 %     warpFunction
  %    plotopts = "-k";
   %end
    omega_warped = [omega_warped ./ pi .* m];
    warpedFrame = interp1((1:m), frames(j).data, omega_warped, 'linear').';

    if isreal(frames(j).data(end))
        warpedFrame(end) = real(warpedFrame(end));
    end

    warpedFrame(isnan(warpedFrame)) = 0;
    warpedFreqs(j).data = warpedFrame;

    %h = plot((1:m)./m*pi, omega_warped./m*pi, plotopts);
    %set (h(1), "linewidth", 3);
    %plot(1,1, 'w');
end

%end


%set (gca,'fontsize',25);
%l = legend('symmetric', ' ', 'asymmetric',' ', 'power',' ', 'quadratic',' ', 'bilinear',' ', 'neutral', ' ', 'location','southeast');
%set(l, 'FontSize', 18);
%set(gca,'XTick',0:pi/2:pi)
%set(gca,'XTickLabel',{'0','pi/2','pi'})
%set(gca,'YTick',0:pi/2:pi)
%set(gca,'YTickLabel',{'0','pi/2','pi'})
%axis([0 pi 0 pi+0.1])
%print -depsc2 test.eps;
