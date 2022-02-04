function lag = compare_TDS_signal(vt, wf,tsr)
%COMPARE_SIGNAL 


% Getting lags from TDS data
[r1,lags1] = xcorr(vt,wf);
[~, lagindx1] = max(r1);
slag1 = lags1(lagindx1);
lag = slag1/tsr;
return


end

