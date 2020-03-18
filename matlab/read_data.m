function result_matrix = read_data(gesture_index, filename, packet_number)
    if nargin<1
        gesture_index = 1;
    end
    filename = ['../injection/data/jason_' num2str(gesture_index) '.dat'];
    begin_number = 0;
    ret_struct = read_bf_file(filename);
    if nargin < 2
        packet_number = size(ret_struct,1);
    end
    instance_per_gesture = 10;
    csi_sample1 = get_scaled_csi(ret_struct{1,1});
    scale_csi1 = db(abs(squeeze(csi_sample1).'));


    figure(1)
    myplot(scale_csi1, 'Subcarrier index', 'SNR [dB]', 'First Packet Plot', [0 30], 0);

    csi_matrix = zeros(packet_number,30,3); % all csi_matrix
    sub_matrix = cell(30); % for plot
    row_matrix = zeros(packet_number,90); % for output data
    cut_matrix = zeros(packet_number, 3); % for cut 
    %a_matrix = zeros(packet_number*30, 5);

    %X subcarrier index  Z packet index  Y1 CSI value of first antenna Y2 Y3

    for sub =1:30
        sub_matrix{sub} = zeros(packet_number, 3);
    end
    sub_1 = zeros(packet_number - begin_number, 3);

    index_in_a_matrix = 1;
    for index=1:packet_number
        csi_sample = get_scaled_csi(ret_struct{index,1});
        scale_csi = db(abs(squeeze(csi_sample).'));
        scale_csi(isinf(scale_csi)|isnan(scale_csi)) = -92;
        cut_matrix(index,:) = sum(scale_csi)/30;
        row_matrix(index, :) = scale_csi(:);

        for sub =1:30
            %{
            if rem(index, 1000) == 0
                a_matrix(index_in_a_matrix, 1) = sub;
                a_matrix(index_in_a_matrix, 2) = index;
                a_matrix(index_in_a_matrix, 3) = scale_csi(sub,1);
                a_matrix(index_in_a_matrix, 4) = scale_csi(sub,2);
                a_matrix(index_in_a_matrix, 5) = scale_csi(sub,3);
            end
    %}
            sub_matrix{sub}(index,:) = scale_csi(sub,:);
            sub_1(index,:) = scale_csi(1,:);
            index_in_a_matrix = index_in_a_matrix + 1;
        end
        %{
        set(p(1), 'YData', scale_csi(:,1), 'linestyle', '-');
        set(p(2), 'YData', scale_csi(:,2), 'linestyle', '-');
        set(p(3), 'YData', scale_csi(:,3), 'linestyle', '-');
        title(ret_struct{index,1}.bfee_count);

        pause(0.01);
        drawnow;
        %}
        csi_matrix(index,:,:) = scale_csi;
    end
    %{
    figure(2)

    for sub = 1:30
        subplot(5,6,sub);
        myplot(sub_matrix{sub}, 'Packet Count', 'SNR [dB]', ['subcarrier ' num2str(sub)]);
    end


    
    % 3d plot
    %figure(3)
    %plot3(a_matrix(:,1), a_matrix(:,2), a_matrix(:,3));
    

    figure(3)
    myplot(cut_matrix, 'Packet Count', 'SNR [dB]', ['Sum Amplitude of 30 Subcarrier '], [0,30]);
    
    figure(4)
    cut_matrix = filter_after_sum(cut_matrix);
    myplot(cut_matrix, 'Packet Count', 'SNR [dB]', ['Sum Amplitude of Gesture ' num2str(gesture_index) ' (filter after sum)'], [0,30], 1);

    figure(5)
    %}
    [row_matrix, cut_matrix] = filter_before_sum(row_matrix, cut_matrix);
    
    
    %myplot(cut_matrix, 'Packet Count', 'SNR [dB]', ['Sum Amplitude of Gesture ' num2str(gesture_index) ' (filter before sum)'], [0,30], 1);

    
    %figure(6)
   %min_index = select_antenna(cut_matrix);
    %findpeaks(-cut_matrix(:,min_index), 'MinPeakDistance',2000);

    %title(['Sum Amplitude of Gesture ' num2str(gesture_index) ' (selected antenna filter after sum) ']);
    
    cutdata1(cut_matrix, row_matrix, gesture_index, 1500, 250, 10);
    
    
end


function cutdata1(cut_matrix, row_matrix, gesture_index, window_size, shift, instance_per_gesture)
    for i = 1:instance_per_gesture
        X = row_matrix(2500 +3000 *(i-1): 2500 + 3000*(i), :);
        save(['cut_data/jason_' num2str(gesture_index+1) '_' num2str(i) '.mat'],'X');
    end
end

function cutdata(cut_matrix, row_matrix, gesture_index, window_size, shift, instance_per_gesture)
% cut data
    
    min_index = select_antenna(cut_matrix);
    [~,locs] = findpeaks(-cut_matrix(:,min_index), 'MinPeakDistance',2000);
    indices = 2000<locs;
    locs = locs(indices);
    indices = locs<34000;
    locs = locs(indices);
    if gesture_index == gesture_index
        locs =[1:10] * 3000 + 1250;
    end    
    sizes = size(row_matrix);
    hw = window_size/2;
    sh = shift;
    A = zeros(instance_per_gesture, window_size + shift*2+1);
    B = zeros(instance_per_gesture + 1, 1000);
    B(1,1:locs(1) - hw - shift) = 1:locs(1) - hw - shift;
    for i = 1:instance_per_gesture
        index = locs(i);
        
        A(i, :) = index - hw - shift : index + hw + shift;
        if i >1 
            last_index = locs(i-1);
            B(i, 1: index - last_index - 2*hw - 2* sh + 1) = last_index + hw + sh : index - hw - sh;
        end
        X = row_matrix(index - hw - sh : index + hw - sh, :);
        save(['cut_data/jason_' num2str(gesture_index+1) '_' num2str(3*i-2) '.mat'],'X');
        X = row_matrix(index - hw : index + hw, :);
        save(['cut_data/jason_' num2str(gesture_index+1) '_' num2str(3*i-1) '.mat'],'X');
        X = row_matrix(index - hw + sh : index + hw + sh, :);
        save(['cut_data/jason_' num2str(gesture_index+1) '_' num2str(3*i) '.mat'],'X');
        fprintf(['save file jason_' num2str(gesture_index+1) '_' num2str(3*i) '.mat \n']);
    end
    
% non_gesture_data_cutting
    B(instance_per_gesture + 1, 1 : sizes(1) + 1 - hw - sh - locs(10)) = locs(10) + hw + sh : sizes(1);
    %aa = row_matrix(A, :);
    C = B~= 0;
    B = B(C);
    bb = row_matrix(B, :);
    k = 0;
    sizes= size(bb);
    index = 1;
    direction = 1;
    while (k < 30)
        rand_index = randperm(window_size);
        next_index = index + window_size*direction;
        if next_index > sizes(1)
            index = sizes(1) - rand_index(k+1);
            direction = -1;
            next_index = index + window_size*direction;
        elseif  next_index < 1
            index = rand_index(k+1);
            direction = 1;
            next_index = index + window_size*direction;
        end
        range = index : next_index;
        if direction == -1
            range = next_index : index;
        end
        index = next_index;
        X = bb(range, :);
        save(['cut_data/jason_' num2str(0) '_' num2str(k+1) '.mat'],'X');
        k = k + 1;
    end
end

function select_index = select_antenna(cut_matrix)
    mean_value = mean(cut_matrix);
    [max_mean, max_mean_index] = max(mean_value);
    middle_index = 1;
    if max_mean_index == 1
        middle_index = 3;
    end

    if max_mean - mean_value(middle_index) < 2 
        var_value = var(cut_matrix);
        [~,select_index ] = min(var_value);
    else
        select_index = max_mean_index;
    end
end


function [row_matrix, cut_matrix] = filter_before_sum(row_matrix, cut_matrix)
    sizes = size(row_matrix);
    for i = 1:sizes(2)
        amplitude = row_matrix(:,i);
        [amplitude_hampel,~] = hampel(amplitude);
        row_matrix(:,i) = wifi_butterworth_function(amplitude_hampel', 0);
    end
    for i = 1:3
        cut_matrix(:,i) = sum(row_matrix(:,(i-1)*30+1:i*30), 2)/30;
    end
end

function out_matrix = filter_after_sum( out_matrix)
    sizes = size(out_matrix);
    for i = 1:sizes(2)
        amplitude = out_matrix(:,i);
        [amplitude_hampel,~] = hampel(amplitude);
        out_matrix(:,i) = wifi_butterworth_function(amplitude_hampel', 0);
    end
end

function myplot(matrix, x_label, y_label, title_string, ylimit, islegend )
    plot(matrix); 
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