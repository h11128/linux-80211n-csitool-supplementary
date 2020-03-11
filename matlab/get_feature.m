


gesture_number = 2;
instance_per_gesture = 10;
total_instance = gesture_number*instance_per_gesture;
value_per_feature = 90;
feature_number = 8;
total_feature = feature_number * value_per_feature;
features = zeros(total_instance, total_feature);
labels = zeros(total_instance, 1);
%mean std var min max median rms rssq
for gesture_index = 0:gesture_number-1
    labels(instance_per_gesture*(gesture_index) + 1: instance_per_gesture*(gesture_index+1), :) = gesture_index;
    for instance = 1:10
        filename = ['cut_data/jason_' num2str(gesture_index) '_' num2str(instance) '.mat'];
        X = load(filename);
        X = X.X;
        X(isinf(X)|isnan(X)) = -92;
        features(instance_per_gesture*(gesture_index) + instance, value_per_feature*0 + 1:value_per_feature) = mean(X);
        features(instance_per_gesture*(gesture_index) + instance, value_per_feature*1 + 1:value_per_feature*2) = std(X);
        features(instance_per_gesture*(gesture_index) + instance, value_per_feature*2 + 1:value_per_feature*3) = var(X);
        features(instance_per_gesture*(gesture_index) + instance, value_per_feature*3 + 1:value_per_feature*4) = min(X);
        features(instance_per_gesture*(gesture_index) + instance, value_per_feature*4 + 1:value_per_feature*5) = max(X);
        features(instance_per_gesture*(gesture_index) + instance, value_per_feature*5 + 1:value_per_feature*6) = median(X);
        features(instance_per_gesture*(gesture_index) + instance, value_per_feature*6 + 1:value_per_feature*7) = rms(X);
        features(instance_per_gesture*(gesture_index) + instance, value_per_feature*7 + 1:value_per_feature*8) = rssq(X);

    end
end

rand_index = randperm(total_instance);
features = features( ~any( isnan( features ) | isinf( features ), 2 ),: );
labels = labels( ~any( isnan( features ) | isinf( features ), 2 ),: );
features = features(rand_index, :);
labels = labels(rand_index, :);
split_ratio = 0.9;
train_features = features(1:split_ratio*total_instance, :);
train_labels = labels(1:split_ratio*total_instance, :);
test_features = features(split_ratio*total_instance +1 : total_instance, :);
test_labels = labels(split_ratio*total_instance + 1 : total_instance, :);

save(['test_features.mat'],'test_features');
save(['test_labels.mat'],'test_labels');
save(['train_features.mat'],'train_features');
save(['train_labels.mat'],'train_labels');

