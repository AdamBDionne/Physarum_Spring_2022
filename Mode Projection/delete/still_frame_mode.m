%Still frame of excitation on network, like a mode

% Load in mode
mode = readmatrix('Mode projection/results/mode_largest_proj.txt');
mode = -1*mode;

filename = 'sample three';
source = ['Data/' filename '/' filename];
destination = 'Mode projection/results/';

%%% load in data
graph = load([source '_graph.mat']);
graph = graph.graph;

crop = load([source '_crop.txt']);
y_min = crop(1); y_max = crop(2);
x_min = crop(3); x_max = crop(4);

%%% measure radii & animate
numEdges = length(graph);

mode_num = numEdges-1; 

% Mask
mask = imread([source '_mask.png']);
filtered = medfilt2(mask(:,:,1), [20 20]);
filtered_again = imgaussfilt(filtered, 5);
BW = imbinarize(filtered_again,0.1);
mask = uint16(~BW);
mask = double(mask);

mask = mask(y_min:y_max,x_min:x_max);
dims = size(mask);

% Make voronoi cells for coloring
if ~exist('diagram','var') || size(diagram,1) ~= size(mask,1)
    point_list = zeros(numEdges,2);

    for i = 1:numEdges
        edgeData = graph(i).edge_data;
        point_list(i,1) = mean(edgeData(:,1));
        point_list(i,2) = mean(edgeData(:,2));
    end

    diagram = zeros(dims(1), dims(2));

    for i = 1:dims(1)
        for j = 1:dims(2)
            [~,ind] = min((point_list(:,1) - i).^2 + (point_list(:,2) - j).^2);
            diagram(i,j) = ind;
        end
    end
end


% Color Map
colors = getPyPlot_cMap('RdYlBu', 500);
 

diagram_cropped = diagram;




max_amp = max(mode);
min_amp = min(mode);

%translate from julia indexing to matlab indexing 
translator = readmatrix([source, '_translator.txt']);
temp = mode;
for i = 1:numEdges
    mode(abs(translator(i))) = temp(i);
end


%Setup phase colors
map = zeros(numEdges,3);
for j = 1:numEdges
    amp = mode(j);
    color_ind = round( (amp-min_amp)/(max_amp-min_amp) * 499)+1;
    map(j,:) = colors(color_ind,:);
end

fig_lab = figure(1); clf
h = imagesc(diagram_cropped);
alpha_data = logical(mask);
set(h, 'AlphaData', alpha_data)
set(gca,'position',[0 0 1 1],'units','normalized')
set(gca,'XTick',[])
set(gca,'YTick',[])
axis equal
colormap(map);


saveas(gcf,"Mode projection/results/largest_proj_mode.png")
