function output=control(song1, bandlimits, maxfreq)

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
%        MAXFREQ = 8192
  

  if nargin < 1, song1 = 'None'; end
  if nargin < 2, bandlimits = [0 200 400 800 1600 3200]; end
  if nargin < 3, maxfreq = 8192; end
  
  % Length (in samples) of 5 seconds of the song
  
  sample_size = floor(10*maxfreq); 
  scaling = 1.334;
  
  % Takes in the two wave files
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  RECORDING LOGIC  %%%%%%%%%%%%
if (strcmp(song1, 'None'))
	recObj = audiorecorder;
	disp('Start Speaking')
	recordblocking(recObj, 10);
	disp('End of Recording');
    x1 = getaudiodata(recObj);
    short_sample = x1;%short_song(start:stop);
    scaling = 1;
else
    x1 = wavread(song1);
    short_song = x1;
    short_length = length(x1);
    start = floor(short_length/2 - sample_size/2);
    stop = floor(short_length/2 + sample_size/2);
  
  % Finds a 5 second representative sample of each song
  
  short_sample = short_song(start:stop);
end

%  x1 = getaudiodata(recObj);
  %x2 = wavread(song2);
  
  % Differentiates between the shorter and longer signal
  
  %if length(x1) < length(x2)
  %  short_song = x1;
    %long_song = x2;
 %   short_length = length(x1);
 % else
   % short_song = x2;
    %long_song = x1;
   % short_length = length(x2);
 % end
 
  %start = floor(short_length/2 - sample_size/2);
  %stop = floor(short_length/2 + sample_size/2);
  
  % Finds a 5 second representative sample of each song
  
  %short_sample = short_song(start:stop);
  %long_sample = long_song(start:stop);
  
  % Implements beat detection algorithm for each song
  
  %status = 'filtering first song...';
  a = filterbank(short_sample, bandlimits, maxfreq);
  %plot fft(a);
  %status = 'windowing first song...';
  b = hwindow(a, 0.2, bandlimits, maxfreq);
  %plot b;
  %status = 'differentiating first song...';
  c = diffrect(b, length(bandlimits));
  %TODO: create subplots to show all signals together and each individually
  %
  plot(c);
  %status = 'comb filtering first song...';
  
  % Recursively calls timecomb to decrease computational time
  
  d = timecomb(c, 2, 60, 240, bandlimits, maxfreq);
  %e = timecomb(c, .5, d-2, d+2, bandlimits, maxfreq);
  %f = timecomb(c, .1, e-.5, e+.5, bandlimits, maxfreq);
  %g = timecomb(c, .01, f-.1, f+.1, bandlimits, maxfreq);
  g = floor(scaling*d);
  
 audio_bpm = g
  %short_song_bpm = d
  
  output = audio_bpm;

