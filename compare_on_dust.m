fileID = fopen('solo_dust.txt','r');
txt = split(string(fscanf(fileID,'%s')),'`');

for i = txt'
    disp(i)
    temp = split(i,'_');
    date = str2num(replace(temp(1),'-',',')'); %#ok<ST2NM>
    indexes = str2num(temp(2)); %#ok<ST2NM>
    
    tds = cdf_from_server(date(1),date(2),date(3),'tswf');
    lfr = cdf_from_server(date(1),date(2),date(3),'lfr-e');
    lfrtimes = spdfdatenumtott2000(lfr.Epoch.data);
    for j = indexes
        tt0 = double(spdfdatenumtott2000(tds.Epoch.data(j)));
        tsr = tds.SAMPLING_RATE.data(j);
        dt = 1e9*(double(tds.SAMPS_PER_CH.data(j))/tsr);
        tt1 = tt0+dt;
        [d, index] = min(abs(lfrtimes-tt0));
        if lfrtimes(index) > tt0 
            index = index-1;
        end
        if index~=0
            sr = lfr.SAMPLING_RATE.data(index);
            dt = 1e9*(double(2048)/sr);
            if (lfrtimes(index)+double(dt))<tt0  
                index = 0;
            else
                lag = compare_signal(lfr,tds,j,index,tt0, 1, 1);
            end
        end
    end
    
end
