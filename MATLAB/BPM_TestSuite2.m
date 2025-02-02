%bandlimits = [0 200 400 800 1600 3200];
bandlimits = [0];
samplerate = 8192;
%samplerate = 16384;
%samplerate = 32768;
scaling = 1.39; %best for [0] and 8192 and rangelimit = 0
%scaling = 1;
rangelimit = 0;
%rangelimit = 1;

x = control_optimizer('70AllNight.wav', bandlimits, samplerate, scaling, rangelimit)%
x70 = abs(((140 - x)/140)*100)%

x = control_optimizer('75TinCan.wav', bandlimits, samplerate, scaling, rangelimit)%
x75 = abs(((300 - x)/300)*100)%

x = control_optimizer('80ShadowOfDoubt.wav', bandlimits, samplerate, scaling, rangelimit)%
x80 = abs(((160 - x)/160)*100)%

x = control_optimizer('90MyShell.wav', bandlimits, samplerate, scaling, rangelimit)%
x90 = abs(((90 - x)/90)*100)%

x = control_optimizer('95DanceStudio.wav', bandlimits, samplerate, scaling, rangelimit)%
x95 = abs(((95 - x)/95)*100)%

x = control_optimizer('100SledgeHammer.wav', bandlimits, samplerate, scaling, rangelimit)%
x100 = abs(((100 - x)/100)*100)%

x = control_optimizer('105CapitolBlues.wav', bandlimits, samplerate, scaling, rangelimit)%
x105 = abs(((210 - x)/210)*100)%

x = control_optimizer('125YaleBoolaMarch.wav', bandlimits, samplerate, scaling, rangelimit)%
x125 = abs(((125 - x)/125)*100)%

x = control_optimizer('130ImSoConfused.wav', bandlimits, samplerate, scaling, rangelimit)%
x130 = abs(((260 - x)/260)*100)%

pcgavg = {x70, x75, x80, x90, x95, x100, x105, x125, x130};


avg_percent_error = ((x70 + x75 + x80 + x90 + x95 + x100 + x105 + x125 + x130)/9)
