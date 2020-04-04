%RECO_BF_SOCKET Reads in a file of beamforming feedback logs and output the
%gesture in real-time
%   This version uses the *C* version of read_bfee, compiled with
%   MATLAB's MEX utility.
%
% (c) 2008-2011 Daniel Halperin <dhalperi@cs.washington.edu>
%
%   Modified by Renjie Zhang, Bingxian Lu.
%   Email: bingxian.lu@gmail.com
%
%
%   Modified by Jason Yao
%   Email: h11129@gmail.com

function reco_bf_socket()

while 1
%% Build a TCP Server and wait for connection
    port = 8090;
    t = tcpip('127.0.0.1', port, 'NetworkRole', 'server');
    t.InputBufferSize = 2146304;
    t.Timeout = 60;
    fprintf('Waiting for connection on port %d\n',port);
    fopen(t);
    fprintf('Accept connection from %s\n',t.RemoteHost);

%% Set plot parameters
    clf;
    axis([1,30,-10,30]);
    t1=0;
    m1=zeros(30,1);

%%  Starting in R2014b, the EraseMode property has been removed from all graphics objects. 
%%  https://mathworks.com/help/matlab/graphics_transition/how-do-i-replace-the-erasemode-property.html
    [~, DATESTR] = version();
    %% plot 1 about snr-subcarrier index
    %subplot(2,1,1)
    if datenum(DATESTR) > datenum('February 11, 2014')
        disp('mode 1.');
        %% mode 1 is used
        p = plot(t1,m1,'MarkerSize',5);
    else
        p = plot(t1,m1,'EraseMode','Xor','MarkerSize',5);
    end

    xlabel('Subcarrier index');
    ylabel('SNR (dB)');
    axis([1,30,-10,40]);
    box off;
    %{
    subplot(2,1,2)
    t2 = [0];
    m2 = [0];
    m2_2 = [0];
    m2_3 = [0];
    x2 = 0;
    p1 = plot(t2,m2,t2, m2_2, t2,m2_3, 'MarkerSize',5);
    xlabel('Time (us)');
    ylabel('Rssi (dB)');
    axis([x2,x2+200000,20,50]);
    box off;
   %}
    initial_time = 0;
    
%% Initialize variables
    csi_entry = [];
    index = -1;                     % The index of the plots which need shadowing
    count = 0;                       % Packet count
    buffer_count = 0;
    broken_perm = 0;                % Flag marking whether we've encountered a broken CSI yet
    triangle = [1 3 6];             % What perm should sum to for 1,2,3 antennas
    gestures  = [
		"swipe left"
		"swipe right"
		"swipe down"
		"swipe up"
		"push"
		"pull"
		"circle left"
		"circle right"
		"double tap"
	];
    window_size = 1500;
    shift = 250;
    value_per_feature = 90;
    buffer_matrix = zeros(window_size ,value_per_feature);
    feature_number = 8;
    total_feature = feature_number * value_per_feature;
    features = zeros(1, total_feature);
    random_label = zeros(1, 1);
    load("model.mat");
    buffer_matrix = zeros(window_size ,value_per_feature));
    
%% Get CSI entry From Socket
    % Need 3 bytes -- 2 byte size field and 1 byte code
    while 1
        % Read size and code from the received packets
        
        s = warning('error', 'instrument:fread:unsuccessfulRead');
        try
            field_len = fread(t, 1, 'uint16');
        catch
            warning(s);
            disp('Timeout, please restart the client and connect again.');
            break;
        end

        code = fread(t,1);    
        % If unhandled code, skip (seek over) the record and continue
        if (code == 187) % get beamforming or phy data
            bytes = fread(t, field_len-1, 'uint8');
            bytes = uint8(bytes);
            if (length(bytes) ~= field_len-1)
                fclose(t);
                return;
            end
        else if field_len <= t.InputBufferSize  % skip all other info
            fread(t, field_len-1, 'uint8');
            continue;
            else
                continue;
            end
        end

        if (code == 187) % (tips: 187 = hex2dec('bb')) Beamforming matrix -- output a record
            csi_entry = read_bfee(bytes);
            display(csi_entry);
            perm = csi_entry.perm;
            Nrx = csi_entry.Nrx;
            if Nrx > 1 % No permuting needed for only 1 antenna
                if sum(perm) ~= triangle(Nrx) % matrix does not contain default values
                    if broken_perm == 0
                        broken_perm = 1;
                        fprintf('WARN ONCE: Found CSI (%s) with Nrx=%d and invalid perm=[%s]\n', filename, Nrx, int2str(perm));
                    end
                else
                    csi_entry.csi(:,perm(1:Nrx),:) = csi_entry.csi(:,1:Nrx,:);
                end
            end
        end
    
        index = mod(index+1, 10);
         
%% Process CSI       
        csi = get_scaled_csi(csi_entry);%CSI data
        scale_csi = db(abs(squeeze(csi_sample).'));
        count = count + 1;
        buffer_count = buffer_count + 1;
        buffer_matrix(buffer_count, :) = scale_csi(:);
        if buffer_count == window_size
            features = get_feature(features, buffer_matrix, 1);
            [labels, ~, ~] = svmpredict(random_label, features, model);
            fprintf('The predict gesture is %d, window %d to %d \n', labels, count - window_size, count);   
            buffer_matrix(1:window_size - shift, :) = buffer_matrix(shift+1: window_size, :);
            buffer_count = buffer_count - shift;
        end
        
        %{
        if initial_time == 0
            initial_time = csi_entry.timestamp_low;
        end
        current_time = csi_entry.timestamp_low - initial_time;
        %disp(packet_count);
        %disp(csi_entry.rssi_a);
        %rssi = [csi_entry.rssi_a, csi_entry.rssi_b, csi_entry.rssi_c];
        %}
	%You can use the CSI data here.

	%This plot will show graphics about recent 10 csi packets
        set(p(index*3 + 1),'XData', (1:30), 'YData', db(abs(squeeze(csi(1,1,:)).')), 'color', 'b', 'linestyle', '-');
        if Nrx > 1
            set(p(index*3 + 2),'XData', (1:30), 'YData', db(abs(squeeze(csi(1,2,:)).')), 'color', 'g', 'linestyle', '-');
        end
        if Nrx > 2
            set(p(index*3 + 3),'XData', (1:30), 'YData', db(abs(squeeze(csi(1,3,:)).')), 'color', 'r', 'linestyle', '-');
        end

        drawnow;
        
        pause(sampling_rate/10000000);
        csi_entry = [];
    end
%% Close file
    fclose(t);
    delete(t);
end

end
