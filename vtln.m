function warpedFreqs = vtln(frames, warpFunction, alpha)

if ~(strcmp(warpFunction, 'asymmetric') || strcmp(warpFunction, 'symmetric') || ...
     strcmp(warpFunction, 'power') || strcmp(warpFunction, 'quadratic') || ...
     strcmp(warpFunction, 'bilinear') ...
    )
    error('Invalid warp function');
end

warpedFreqs = struct();

for j = 1:length(frames)
    m = length(frames(j).data);
    omega = (1:m) ./ m .* pi;
    omega_warped = omega;
    
    if strcmp(warpFunction, 'asymmetric') || strcmp(warpFunction, 'symmetric')
		omega0 = 7/8 * pi;
		if strcmp(warpFunction, 'symmetric') && alpha > 1
			omega0 = 7/(8*alpha) * pi;
        end
        omega_warped(find(omega <= omega0)) = alpha .* omega(find(omega <= omega0));
        omega_warped(find(omega > omega0)) = alpha * omega0 + ((pi - alpha * omega0)/(pi - omega0)) .* (omega(find(omega > omega0)) - omega0);
	elseif strcmp(warpFunction, 'power')
		omega_warped = pi .* (omega./pi) .^ alpha;
	elseif strcmp(warpFunction, 'quadratic')
		omega_warped = omega + alpha .* (omega./pi - (omega./pi).^2);
	elseif strcmp(warpFunction, 'bilinear')
		z = exp(omega .* i);
		omega_warped = abs(-i .* log((z - alpha)./(1 - alpha.*z)));
    end

    omega_warped = [omega_warped ./ pi .* m];
    warpedFrame = interp1((1:m), frames(j).data, omega_warped, 'linear').';

    if isreal(frames(j).data(end))
        warpedFrame(end) = real(warpedFrame(end));
    end

    warpedFrame(isnan(warpedFrame)) = 0;
    warpedFreqs(j).data = warpedFrame;
    
%    if j==160
%        figure(1);
%        plot((1:m), omega_warped);
%    end
end
