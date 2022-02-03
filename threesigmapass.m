function pass = threesigmapass(data)
pass = false;    
s = std(data);
    m = mean(data);
    if abs(data-m)<=3*s
        pass = true;
    end
end