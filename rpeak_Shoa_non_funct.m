%BY: SHOA RUSSELL 
% heart rate detection with flagging technique
%clearvars -except ecgData
sample_freq=250;
k=1;
b=1;

%*** two seperate window in order to allow overlap in the data 
window_outer=50; % pick a number that 1000 is divisible by 
window_small=125-1; %value minus 1 
window_large=500; % this window is used to find the relative max in the...
                     % surrounding area 
num_set_sec=250/window_small;
flagthresh=1000;
replaced=0;

if length(ecgData)<window_large
    error('too little of samples')

end 

for n=1:window_outer:floor((length(ecgData))-window_large)
 samples = ecgData(n:(n+window_small)); % sends 50 samples at a time to the HR detector
                                   %window overlap of small-outer samples
                                   % estimate for max of 135 bmp used to
                                   % get the smallest interval of data to
                                   % send 111.1 samples between hb
 ecgshort = ecgData(n:(n+window_large-1)); % sends 428 samples at a time to the HR detector 
                                   % to calculate the max in the largest hr
                                   % sample period 35bmp used to calculate
                                   % this so theres about 450 samples between
                                   % each hb max
flagshort = flagData(n:(n+window_large-1)); %% grab a segment of the 
                                            %% flag data, use large window to
                                            %surrounding area of signal 

% Perform CWT with scale 3 and wavelet Coiflet-1 on larger window 
cof=cwt(ecgshort,3,'coif1'); % finds the mean in a outer sample window 
% R -Peak Identification
cofsq=cof.^2;
threshold=mean(cofsq); % determine the threshhold in the larger window 
peak=0;

% Perform CWT with scale 3 and wavelet Coiflet-1 on samples window 
cof2=cwt(samples,3,'coif1'); % finds the mean in a large sample window
% R -Peak Identification
cofsq2=cof.^2;
% Remove edge effects
cofsq2(1)=0;
cofsq2(end)=0;

%calculates how many peaks over in the sample are over the large window 
% threshold
ntime=length(samples);

for i=1:ntime
    if cofsq(i) >=threshold % is the sample value larger than the threshold?
        peak=peak+1;
    end
end

% Beats per minute
beats= ((peak)/2*60);  % convert to bpm since samples occur 20 times in 1 s 
Heartbeats(b)=beats; % give the HR for the sample period
flagsum(b)=sum(flagshort,2);
b=b+1;
end

Scaler=mean(Heartbeats);
Heartbeats=(Heartbeats./Scaler).*60;

ntime=length(Heartbeats);
    for i=1:ntime
        if (flagsum(i)>flagthresh) 
     % if there is too many flags in this area use the sum of the 5 previous HRs 
            % detected instead
        if i>20 % if not one of the first 20 HRs 
        Heartbeats(i)= mean(Heartbeats(i-19:i));%set = to the mean of the previos HRs
        replaced=replaced+1;
         else 
            Heartbeats(i)=Heartbeats(i);
         end%ends inner if 
    end %ends if
    
    %threshold check in case of spikes in data 
%         if Heartbeats(i) >135 
%         Heartbeats(i) =135;
%         elseif Heartbeats(i)<35 
%         Heartbeats(i)=35;
%         end 
end %ends for 

for n=1:20
     sumbeats(n)=Heartbeats(n);
 end     
for n=20:length(Heartbeats)
    sumbeats(n)=sum(Heartbeats((n-19):n))/20;
end

t = 0:1/sample_freq:floor((length(ecgData)-window_large)/sample_freq);                                    
t2 = 0:(window_outer):(length(ecgData)-window_large-1);
HR=figure('Name', ['ECG HEART RATE'])
subplot(3,1,1),plot (ecgData(1:(length(ecgData)-window_large-1)));
title('ECG Data')
xlabel('Samples')
ylabel('3.3v/1024 conversion factor')
subplot(3,1,2),plot (t2,Heartbeats);
hold on
str = sprintf('Heart Beats with flagging threshold of %d every %d samples',flagthresh, window_large);
title(str)
xlabel('Samples')
ylabel('Heart Rate')
plot(t2,sumbeats,'m');
hold off

subplot(3,1,3),plot (flagData(1:(length(flagData)-window_large-1)));
title('Flags')
xlabel('Samples')
ylabel('Count')
replaced
%saveas(HR,[pathName,'\figures',num2str(k),'\','HeartRate_Shoa',ShortEndName],'fig')
 