function warped = vtln(input, warpFunction, alpha)
% warp a struct of frequencies using vocal tract length normalization

warped = struct();

for j = 1:length(input)
	
	m = length(input(j).x);
	X = 1:m;
	Xtmp = X(1:end-2)/(m-2)*pi;
	X_warped = X(1:end-2);
	
	if strcmp(warpFunction, 'asymmetric') | strcmp(warpFunction, 'symmetric')
		w0 = 7/8 * pi;
		if strcmp(warpFunction, 'symmetric') & alpha > 1
			w0 = 7/(8*alpha) * pi;
		end
		X_warped(find(Xtmp <= w0)) = alpha .* X(find(Xtmp <= w0));
		w = X_warped(find(Xtmp > w0));
		X_warped(find(Xtmp > w0)) = alpha * w0 + (pi - alpha * w0)/(pi - w0) .* (w - w0);
	elseif strcmp(warpFunction, 'power')
		X_warped = pi .* (Xtmp./pi) .^ alpha;
	elseif strcmp(warpFunction, 'quadratic')
		X_warped = Xtmp + alpha .* (Xtmp./pi - (Xtmp./pi).^2);
	elseif strcmp(warpFunction, 'bilinear')
		z = exp(Xtmp .* i);
		X_warped = abs(-i .* log((z - alpha)./(1 - alpha.*z)));
	end

	X_warped = [1 2 X_warped/pi*m+2];
	warped(j).x = real(interp1(X, input(j).x, X_warped));
end

