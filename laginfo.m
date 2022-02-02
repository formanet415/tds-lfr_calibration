function laginfo(lags,type)
%LAGINFO Function that plots and prints info about the tds-lfr lags
%   LAGS = lags from the comparing function.
lags=lags(lags~=-1);

lsr = 24576;
lsp = 1/lsr;
%lags = lags(lags/lsp<10);
%lags = lags(lags/lsp>-10);
disp('Time in seconds that TDS is ahead of LFR (negative values mean that LFR is ahead)')
fprintf('Mean:   %.16fs\nMedian: %.16fs\nStdev.:  %.16fs\n',mean(lags),median(lags),std(lags))
if mean(lags)>0
    fprintf('TDS is ahead by %.16f LFR samples\n', median(lags/lsp))
else
    fprintf('LFR is ahead by %.16f LFR samples\n', -median(lags/lsp))
end
    
stem(lags)
hold on
title(sprintf('TDS-LFR lags on %s',type))
ylabel('lag (s)')
xlabel('events')
yline(mean(lags))
yline(median(lags),'green')
yline(lsp, 'color', 'red')
legend('lags','mean','median','lfr sampling period')

set(gcf, 'Position', [100 100 1200 700]);
print(gcf,sprintf('TDS-LFR_%s_lags_v3.png', type),'-dpng','-r300');
close(gcf)

stem(lags/lsp)
hold on
title(sprintf('TDS-LFR lags on %s',type))
ylabel('lag (LFR samples)')
xlabel('events')
yline(mean(lags/lsp))
yline(median(lags/lsp),'green')
yline(1, 'color', 'red')
legend('lags','mean','median','lfr sampling period')

set(gcf, 'Position', [100 100 1200 700]);
print(gcf,sprintf('TDS-LFR_%s_lags_2_v3.png', type),'-dpng','-r300');
close(gcf)
end

