function [tsf] = ApplyButterworthFilter(ts, order, fmin, fmax)

[b, a] = myButter(order, [fmin, fmax], 'bandpass');

tsf = filtfilt(b,a,ts);

end