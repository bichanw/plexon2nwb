%For filtering 60Hz Line noise 
%based on Matlab original
%Manoj 12/03/2018

function [data]=notchfilt(input,Fs)

d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',Fs);
data = filtfilt(d,input);
end

%{
%Testing 
Data_fr=notchfilt(Data,1000);

[popen,fopen] = periodogram(Data_Or,[],[],Fs);
[pbutt,fbutt] = periodogram(Data_fr,[],[],Fs);

plot(fopen,20*log10(abs(popen)),fbutt,20*log10(abs(pbutt)),'--')
%}