%% etract features for each images on imgnet (mars)
clear all;

startup_faster

netname = 'resnet50';

use_gpu  = true;


% track_train = importdata('mars/MARS-evaluation-master/info/tracks_train_info.mat');
% track_test = importdata('mars/MARS-evaluation-master/info/tracks_test_info.mat');
% 

opts.net_def_file = ['market/model/full_test_resnet_50.prototxt'];
% %读取存储网络权值的文件
%opts.net_file =  'prw/VGG16_iter_60000.caffemodel';
 opts.net_file =  ['market/model/resnet_50_7500.caffemodel'];

    %载入网络,设置为cpu模式
    if strcmp(netname, 'CaffeNet')
    im_size = 227;
    else
        im_size = 224;
    end
    
    rcnn_model = rcnn_create_model(opts.net_def_file, opts.net_file,[], im_size);
    rcnn_model = rcnn_load_model_faster(rcnn_model,use_gpu);  %第二个参数为0意味着CPU模式，1则是GPU模式
    
    rcnn_model.detectors.crop_padding = 0;
    

% if rcnn_model.cnn.init_key ~= caffe('get_init_key')
%     error('You probably need to call rcnn_load_model');
% end

if strcmp(netname, 'CaffeNet')
    rcnn_model.cnn.input_size = 227;
end

rcnn_model.cnn.batch_size = 1;


ef_path = {'market/dataset/bounding_box_train/', 'market/dataset/bounding_box_test/', 'market/dataset/query/'};
ef_name = {'train', 'test', 'query'};

%% ef train feature

for i = 1:3
    
    cam_path = ef_path{i};
    
    img_file = dir([cam_path '*.jpg']);
    
    feat = single(zeros(2048, length(img_file)));
    
    
    for n = 1:length(img_file)
        
        if mod(n, 1000) ==0
            fprintf('train: %d/%d\n',n, length(img_file))                        
        end
        
        img_name = [cam_path  img_file(n).name];
        
        im = imread(img_name);
        boxes = [1,1, size(im,2), size(im, 1)];
        feat_img = rcnn_features_resnet(im, boxes, rcnn_model);
        
        feat(:, n) = single(feat_img);
    end

    save(['market/feat/ide_' ef_name{i} '_' netname '.mat'], 'feat');
    feat = [];
    
end



