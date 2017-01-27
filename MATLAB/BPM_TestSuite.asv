%bandlimits = [0 200 400 800 1600 3200];
bandlimits = [0];
samplerate = 16384;
scaling = 1.5;
rangelimit = 0;

x = control_optimizer('35BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x35 = abs(((140 - x)/140)*100)%

x = control_optimizer('55BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x55 = abs(((110 - x)/110)*100)%

x = control_optimizer('60BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x60 = abs(((120 - x)/120)*100)%

x = control_optimizer('65BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x65 = abs(((130 - x)/130)*100)%

x = control_optimizer('70BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x70 = abs(((140 - x)/140)*100)%

x = control_optimizer('75BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x75 = abs(((150 - x)/150)*100)%

x = control_optimizer('80BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x80 = abs(((160 - x)/160)*100)%

x = control_optimizer('85BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x85 = abs(((85 - x)/85)*100)%

x = control_optimizer('90BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x90 = abs(((90 - x)/90)*100)%

x = control_optimizer('95BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x95 = abs(((95 - x)/95)*100)%

x = control_optimizer('100BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x100 = abs(((100 - x)/100)*100)%

x = control_optimizer('105BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x105 = abs(((105 - x)/105)*100)%

x = control_optimizer('110BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x110 = abs(((110 - x)/110)*100)%

x = control_optimizer('115BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x115 = abs(((115 - x)/115)*100)%

x = control_optimizer('120BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x120 = abs(((120 - x)/120)*100)%

x = control_optimizer('125BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x125 = abs(((125 - x)/125)*100)%

x = control_optimizer('145BPM.wav', bandlimits, samplerate, scaling, rangelimit)%
x145 = abs(((145 - x)/145)*100)%

pcgavg = {x35, x55, x60, x65, x70, x75, x80, x85, x90, x95, x100, x105, x110, x115, x120, x125, x145};


avg_percent_error = ((x35 + x55 + x60 + x65 + x70 + x75 + x80 + x85 + x90 + x95 + x100 + x105 + x110 + x115 + x120 + x125 + x145)/17)
