
filename = ['sub_matrix.mat'];
load(filename);
amplitude=sub_matrix{23, 1}(:,2);
sampling_rate = 1000;
t = (1:length(amplitude))/sampling_rate;
time_length = length(amplitude)/sampling_rate;

figure('color',[1 1 1])
plot(t,amplitude,'k')
set(gca,'XLim',[0 time_length])
legend('original signal')
xlabel('Time(Seconds)')
ylabel('CSI amplitude')
%save_figure(figure,'original.')

%figure('color',[1 1 1])
%hampel(amplitude)

figure('color',[1 1 1])
[amplitude_hampel,outliers] = hampel(amplitude);
plot(t,amplitude_hampel,'k')
set(gca,'XLim',[0 time_length])
legend('hampel signal')
xlabel('Time(Seconds)')
ylabel('CSI amplitude')
%save_figure(figure,'hampel.')

figure('color',[1 1 1])
plot(t,wifi_butterworth_function(amplitude_hampel'),'k')
set(gca,'XLim',[0 time_length])
legend('butterworth filtered signalk')
xlabel('Time(Seconds)')
ylabel('CSI amplitude')
%save_figure(figure,'butterworth.')

function save_figure(figure,savename)
    hfig = figure;
    figWidth = 5;  % 设置图片宽度
    figHeight = 5;  % 设置图片高度
    set(hfig,'PaperUnits','inches'); % 图片尺寸所用单位
    set(hfig,'PaperPosition',[0 0 figWidth figHeight]);
    fileout = [savename]; % 输出图片的文件名
    print(hfig,[fileout,'tif'],'-r600','-dtiff'); % 设置图片格式、分辨率
end