function result_matrix = read_data(gesture_index, filename, packet_number)

filename = ['../injection/data/jason_' num2str(gesture_index) '.dat'];
begin_number = 0;
ret_struct = read_bf_file(filename);
if nargin < 2
    packet_number = size(ret_struct,1);
end

csi_sample1 = get_scaled_csi(ret_struct{1,1});
scale_csi1 = db(abs(squeeze(csi_sample1).'));


figure(1)
p = plot(scale_csi1);
legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C', 'Location', 'SouthEast' );
xlabel('Subcarrier index');
ylabel('SNR [dB]');
ylim([0 30]);


csi_matrix = zeros(packet_number,30,3);
sub_matrix = cell(30);
row_matrix = zeros(packet_number,90);
a_matrix = zeros(packet_number*30, 5);
index_array = 1:1:packet_number;
%X subcarrier index  Z packet index  Y1 CSI value of first antenna Y2 Y3
for sub =1:30
    sub_matrix{sub} = zeros(packet_number, 3);
end
sub_1 = zeros(packet_number - begin_number, 3);
index_in_a_matrix = 1;
for index=1:packet_number
    csi_sample = get_scaled_csi(ret_struct{index,1});
    scale_csi = db(abs(squeeze(csi_sample).'));
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
    %set(p(1), 'YData', scale_csi(:,1), 'linestyle', '-');
    %set(p(2), 'YData', scale_csi(:,2), 'linestyle', '-');
    %set(p(3), 'YData', scale_csi(:,3), 'linestyle', '-');
    %title(ret_struct{index,1}.bfee_count);
    
    %pause(0.01);
    csi_matrix(index,:,:) = scale_csi;
    %drawnow;
    
end

figure(2)

for sub = 1:30
    subplot(5,6,sub);
    plot(sub_matrix{sub}); 
    %X = sub_matrix{sub}(:,1);
    %findpeaks(X.', index_array);
    xlabel('Packet Count');
    ylabel('SNR [dB]');
    title(['subcarrier ' num2str(sub)] );
end

%{
%figure(3)
%plot3(a_matrix(:,1), a_matrix(:,2), a_matrix(:,3));
for i = 1:10
    X = row_matrix(2500 + (i-1) *3000 : 2500 + i * 3000, :);
    save(['cut_data/jason_' num2str(gesture_index) '_' num2str(i) '.mat'],'X')
end
%}
result_matrix = csi_matrix;
end