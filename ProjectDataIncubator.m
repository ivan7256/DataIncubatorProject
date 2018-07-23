%Created by Ivan A. Trujillo-Priego

clear all
close all
clc

filename = 'myGlucose.xlsx';
[num,txt,raw] = xlsread(filename,2);
Upper_Range=140;
Lower_Range=50;
%Column 1 ID scan, Column 2 Date, Colum 3 Type (scan or recorded, Column 4
%Record 15 min , Column 5 scanned; Coumn 8 Food or not
Data=[num(:,1) num(:,2) num(:,3) num(:,4) num(:,5) num(:,8)];

Date   = datevec(Data(:,2));
Time=datenum(Date);
Measurements=Data(:,4);
Scanned=Data(:,5);

Index_Change_Day=[];
j=1;
for i=2:length(Date)
    if Date(i,3) - Date(i-1,3) ~=0
        Index_Change_Day(j)=i;
        j=j+1;
    end
end

Time_Day1=Date(1:Index_Change_Day(1)-1,:);
Time_Day2=Date(Index_Change_Day(1):Index_Change_Day(2)-1,:);
Time_Day2_formated=datenum(Time_Day2);

for i=1:length(Index_Change_Day)-1
    Day{1}=Measurements(1:Index_Change_Day(i)-1);
    Day{i+1}=Measurements(Index_Change_Day(i):Index_Change_Day(i+1)-1);
end

Day2=cell2mat(Day(2));

for i=1:length(Day2)
    if isnan(Day2(i))
        Day2(i)=Day2(i-1);
    end
end

y = sgolayfilt(Day2,4,15); %filtered values



[HighValues,High_Index,High_Value_WidthWidth,Prominence]=findpeaks(y,'MinPeakDistance',60,'MinPeakHeight',Upper_Range) % detect peaks that 
figure
set(gcf,'Name','Glucose Levels','NumberTitle','off')
set(gcf,'Color',[1,1,1])
findpeaks(y,'MinPeakDistance',60,'MinPeakHeight',Upper_Range,'Annotate','extents')
hline = refline([0 Mean]);
hline.Color = 'k';
hline.LineWidth = 2;
hline = refline([0 Upper_Range]);
hline.LineWidth = 1;
hline.Color = 'k';
hline.LineStyle= '--';
hline = refline([0 Lower_Range]);
hline.LineWidth = 1;
hline.Color = 'k';
hline.LineStyle= '--';
title('My Glucose Levels')
xlabel('Time')
ylabel('Glucose levels')
legend('Glucose','High Levels','Peak','Duration of Peak','Average Glucose','Set Upper Range','Set Low Range')



[Day2upper,Day2lower] = envelope(y,60,'analytic') % rms, analytic

Mean = mean(y);
MmeanPlusSTD = Mean + std(y);
meanMinusSTD = Mean - std(y);


peaks = [false; diff(diff(y) > 0) < 0; false];
troughs = [false; diff(diff(y) > 0) > 0; false]; %
t=linspace(1,length(troughs),length(troughs));

k=1;
Slope_Index=[];
for i = 1:length(High_Index)
    for j= 1:20
        if troughs(High_Index(i)-j)==1
           Slope_Index(k)=High_Index(i)-j; 
           k=k+1;
           break
        end
    end
end
prueba=[1 length(Time_Day2_formated)-1 length(Time_Day2_formated)-1 1];
prueby=[meanMinusSTD meanMinusSTD MmeanPlusSTD MmeanPlusSTD];

 prueba = linspace(0,1,length(Time_Day2_formated));
 prueby=linspace(meanMinusSTD,MmeanPlusSTD,length(prueba));

 fill([x flip(x)],[z zeros(size(z))],'k','LineStyle','none')




figure
set(gcf,'Name','Glucose Levels','NumberTitle','off')
set(gcf,'Color',[1,1,1])
plot(Time_Day2_formated,y,'LineWidth',2)
datetick('x','HH:MM')
hold
plot(Time_Day2_formated(High_Index),y(High_Index), 'ro')
plot(Time_Day2_formated(troughs),y(troughs), 'ro')
for i=1:length(HighValues)
plot([Time_Day2_formated(Slope_Index(i)) Time_Day2_formated(High_Index(i))], [y(Slope_Index(i)) HighValues(i)],'r','LineWidth',2)  
end
hline = refline([0 Mean]);
hline.Color = 'k';
hline.LineWidth = 2;
hline = refline([0 MmeanPlusSTD]);
hline.Color = 'k';
hline.LineStyle= '--';
hline = refline([0 meanMinusSTD]);
hline.Color = 'k';
hline.LineStyle= '--';
area(prueba,prueby)
grid on
title('My Glucose Levels detecting sharp spikes')
xlabel('Time')
ylabel('Glucose levels')
legend('Glucose','High Levels','Low Levels','Slope of Peaks','','Average Glucose','Upper Deviation','Lower Deviation')





