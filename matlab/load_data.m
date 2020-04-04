function load_data()
    window_size = 1500;
    shift = 250;
    sampling_rate = 1000;
    
    filename = ['../injection/data/jason_4.dat'];
    model_path = ['model.mat'];
    
    ret_struct = read_bf_file(filename);
    load(model_path);
    packet_number = size(ret_struct,1);
    row_matrix = zeros(packet_number,90); % for output data

    %X subcarrier index  Z packet index  Y1 CSI value of first antenna Y2 Y3

    for index=1:packet_number
        csi_sample = get_scaled_csi(ret_struct{index,1});
        scale_csi = db(abs(squeeze(csi_sample).'));
        scale_csi(isinf(scale_csi)|isnan(scale_csi)) = -92;
        row_matrix(index, :) = scale_csi(:);
    end
    
    sizes = size(row_matrix);
    generate_labels = zeros(1, 1);
    value_per_feature = sizes(2);
    feature_number = 8;
    total_feature = feature_number * value_per_feature;
    features = zeros(1, total_feature);
    
    buffer_matrix = zeros(window_size ,value_per_feature);
    count = 0;
    buffer_count = 0;
    t1=0;
    m1=zeros(30,1);
    
    %p = plot(t1,m1,'MarkerSize',5);
    subcarrier_index = subcarrier_selection(row_matrix);
    p = myplot(buffer_matrix(:, 1:90), 'Packet Count', 'SNR [dB]', ['The signal of first 3 subcarrier '], [0,35]);
    %axis([1,3000,0,35]);
    while (count < packet_number)
        tic;
        buffer_count = buffer_count + 1;
        count = count + 1;
        buffer_matrix(buffer_count, :) = row_matrix(count, :); % read packet
        if buffer_count == window_size
            features = get_feature(features, buffer_matrix, 1);
            [labels, ~, ~] = svmpredict(generate_labels, features, model);
            fprintf('The predict gesture is %d, window %d to %d \n', labels, count - window_size, count);     
            buffer_matrix(1:window_size - shift, :) = buffer_matrix(shift+1: window_size, :);
            buffer_count = buffer_count - shift;    
            %fprintf('time 1  \n');
            f = 1;
        end

        index = mod(index+1, 10);
        %set(p(index*3 + 1),'XData', [1:30], 'YData', row_matrix(count, 1:30), 'color', 'b', 'linestyle', '-');
        %set(p(index*3 + 2),'XData', [1:30], 'YData', row_matrix(count, 31:60), 'color', 'g', 'linestyle', '-');
        %set(p(index*3 + 3),'XData', [1:30], 'YData', row_matrix(count, 61:90), 'color', 'r', 'linestyle', '-');
        
        %drawnow;   
        for i = 1:3
            subcarrier = subcarrier_index(i);
            set(p(subcarrier), 'YData', buffer_matrix(:,subcarrier));
            
            %if count > window_size
                %set(p(1), 'XData', count, 'YData', buffer_matrix(:,1));
                
            %else 
            %    set(p(subcarrier), 'YData', buffer_matrix(:,subcarrier));                
            %end
        end

        drawnow;
        pause(sampling_rate/10000000);
        
        time = toc;
        if buffer_count == window_size - shift
            fprintf('total cost time %d \n', time);
        end
    end

end

function index = subcarrier_selection(matrix)
    index = zeros(3,1);
    mean_value = mean(matrix);
    mean_sort = sort(mean_value);
    a = mean_sort(1, end);
    b = mean_sort(1, ceil(end/2));
    c = mean_sort(1, 1);
    
    aa = find(mean_value == a);
    bb = find(mean_value == b);
    cc = find(mean_value == c);
    
    index(:,1) = [aa, bb, cc];
end