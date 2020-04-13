clf;
nsat = 30;
for i = 1:nsat
    subplot(5,6,i)
    plot((0:288:86399)/3600, udrei(i,:)-1,'-o')
    title(['PRN ' int2str(satdata(i,1))])
    xlabel('Time (hours)')
    ylabel('UDREI')
    axis([0 24 4 15])
    xticks(0:6:24)
    grid on
end