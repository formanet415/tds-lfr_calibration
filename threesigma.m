function [avg, sigma] = threesigma(data)
    if ~threesigmapass(data)
        s = std(data);
        m = mean(data);
        mask = abs(data-m)<3*s;
        [avg, sigma] = threesigma(data(mask));
    else
        avg = mean(data);
        sigma = std(data);
    end
    
end

