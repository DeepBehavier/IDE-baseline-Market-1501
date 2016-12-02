%% etract features for each images on imgnet (mars)
clear all;

addpath('external/caffe-fast-rcnn_2/matlab/');

% load model and creat network

netname = 'CaffeNet';
model =  ['market/model/full_test_caffenet_4096.prototxt'];
weights = ['market/model/caffenet_lloss_4096_iter_10000.caffemodel'];

caffe.set_device(0);
caffe.set_mode_gpu();
net = caffe.Net(model, weights, 'test');

% mean data
if strcmp(netname, 'CaffeNet')
    im_size = 227;
else
    im_size = 224;
end
mean_data = importdata('external/caffe-fast-rcnn_2/matlab/+caffe/imagenet/ilsvrc_2012_mean.mat');
image_mean = mean_data;
off = floor((size(image_mean,1) - im_size)/2)+1;
image_mean = image_mean(off:off+im_size-1, off:off+im_size-1, :);


ef_path = {'market/dataset/bounding_box_train/', 'market/dataset/bounding_box_test/', 'market/dataset/query/'};
ef_name = {'train', 'test', 'query'};

%% ef feature

for i = 1:3
    
    cam_path = ef_path{i};
    
    img_file = dir([cam_path '*.jpg']);
    
    feat = single(zeros(4096, length(img_file)));
    
    
    for n = 1:length(img_file)
        
        if mod(n, 1000) ==0
            fprintf('%s: %d/%d\n',ef_name{i}, n, length(img_file))                        
        end
        
        img_name = [cam_path  img_file(n).name];
        
        im = imread(img_name);
        im = prepare_img( im, image_mean, im_size);
        res = net.forward({im});
        %feat(:, n) = single([res{1}(:); res{2}(:); res{3}(:)]);
        feat_img = net.blobs('fc7').get_data();  
        feat(:, n) = single(feat_img(:));
    end
    
    save(['market/feat/ide_' ef_name{i} '_' netname '_4096_lloss.mat'], 'feat');
    feat = [];
    
end

caffe.reset_all();

