function tlag = compare_signal(lfr,tds,iT,iL,time, plotit, printdelay)
%COMPARE_SIGNAL Plotter function for both tds and lfr data

CH12diplen = 7.53; % effective length of L13 and L21
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

ldata = lfr.EAC.data(:,1,iL); % lfr - voltage
tdata = -tds.WAVEFORM_DATA_VOLTAGE.data(2,1:tSamps,iT); % Voltage data
twdata = tds.WAVEFORM_DATA.data(2,1:tSamps,iT) * CH12diplen; % converted voltage data
% Channel 2
ldata2 = lfr.EAC.data(:,2,iL);
tdata2 = tds.WAVEFORM_DATA_VOLTAGE.data(1,1:tSamps,iT);
twdata2 = -tds.WAVEFORM_DATA.data(1,1:tSamps,iT) * CH12diplen;

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

% Getting lags from voltage data
[r,lags] = xcorr(tdata,cutldata);
[~, lagindx] = max(r);
slag = lags(lagindx);
tlag = slag/tsr;
relative_lag = tlag*lsr; %#ok<NASGU>

% Getting lags from converted voltage data
[r,lags] = xcorr(twdata,cutldata);
[~, lagindx] = max(r);
swlag = lags(lagindx);
twlag = swlag/tsr;

if printdelay == 1
    fprintf('delay between lfr and tds trigger: %fs\n',1e-9*(tt0-lt0))
    % add twlag
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
    loglog(lfq(lfq>100),lsp(lfq>100),'DisplayName','LFR')
    hold on
    loglog(tfq(tfq>100),tsp(tfq>100),'DisplayName','TDS')
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
[r,lags] = xcorr(tdata2,cutldata2);
[~, lagindx] = max(r);
slag = lags(lagindx);
tlag = slag/tsr;
relative_lag = tlag*lsr; %#ok<NASGU>
% converted waveform lag
[r,lags] = xcorr(twdata2,cutldata2);
[~, lagindx] = max(r);
swlag2 = lags(lagindx);
twlag2 = swlag2/tsr;

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
    loglog(lfq,lsp,'DisplayName','LFR')
    hold on
    loglog(tfq,tsp,'DisplayName','TDS')
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


% Plotting the converted waveform data
tdata = twdata;
tdata2 = twdata2;
if plotit==1
    subplot(2,3,2)
    plot(tt, tdata,'DisplayName','TDS')
    hold on
    plot(lt, ldata,'DisplayName','LFR')
    datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
    xline(time,'DisplayName','wave detected')
    title('Channel 1 (V1-V2) waveforms (converted TDS)')
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
    title('Channel 2 (V1-V3) waveforms (converted TDS)')
    ylabel('voltage (V)')
    xlabel('time')
    legend()
    hold off
    
    
    
    
    subplot(2,3,1)
    plot(tt, tdata,'DisplayName','TDS')
    hold on
    if swlag>0
         plot(tt(1+swlag:end), cutldata(1:end-swlag),'DisplayName','shifted LFR')
    end
    if swlag<0
         plot(tt(1:end+swlag), cutldata(1-swlag:end),'DisplayName','shifted LFR')
    end
    datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
    plot(tt, cutldata,'DisplayName','unshifted LFR data')
    title(sprintf('Channel 1 (V1-V2) waveform // calculated lag: %fms', twlag*1e3))
    ylabel('voltage (V)')
    xlabel('time')
    legend()
    hold off

    subplot(2,3,3)
    [tsp, tfq, ~] = make_spectrum(tdata, tSamps, 1./tsr, 100000, 0);
    [lsp, lfq, ~] = make_spectrum(cutldataog, cutlSamps, 1./lsr);
    loglog(lfq(lfq>100),lsp(lfq>100),'DisplayName','LFR')
    hold on
    loglog(tfq(tfq>100),tsp(tfq>100),'DisplayName','TDS')
    title('Channel 1 (V1-V2) spectrum')
    ylabel('PSD (V^{2}/Hz)')
    xlabel('Frequency (Hz)')
    legend()

    subplot(2,3,4)
    plot(tt, tdata2,'DisplayName','TDS')
    hold on
    if swlag2>0
         plot(tt(1+swlag2:end), cutldata2(1:end-swlag2),'DisplayName','shifted LFR')
    end
    if swlag2<0
         plot(tt(1:end+swlag2), cutldata2(1-swlag2:end),'DisplayName','shifted LFR')
    end
    datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
    plot(tt, cutldata2,'DisplayName','unshifted LFR')
    title(sprintf('Channel 2 (V1-V3) waveform // calculated lag: %fms', twlag2*1e3))
    ylabel('voltage (V)')
    xlabel('time')
    legend()
    hold off
    
    subplot(2,3,6)
    [tsp, tfq, ~] = make_spectrum(tdata2, tSamps, 1./tsr, 100000, 0);
    [lsp, lfq, ~] = make_spectrum(cutldata2og, cutlSamps, 1./lsr);
    loglog(lfq,lsp,'DisplayName','LFR')
    hold on
    loglog(tfq,tsp,'DisplayName','TDS')
    title('Channel 2 (V1-V3) spectrum')
    ylabel('PSD (V^{2}/Hz)')
    xlabel('Frequency (Hz)')
    legend()

    sgt =  sgtitle(sprintf('TDS - LFR comparison, TDS from WAVEFORM_DATA, event on %s', nam), 'interpreter', 'none');
    sgt.FontSize = 20;
    sgt.FontWeight = 'bold';
    set(gcf, 'Position', [100 100 2600 1000]);
    print(gcf,sprintf('plots/%stds-lfr_WAVEFORM_DATA_.png', nam),'-dpng','-r300');
    close(gcf)
end
end

