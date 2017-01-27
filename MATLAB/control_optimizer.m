function output=control_optimizer(song1, bandlimits, maxfreq, scaling, rangelimit)

% CONTROL takes in the names of two .wav files, and outputs their
% combination, beat-matched, and phase aligned.
%
%     SIGNAL = CONTROL(SONG1, BANDLIMITS, MAXFREQ, SCALING) takes in
%     the names of two .wav files, as strings, and outputs their
%     sum. BANDLIMITS and MAXFREQ are used to divide the signal for
%     beat-matching
%
%     Defaults are:
%        BANDLIMITS = [0 200 400 800 1600 3200]
%        MAXFREQ = 8192
%        SCALING = 1.5
%        RANGELIMIT = 1
  
%  if nargin < 2, bandlimits = [0 200 400 800 1600 3200]; end
%  BELOW ARE THE BEST ACCURATE PARAMETERIZED TESTING RESULTS
%       --- 7.3s compute time with 2% error ---
  if nargin < 2, bandlimits = [0]; end
  if nargin < 3, maxfreq = 16384; end
  if nargin < 4, scaling = 1.5; end % Experimentally derived
  if nargin < 5, rangelimit = 1; end % 1=keep 60<BPM<120, else raw value
      
  % Length (in power-2 samples) of the song
  sample_size = floor(16*maxfreq); 
  
  x1 = wavread(song1);
  
  % Differentiates between the shorter and longer signal
  
    short_song = x1;
    short_length = length(x1);

  start = floor(short_length/2 - sample_size/2);
  stop = floor(short_length/2 + sample_size/2);
  
  % Finds a 5 second representative sample of each song
  
  short_sample = short_song(start:stop);
  %long_sample = long_song(start:stop);
  
  % Implements beat detection algorithm for each song
  
  status = 'filtering first song...';
  a = filterbank(short_sample, bandlimits, maxfreq);
  status = 'windowing first song...';
  b = hwindow(a, 0.2, bandlimits, maxfreq);
  %b = hwindow(a, 0.01);
  status = 'differentiating first song...';
  c = diffrect(b, length(bandlimits));
  %plot(c);
  status = 'comb filtering first song...';
  
  % Recursively calls timecomb to decrease computational time
  
% d = timecomb(c, 5, 30, 240, bandlimits, maxfreq);
  d = timecomb(c, 2, 60, 240, bandlimits, maxfreq);
  e = timecomb(c, .5, d-2, d+2, bandlimits, maxfreq);
  f = timecomb(c, .1, e-.5, e+.5, bandlimits, maxfreq);
  g = timecomb(c, .01, f-.1, f+.1, bandlimits, maxfreq);
  h = floor(scaling*g);
% h = floor(scaling*d);
  
  % We want 60-120 BPM, so scale harmonics into range. Assume 240 Max
  % and 30 Min BPM in audio input sample.
  if (rangelimit == 1)
      while ((h > 120) || (h < 60)) % Only scale if INPUT is out of range
          if (h < 30 )
              h = 3*h;      %double if less than 60, assume never below 30BPM
          elseif ((h > 30) && (h < 60))
              h = 2*h;      %double if less than 60, assume never below 30BPM
          elseif (h > 121)
              h = 0.5*h;    %halve if more than 120 but less than 180
          %assume never over 300
          end
      end
  end %else raw value, skip range limiting
  short_song_bpm = h;
  
  output = short_song_bpm;

