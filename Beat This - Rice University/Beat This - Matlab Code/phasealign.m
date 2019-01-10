function output = phasealign(sig, bpm, bandlimits, maxfreq)
%
% PHASEALIGN takes a time domain signal and returns the location of
% the sample where its first beat occurs. 
%
%     OFFSET = PHASEALIGN(SIG, BPM, BANDLIMITS, MAXFREQ) takes in a
%     signal, and outputs the index of the sample where the first
%     significant beat occurs. BPM is the tempo of the signal, and
%     BANDLIMITS and MAXFREQ are used to call beat detection
%     functions.
% 
%     Defaults are:
%        BANDLIMITS = [1 200 400 800 1600 3200]
%        MAXFREQ = 4096
  
  if nargin < 3, bandlimits = [1 200 800 1600 3200]; end
  if nargin < 4, maxfreq = 4096; end
  
  % Calculates the number of samples between beats
  
  siglen = floor(120/bpm*maxfreq);
  
  % Sets the muber of pulses in the comb filter
  
  num_pulses = 3;
  
  % Sets the length of the comb filter
  
  comblen = (num_pulses - 1)*siglen + 1;
  
  % Initializes comb filter
  
  comb = zeros(comblen,1);
  
  comb(1) = 1;
  
  % Constructs filter  
  for i = 1:(num_pulses - 1)
    comb(i*siglen + 1) = 1;
  end
  
  % gets a samble of the beginning of the signal
  
  sample = sig(1:num_pulses*siglen + 1);
  
  a = filterbank(sample, bandlimits, maxfreq);
  b = hwindow(a, 0.2, bandlimits, maxfreq);
  c = diffrect(b, length(bandlimits));
  
  % sums the output of DIFFRECT along the rows
  
  newsig = sum(c,2);
  
  % Calculates the energy of the filter convolved with newsig for
  % the first beat interval
  
  for i = 1:siglen
    phase1(i) = sum((comb.*newsig(i:(i+comblen - 1))).^2);
  end
  
  % Returns the index of the first pulse
  
  [a, output] = max(phase1);

  
  