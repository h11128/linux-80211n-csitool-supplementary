function server_data()
    t = tcpip('0.0.0.0', 30000, 'NetworkRole', 'server');
    t.InputBufferSize = 2146304;
    index = -1;                     % The index of the plots which need shadowing
    count = 0;                       % Packet count
    buffer_count = 0;
    fopen(t);
    window_size = 1500;
    shift = 250;
    value_per_feature = 90;
    buffer_matrix = zeros(window_size ,value_per_feature);
    feature_number = 8;
    total_feature = feature_number * value_per_feature;
    features = zeros(1, total_feature);
    random_label = zeros(1, 1);
    load(['model.mat']);
    buffer_matrix = zeros(window_size ,value_per_feature);
    t1=0;
    m1=zeros(30,1);
    p = myplot(buffer_matrix(:, 1:90), 'Packet Count', 'SNR [dB]', ['The signal of first 3 subcarrier '], [0,35]);
    while 1
        data = fread(t, t.BytesAvailable, 'double');
        plot(data); 
        buffer_count = buffer_count + 1;
    end
end




