

function [train_features, train_labels, test_features, test_labels] = train_test_split(split_ratio) 
dir = 'cut_data/jason_';
gesture_number = 10;
instance_per_gesture = 30;
total_instance = gesture_number*instance_per_gesture;
value_per_feature = 90;
feature_number = 8;
total_feature = feature_number * value_per_feature;
features = zeros(total_instance, total_feature);
labels = zeros(total_instance, 1);
random_split =1;
%mean std var min max median rms rssq

train_ratio = split_ratio;
train_size = round(total_instance*train_ratio);
test_size = total_instance - train_size;
instance_per_gesture_test = test_size/gesture_number;
instance_per_gesture_train = train_size/gesture_number;

train_features = zeros(train_size, total_feature);
train_labels = zeros(train_size, 1);
test_features = zeros(test_size, total_feature);
test_labels = zeros(test_size, 1);
train_index = ones(train_size, 1);
test_index = ones(test_size, 1);

for gesture_index = 0:gesture_number-1
    labels(instance_per_gesture*(gesture_index) + 1: instance_per_gesture*(gesture_index+1), :) = gesture_index;
    for instance = 1:instance_per_gesture
        filename = [dir num2str(gesture_index) '_' num2str(instance) '.mat'];
        X = load(filename);
        X = X.X;
        features = get_feature(features, X, instance_per_gesture*(gesture_index) + instance);

    end
    % 1-6 7-12 to 1-6 11-16 21-26
    % 1-4 5-8 to 7-10 17-2
    instances_of_this_gesture = [instance_per_gesture*(gesture_index) + 1: instance_per_gesture*(gesture_index + 1)];
    a = instances_of_this_gesture(randperm(instance_per_gesture));
    b = a(1: instance_per_gesture_train);
    c = a(instance_per_gesture_train + 1: instance_per_gesture);
    train_index(instance_per_gesture_train*(gesture_index) + 1: instance_per_gesture_train*(gesture_index+1),1) = b;
    test_index(instance_per_gesture_test*(gesture_index) + 1: instance_per_gesture_test*(gesture_index+1),1) = c;
end

%rand_index = randperm(total_instance);
%features = features( ~any( isnan( features ) | isinf( features ), 2 ),: );
%labels = labels( ~any( isnan( features ) | isinf( features ), 2 ),: );
if random_split == 1
    train_features = features(train_index, :);
    train_labels = labels(train_index, :);
    test_features = features(test_index, :);
    test_labels = labels(test_index, :);
else
    train_features = features(1:train_size, :);
    train_labels = labels(1:train_size, :);
    test_features = features(train_size+1:total_instance, :);
    test_labels = labels(train_size+1:total_instance, :);
end

save(['test_features.mat'],'test_features');
save(['test_labels.mat'],'test_labels');
save(['train_features.mat'],'train_features');
save(['train_labels.mat'],'train_labels');


end



