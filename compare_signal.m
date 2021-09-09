function tlag = compare_signal(lfr,tds,iT,iL,time, plotit, printdelay)
%COMPARE_SIGNAL Plotter function for both tds and lfr data

%CH12diplen = 7.53; % effective length of L13 and L21
lt0 = lfr.epoch(iL);
tt0 = tds.epoch(iT);
lSamps = 2048;
tSamps = tds.samples_per_ch(iT);
lsr = lfr.samp_rate(iL);
tsr = tds.samp_rate(iT);
ldt = 1e9*(lSamps/lsr);
tdt = 1e9*(tSamps/tsr);
lt1 = lt0+ldt;
tt1 = tt0+tdt;
lt = linspace_int64(lt0,lt1,int64(lSamps));
tt = linspace_int64(tt0,tt1,int64(tSamps));
t00=min(tt0,lt0);
lt = (lt')-t00;
tt = (tt')-t00;

ldata = lfr.data(:,1,iL); % lfr - voltage

[b,a] = rc_filter(15e3, 47e-9, lfr.samp_rate(iL), 'high');
dcal_filt = filter(b,a,ldata);
ldata = filter(b,a,dcal_filt);

tdata = -tds.voltage_data(2,1:tSamps,iT); % Voltage data
% Channel 2
ldata2 = lfr.data(:,2,iL);

[b,a] = rc_filter(15e3, 47e-9, lfr.samp_rate(iL), 'high');
dcal_filt = filter(b,a,ldata2);
ldata2 = filter(b,a,dcal_filt);

tdata2 = tds.voltage_data(1,1:tSamps,iT);

if lsr<500
    tlag = -1;
    return
end

wave = datestr(spdftt2000todatenum(time), 31);
nam = erase(wave,':');


[~, iL0] = min(abs(lt-tt(1)));
[~, iL1] = min(abs(lt-tt(end)));

cutldataog = double(ldata(iL0:iL1));
cutlSamps = size(double(lt(iL0:iL1)),1);
p = size(tt,1);
q = size(cutldataog,1);
cutldata = resample(cutldataog, p, q);

% Getting lags from voltage data
[r1,lags1] = xcorr(tdata,cutldata);
[~, lagindx1] = max(r1);
slag1 = lags1(lagindx1);
tlag1 = slag1/tsr;
relative_lag1 = tlag1*lsr; %#ok<NASGU>


if printdelay == 1
    fprintf('delay between lfr and tds trigger: %fs\n',1e-9*(tt0-lt0))
end
plotit=1;
if plotit==1
    fprintf('Plotting indexes tds: %i, lfr: %i\n', iT, iL)
    subplot(2,3,2)
    plot(tt, tdata,'DisplayName','TDS')
    hold on
    plot(lt, ldata,'DisplayName','LFR with highpass')
    xline(time-t00,'DisplayName','wave detected')
    title('Channel 1 (V1-V2) raw waveforms')
    ylabel('voltage (V)')
    xlabel(sprintf('time since %s (ns)', wave))
    legend()
    hold off
    
    subplot(2,3,5)
    plot(tt, tdata2,'DisplayName','TDS')
    hold on
    plot(lt, ldata2,'DisplayName','LFR with Highpass')
    xline(time-t00,'DisplayName','wave detected')
    title('Channel 2 (V1-V3) raw waveforms')
    ylabel('voltage (V)')
    xlabel(sprintf('time since %s (ns)', wave))
    legend()
    hold off
    
    
    
    subplot(2,3,1)
    plot(tt, tdata,'DisplayName','TDS')
    hold on
    if slag1>0
         plot(tt(1+slag1:end), cutldata(1:end-slag1),'DisplayName','shifted LFR')
    end
    if slag1<0
         plot(tt(1:end+slag1), cutldata(1-slag1:end),'DisplayName','shifted LFR')
    end
    plot(tt, cutldata,'DisplayName','unshifted LFR data')
    title(sprintf('Channel 1 (V1-V2) waveform // calculated lag: %fms', tlag1*1e3))
    ylabel('voltage (V)')
    xlabel(sprintf('time since %s (ns)', wave))
    legend()
    hold off

    subplot(2,3,3)
    [tsp, tfq, ~] = make_spectrum(tdata, tSamps, 1./tsr, 100000, 0);
    [lsp, lfq, ~] = make_spectrum(cutldataog, cutlSamps, 1./lsr);
    
    loglog(tfq(tfq>100),tsp(tfq>100),'DisplayName','TDS')
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

%second channel lags
[r2,lags2] = xcorr(tdata2,cutldata2);
[~, lagindx2] = max(r2);
slag2 = lags2(lagindx2);
tlag2 = slag2/tsr;
relative_lag = tlag2*lsr; %#ok<NASGU>


[~, lagindx] = max(r1+r2);
slag = lags1(lagindx);
tlag = slag/tsr;
%fprintf('CH2 lag in seconds %es\n',tlag);
%fprintf('CH2 relative lag is %f lfr samples\n', relative_lag)


if plotit==1
    subplot(2,3,4)
    plot(tt, tdata2,'DisplayName','TDS')
    hold on
    if slag2>0
         plot(tt(1+slag2:end), cutldata2(1:end-slag2),'DisplayName','shifted LFR')
    end
    if slag2<0
         plot(tt(1:end+slag2), cutldata2(1-slag2:end),'DisplayName','shifted LFR')
    end
    plot(tt, cutldata2,'DisplayName','unshifted LFR')
    title(sprintf('Channel 2 (V1-V3) waveform // calculated lag: %fms', tlag2*1e3))
    ylabel('voltage (V)')
    xlabel(sprintf('time since %s (ns)', wave))
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

