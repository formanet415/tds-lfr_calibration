function compare_signal(lfr,tds,iT,iL,time)
%COMPARE_SIGNAL Plotter function for both tds and lfr data

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

if lsr<500
    return
end

figure;
plot(lt, ldata)
datetick('x', 'MM:SS:FFF', 'keeplimits', 'keepticks')
hold on
plot(tt, tdata)

end

