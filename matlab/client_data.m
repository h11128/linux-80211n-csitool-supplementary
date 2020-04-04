function client_data()


    t = tcpip('localhost', 30000, 'NetworkRole', 'client');
    filename = ['../injection/data/jason_4.dat'];
    
    ret_struct = read_bf_file(filename);
    packet_number = size(ret_struct,1);
    fopen(t);
    for index=1:packet_number
        csi_sample = get_scaled_csi(ret_struct{index,1});
        scale_csi = db(abs(squeeze(csi_sample).'));
        scale_csi(isinf(scale_csi)|isnan(scale_csi)) = -92;
        data = scale_csi(:);
        %plot(data);
        fwrite(t, data);
        
    end
end