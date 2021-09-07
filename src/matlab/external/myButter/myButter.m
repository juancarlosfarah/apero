function [Z, P, G] = myButter(n, W, pass)
% Digital Butterworth filter, either 2 or 3 outputs
% Jan Simon, 2014, BSD licence
% See docs of BUTTER for input and output
% Fast hack with limited accuracy: Handle with care!
% Until n=15 the relative difference to Matlab's BUTTER is < 100*eps
V = tan(W * 1.5707963267948966);
Q = exp((1.5707963267948966i / n) * ((2 + n - 1):2:(3 * n - 1)));
nQ = length(Q);
switch lower(pass)
   case 'stop'
      Sg = 1 / prod(-Q);
      c  = -V(1) * V(2);
      b  = (V(2) - V(1)) * 0.5 ./ Q;
      d  = sqrt(b .* b + c);
      Sp = [b + d, b - d];
      Sz = sqrt(c) * (-1) .^ (0:2 * nQ - 1);
   case 'bandpass'
      Sg = (V(2) - V(1)) ^ nQ;
      b  = (V(2) - V(1)) * 0.5 * Q;
      d  = sqrt(b .* b - V(1) * V(2));
      Sp = [b + d, b - d];
      Sz = zeros(1, nQ);
   case 'high'
      Sg = 1 ./ prod(-Q);
      Sp = V ./ Q;
      Sz = zeros(1, nQ);
   case 'low'
      Sg = V ^ nQ;
      Sp = V * Q;
      Sz = [];
   otherwise
      error('user:myButter:badFilter', 'Unknown filter type: %s', pass)
end
% Bilinear transform:
P = (1 + Sp) ./ (1 - Sp);
Z = repmat(-1, size(P));
if isempty(Sz)
   G = real(Sg / prod(1 - Sp));
else
   G = real(Sg * prod(1 - Sz) / prod(1 - Sp));
   Z(1:length(Sz)) = (1 + Sz) ./ (1 - Sz);
end
% From Zeros, Poles and Gain to B (numerator) and A (denominator):
if nargout == 2
   Z = G * real(poly(Z'));
   P = real(poly(P));
end
