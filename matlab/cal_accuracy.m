
%function cal_accuracy()
[train_features, train_labels, test_features, test_labels] = train_test_split(0.7); 
%libsvmwrite('C:\Users\16145\project\locallization_group\code\libsvm\data\test_data.txt', sparse(test_labels), sparse(test_features));
%libsvmwrite('C:\Users\16145\project\locallization_group\code\libsvm\data\train_data.txt', sparse(train_labels), sparse(train_features));
%pyversion('C:\ProgramData\Anaconda3\pkgs\python-3.7.4-h5263a28_0\pythonw.exe');
%parameters = python('C:\Users\16145\project\locallization_group\code\libsvm\tools\easy.py', '../data/train_data.txt', '../data/test_data.txt');
%python easy.py ../data/train_data.txt ../data/test_data.txt

model = svmtrain(train_labels, train_features);
save(['model.mat'],'model');
[predicted_labels_test, accuracy_test, prob_estimates1] = svmpredict(test_labels, test_features, model);
[predicted_labels_train, accuracy_train, prob_estimates2] = svmpredict(train_labels, train_features, model);

per_sample_accuracy_test = accuracy_test(1)/100;
per_sample_accuracy_train = accuracy_train(1)/100;
figure(1);
per_class_accuracy_test = ppp(test_labels, predicted_labels_test);
figure(2);
per_class_accuracy_train = ppp(train_labels, predicted_labels_train);
figure(3);
plot([1: 9], per_class_accuracy_train(:,3), [1: 9], per_class_accuracy_test(:,3));
p(1).LineWidth = 35;
p(2).LineWidth = 35;
p(1).Marker = '.';
p(2).Marker = '.';
p(1).MarkerSize = 35;
p(2).MarkerSize = 35;
legend('train', 'test', 'Location', 'SouthEast');
xlabel('Gesture class');
ylabel('Accuracy');
ylim([0,1.1]);

function per_class_accuracy = ppp(true_labels, predicted_labels)
number_of_labels = max(true_labels)+1;
number_of_instances = size(true_labels);
number_of_instances = number_of_instances(1);
per_class_accuracy = zeros(number_of_labels, 3);
target_matrix = zeros(number_of_labels, number_of_instances);
output_matrix = zeros(number_of_labels, number_of_instances);


for index = 1: number_of_instances
    target_matrix(true_labels(index, 1)+1, index) = 1;
    output_matrix(predicted_labels(index, 1)+1, index) = 1;
    per_class_accuracy(true_labels(index, 1)+1, 1) = per_class_accuracy(true_labels(index, 1)+1, 1) + 1;
    if true_labels(index, 1) == predicted_labels(index, 1)
        per_class_accuracy(predicted_labels(index, 1)+1, 2) = per_class_accuracy(predicted_labels(index, 1)+1, 2) + 1;
    end
end

for labels = 1: number_of_labels
    per_class_accuracy(labels, 3) = per_class_accuracy(labels, 2) / per_class_accuracy(labels, 1);
end

plotconfusion(target_matrix, output_matrix);

end
%Best c=2.0, g=0.001953125 CV rate=98.1481 for split ratio 0.6
%end


