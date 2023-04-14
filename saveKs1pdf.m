ddd = 'E:\Classification\Generated from VRP-EGG only';
s = ['M', 'F', 'B', 'G'];
for S = 1:4
    for f = 1:14
        h = figure;
        h.Position = [10 10 800 1800];
        for k = 2:6
            if f > 9
                vrp_name = [s(S), char(string(f)), '_', char(string(k))];
            else
                vrp_name = [s(S), '0', char(string(f)), '_', char(string(k))];
            end
            save_filename = vrp_name(1:3);
            if isfield(variable, vrp_name)
                value = getfield(variable,vrp_name);
                mSymbol = FonaDynPlotVRP(value, names, 'maxCluster', ...
                    subplot(3,2,(k-1)), 'ColorBar', 'on','PlotHz', 'off', 'MinCycles', 5); 
                title(save_filename)
                pbaspect([1.5 1 1]);
                xlabel('Hz');
                ylabel('dB');
                grid on
            end
        end
        save_file_dir = [ddd, '\',save_filename, '_k=2-6'];
        set(gcf,'PaperOrientation','portrait');
        set(gcf, 'PaperSize', [30, 40]);
        print(gcf, save_file_dir,'-dpdf','-r600', '-bestfit');
        close gcf;
    end
end