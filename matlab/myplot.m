function p = myplot(matrix, x_label, y_label, title_string, ylimit, islegend )
    p = plot(matrix); 
    xlabel(x_label);
    ylabel(y_label);


    if nargin >3
        title(title_string);
    end
    if nargin > 4    
        ylim(ylimit);
    end
    if nargin>5
        if islegend == 1
            legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C', 'Location', 'SouthEast' );
        end
    end
            
end