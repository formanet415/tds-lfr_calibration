function lag = compare_TDS_signal(vt, wf,tsr)
%COMPARE_SIGNAL Plotter function for both tds and lfr data


% Getting lags from voltage data
[r1,lags1] = xcorr(vt,wf);
[~, lagindx1] = max(r1);
slag1 = lags1(lagindx1);
lag = slag1/tsr;
return


end

