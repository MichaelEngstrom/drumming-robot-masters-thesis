function output = timescale(sig, compression,  maxfreq)
 
% TIMESCALE scales the length of a singal to compression times its
% original length, where compression is less than one.  
%
%     SCALED = TIMESCALE(SIG, COMPRESSION, MAXFREQ) takes in a
%     signal in the time domain and scales its length, thus
%     increasing its tempo. It scales the signal by COMPRESSION,
%     where COMPRESSION is less than 1. It takes in MAXFREQ in
%     order to compute how often to remove samples.
%
%     Defauls are: 
%        MAXFREQ = 4096
  
  if nargin < 3, maxfreq = 4096; end
  
  n = length(sig);
  
  % Computes how often to remove samples
  
  timediv = floor(.08*maxfreq*2)
  
  % Computes how many samples to remove
  
  remove = floor((1-compression)*timediv)

  output = 0;
  
  % Remove samples, and recombine signals
  
  for i = remove+1:(timediv+remove):(n-timediv)
    output = [output;sig((i-remove):(i+timediv-remove))];
  end

