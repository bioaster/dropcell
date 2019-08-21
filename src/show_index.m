function show_index(BOIC, LOIC)
    for k=1:length(BOIC)
        boundary = BOIC{k};
        plot(boundary(:,2), boundary(:,1), 'g','LineWidth',1);
        %randomize text position for better visibility
        rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
        col = boundary(rndRow,2); row = boundary(rndRow,1);
        h = text(col+1, row-1, num2str(LOIC(row,col)));
        set(h,'Color','g','FontSize',10,'FontWeight','normal');
    end
end