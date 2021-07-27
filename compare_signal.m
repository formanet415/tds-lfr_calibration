function tlag = compare_signal(lfr,tds,iT,iL,time, plotit, printdelay)
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
tdata = -tds.WAVEFORM_DATA_VOLTAGE.data(2,1:tSamps,iT);
ldata2 = lfr.EAC.data(:,2,iL);
tdata2 = tds.WAVEFORM_DATA_VOLTAGE.data(1,1:tSamps,iT);

if lsr<500
    return
end

time = spdftt2000todatenum(time);
wave = spdfencodett2000(time);
nam = erase(wave,':');


[~, iL0] = min(abs(lt-tt(1)));
[~, iL1] = min(abs(lt-tt(end)));

cutldataog = double(ldata(iL0:iL1));
cutlSamps = size(double(lt(iL0:iL1)),1);
p = size(tt,1);
q = size(cutldataog,1);
cutldata = resample(cutldataog, p, q);


[r,lags] = xcorr(tdata,cutldata);
[~, lagindx] = max(r);
slag = lags(lagindx);
tlag = slag/tsr;
relative_lag = tlag*lsr; %#ok<NASGU>

if printdelay == 1
    fprintf('delay between lfr and tds trigger: %fs\n',1e-9*(tt0-lt0))
end
    
if plotit==1
    subplot(2,3,2)
    plot(tt, tdata,'DisplayName','TDS')
    hold on
    plot(lt, ldata,'DisplayName','LFR')
    datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
    xline(time,'DisplayName','wave detected')
    title('Channel 1 (V1-V2) raw waveforms')
    ylabel('voltage (V)')
    xlabel('time')
    legend()
    hold off
    
    subplot(2,3,5)
    plot(tt, tdata2,'DisplayName','TDS')
    hold on
    plot(lt, ldata2,'DisplayName','LFR')
    datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
    xline(time,'DisplayName','wave detected')
    title('Channel 2 (V1-V3) raw waveforms')
    ylabel('voltage (V)')
    xlabel('time')
    legend()
    hold off
    
    
    
    
    subplot(2,3,1)
    plot(tt, tdata,'DisplayName','TDS')
    hold on
    if slag>0
         plot(tt(1+slag:end), cutldata(1:end-slag),'DisplayName','shifted LFR')
    end
    if slag<0
         plot(tt(1:end+slag), cutldata(1-slag:end),'DisplayName','shifted LFR')
    end
    datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
    plot(tt, cutldata,'DisplayName','unshifted LFR data')
    title(sprintf('Channel 1 (V1-V2) waveform // calculated lag: %fms', tlag*1e3))
    ylabel('voltage (V)')
    xlabel('time')
    legend()
    hold off

    subplot(2,3,3)
    [tsp, tfq, ~] = make_spectrum(tdata, tSamps, 1./tsr, 100000, 0);
    [lsp, lfq, ~] = make_spectrum(cutldataog, cutlSamps, 1./lsr);
    semilogx(tfq(tfq>100),tsp(tfq>100),'DisplayName','TDS')
    hold on
    loglog(lfq(lfq>100),lsp(lfq>100),'DisplayName','LFR')
    title('Channel 1 (V1-V2) spectrum')
    ylabel('PSD (V^{2}/Hz)')
    xlabel('Frequency (Hz)')
    legend()

end
cutldata2og = double(ldata2(iL0:iL1));
p = size(tt,1);
q = size(cutldata2og,1);
cutldata2 = resample(cutldata2og, p, q);

[r,lags] = xcorr(tdata2,cutldata2);
[~, lagindx] = max(r);
slag = lags(lagindx);
tlag = slag/tsr;
relative_lag = tlag*lsr; %#ok<NASGU>
%fprintf('CH2 lag in seconds %es\n',tlag);
%fprintf('CH2 relative lag is %f lfr samples\n', relative_lag)


if plotit==1
    subplot(2,3,4)
    plot(tt, tdata2,'DisplayName','TDS')
    hold on
    if slag>0
         plot(tt(1+slag:end), cutldata2(1:end-slag),'DisplayName','shifted LFR')
    end
    if slag<0
         plot(tt(1:end+slag), cutldata2(1-slag:end),'DisplayName','shifted LFR')
    end
    datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
    plot(tt, cutldata2,'DisplayName','unshifted LFR')
    title(sprintf('Channel 2 (V1-V3) waveform // calculated lag: %fms', tlag*1e3))
    ylabel('voltage (V)')
    xlabel('time')
    legend()
    hold off
    
    subplot(2,3,6)
    [tsp, tfq, ~] = make_spectrum(tdata2, tSamps, 1./tsr, 100000, 0);
    [lsp, lfq, ~] = make_spectrum(cutldata2og, cutlSamps, 1./lsr);
    loglog(tfq,tsp,'DisplayName','TDS')
    hold on
    loglog(lfq,lsp,'DisplayName','LFR')
    title('Channel 2 (V1-V3) spectrum')
    ylabel('PSD (V^{2}/Hz)')
    xlabel('Frequency (Hz)')
    legend()

    sgt =  sgtitle(sprintf('TDS - LFR comparison, event on %s', nam));
    sgt.FontSize = 20;
    sgt.FontWeight = 'bold';
    set(gcf, 'Position', [100 100 2600 1000]);
    print(gcf,sprintf('plots/%stds-lfr.png', nam),'-dpng','-r300');
    close(gcf)
end
end

