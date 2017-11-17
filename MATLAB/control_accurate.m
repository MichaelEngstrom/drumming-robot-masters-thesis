function output=control_accurate(song1, bandlimits, maxfreq)

% CONTROL takes in the names of two .wav files, and outputs their
% combination, beat-matched, and phase aligned.
%
%     SIGNAL = CONTROL(SONG1, SONG2, BANDLIMITS, MAXFREQ) takes in
%     the names of two .wav files, as strings, and outputs their
%     sum. BANDLIMITS and MAXFREQ are used to divide the signal for
%     beat-matching
%
%     Defaults are:
%        BANDLIMITS = [0 200 400 800 1600 3200]
%        MAXFREQ = 4096
  
  if nargin < 1, song1 = 'None'; end
%  if nargin < 2, bandlimits = [0 200 400 800 1600 3200]; end
  %if nargin < 3, maxfreq = 16384; end
  if nargin < 2, bandlimits = [0]; end
  if nargin < 3, maxfreq = 16384; end
 %%%%% 1/25/2016 BEST: 16384, BL[0], scaling=.73, timecomb(c, 5, 60, 240,
 %%%%% bandlimits, maxfreq) i.e. acc=granularity=5 for timecomb,
 %%%%% windowing=0.1
  
  % Length (in power-2 samples) of the song
  
  sample_size = floor(16*maxfreq); 
  scaling = 0.74;   % Experimentally derived
%  scaling = 1;  
  % Takes in the two wave files
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  RECORDING LOGIC  %%%%%%%%%%%%
if (strcmp(song1, 'None'))
	recObj = audiorecorder;
	disp('Start of Recording')
	recordblocking(recObj, 10);
	disp('End of Recording');
    x1 = getaudiodata(recObj);
    short_sample = x1;
else
    x1 = wavread(song1);
    short_song = x1;
    short_length = length(x1);
    start = floor(short_length/2 - sample_size/2);
    stop = floor(short_length/2 + sample_size/2);
  
  % Finds a 5 second representative sample of each song
  
  short_sample = short_song(start:stop);
end
  
  % Implements beat detection algorithm for each song
  
  status = 'filtering first song...';
  a = filterbank(short_sample, bandlimits, maxfreq);
  status = 'windowing first song...';
  b = hwindow(a, 0.1, bandlimits, maxfreq);
  status = 'differentiating first song...';
  c = diffrect(b, length(bandlimits));
%  plot(c);
  status = 'comb filtering first song...';
  
  % Recursively calls timecomb to decrease computational time
  
  d = timecomb(c, 5, 60, 240, bandlimits, maxfreq);
  e = timecomb(c, .5, d-2, d+2, bandlimits, maxfreq);
  f = timecomb(c, .1, e-.5, e+.5, bandlimits, maxfreq);
  g = timecomb(c, .01, f-.1, f+.1, bandlimits, maxfreq);
  h = floor(scaling*g);
  
  % We want 60-120 BPM, so scale harmonics into range. Assume 240 Max
  % and 15 Min BPM in audio input sample.
  if ((h > 120) || (h < 60)) % Only scale if out of range
      if (h < 30 )
          h = 3*h;      %double if less than 60, assume never below 30BPM
      elseif ((h > 30) && (h < 60))
          h = 2*h;      %double if less than 60, assume never below 30BPM
      elseif (h > 121)
          h = 0.5*h;    %halve if more than 120 but less than 180
      %assume never over 300
      end
  end
  short_song_bpm = floor(h);
  %short_song_bpm = d
  
  output = short_song_bpm;

