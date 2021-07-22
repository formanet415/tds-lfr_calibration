function tlag = compare_signal(lfr,tds,iT,iL,time, plotit)
%COMPARE_SIGNAL Plotter function for both tds and lfr data

tlag = false;
lt0 = double(spdfdatenumtott2000(lfr.Epoch.data(iL)));
tt0 = double(spdfdatenumtott2000(tds.Epoch.data(iT)));
lSamps = double(2048);
tSamps = double(tds.SAMPS_PER_CH.data(iT));
lsr = double(lfr.SAMPLING_RATE.data(iL));
tsr = double(tds.SAMPLING_RATE.data(iT));
ldt = double(1e9*(lSamps/lsr));
tdt = double(1e9*(tSamps/tsr));
lt1 = lt0+ldt;
tt1 = tt0+tdt;
lt = linspace(lt0,lt1,lSamps);
tt = linspace(tt0,tt1,tSamps);
lt = spdftt2000todatenum(lt');
tt = spdftt2000todatenum(tt');

ldata = lfr.EAC.data(:,1,iL);
tdata = tds.WAVEFORM_DATA_VOLTAGE.data(2,1:tSamps,iT);
ldata2 = lfr.EAC.data(:,2,iL);
tdata2 = tds.WAVEFORM_DATA_VOLTAGE.data(1,1:tSamps,iT);

if lsr<500
    return
end

time = spdftt2000todatenum(time);
wave = spdfencodett2000(time);
nam = erase(wave,':');
if plotit==1
    f = figure('Position', [100 100 1600 1000]);
    plot(tt, tdata,'DisplayName','TDS data')
    hold on
    plot(lt, ldata,'DisplayName','LFR data')
    datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
    xline(time,'DisplayName','wave detected')
    title(sprintf('TDS and LFR V1-V2 waveforms with an event at %s', wave))
    ylabel('voltage (V)')
    xlabel('time')
    legend()
    print(f,sprintf('plots/%soriginal_data_CH1.png', nam),'-dpng','-r300');
    close(f)
    
    f = figure('Position', [100 100 1600 1000]);
    plot(tt, tdata2,'DisplayName','TDS data')
    hold on
    plot(lt, ldata2,'DisplayName','LFR data')
    datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
    xline(time,'DisplayName','wave detected')
    title(sprintf('TDS and LFR V1-V3 waveforms with an event at %s', wave))
    ylabel('voltage (V)')
    xlabel('time')
    legend()
    print(f,sprintf('plots/%soriginal_data_CH2.png', nam),'-dpng','-r300');
    close(f)
end


[d, iL0] = min(abs(lt-tt(1)));
[d, iL1] = min(abs(lt-tt(end)));

cutldata = double(ldata(iL0:iL1));
p = size(tt,1);
q = size(cutldata,1);
cutldata = resample(cutldata, p, q);


[r,lags] = xcorr(tdata,cutldata);
[d, lagindx] = max(r);
slag = lags(lagindx);
tlag = slag/tsr;
relative_lag = tlag*lsr;
fprintf('lag in seconds %es\n',tlag);
fprintf('relative lag is %f lfr samples\n', relative_lag)


if plotit==1
    f = figure('Position', [100 100 1600 1000]);
    plot(tt, tdata,'DisplayName','TDS data')
    hold on
    if slag>0
         plot(tt(1+slag:end), cutldata(1:end-slag),'DisplayName','shifted LFR data')
    end
    if slag<0
         plot(tt(1:end+slag), cutldata(1-slag:end),'DisplayName','shifted LFR data')
    end
    datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
    plot(tt, cutldata,'DisplayName','unshifted LFR data')
    title(sprintf('TDS and LFR V1-V2 waveform lag - event at %s', wave))
    ylabel('voltage (V)')
    xlabel('time')
    legend()
    print(f,sprintf('plots/%sshifted_data_CH1.png', nam),'-dpng','-r300');
    %saveas(f,sprintf('plots/%sshifted_data.png', nam))
    close(f)
    hold off
end

cutldata2 = double(ldata2(iL0:iL1));
p = size(tt,1);
q = size(cutldata2,1);
cutldata2 = resample(cutldata2, p, q);

[r,lags] = xcorr(tdata2,cutldata2);
[d, lagindx] = max(r);
slag = lags(lagindx);
tlag = slag/tsr;
relative_lag = tlag*lsr;
fprintf('CH2 lag in seconds %es\n',tlag);
fprintf('CH2 relative lag is %f lfr samples\n', relative_lag)


if plotit==1
    f = figure('Position', [100 100 1600 1000]);
    plot(tt, tdata2,'DisplayName','TDS data')
    hold on
    if slag>0
         plot(tt(1+slag:end), cutldata2(1:end-slag),'DisplayName','shifted LFR data')
    end
    if slag<0
         plot(tt(1:end+slag), cutldata2(1-slag:end),'DisplayName','shifted LFR data')
    end
    datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
    plot(tt, cutldata2,'DisplayName','unshifted LFR data')
    title(sprintf('TDS and LFR V1-V3 waveform lag - event at %s', wave))
    ylabel('voltage (V)')
    xlabel('time')
    legend()
    print(f,sprintf('plots/%sshifted_data_CH2.png', nam),'-dpng','-r300');
    %saveas(f,sprintf('plots/%sshifted_data.png', nam))
    close(f)
    hold off
end

end

