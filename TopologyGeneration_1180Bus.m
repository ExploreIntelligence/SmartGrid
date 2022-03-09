clear all; close all; clc;
% According to the Topology Configuration part in Section IV of the paper, a commonly used simplification 
% to study the communication network feature is to regard the communication network topology and power grid 
% topology as the same. 
% If two buses are connected with a transformer but not a transmission link, in this work, we assume that 
% the two buses are very close to each other, and the distance is set as 0.5km.
%% load data from xlsx file
N = 118;                                                                   % change the size for the used IEEE bus file
Line_DATA = xlsread(['IEEE',num2str(N),'.xlsx']);                          % read IEEE bus files                                                                   
Src_Vertex = Line_DATA(:,4);                                               % source nodes of the links
Dst_Vertex = Line_DATA(:,14);                                              % destination nodes of the links
X_perkm = 0.5;                                                             % in the 220kv level tranmission line, x_ohm_per_km is set as 0.5ohm
X_Total = Line_DATA(:,16);                                                 % the 'x_ohm_per_km' value in this file is actually the total reactance 
Lenght_Line = X_Total/X_perkm;                                             % length of each line

% add links between the two buses connected with a transformer
switch N
    case 14
        % IEEE 14-bus, 5 links for transformer link in IEEE 14-bus
        Transformers = [4 7; 4 9; 7 8; 7 9; 5 6];                                  
    case 24
        % IEEE 24-bus, 5 links
        Transformers=[3 24; 9 11; 9 12; 10 11; 10 12];  
    case 30
        % IEEE 30-bus, 0 links
        Transformers=[];
    case 39
        % IEEE 39-bus, 12 links
        Transformers=[2 30; 25 37; 29 38; 22 35; 23 36; 19 33; 20 34; 19 20; 12 13; 11 12; 10 32; 6 31];  
    case 57
        % IEEE 57-bus, 16 links
        Transformers=[4 18; 20 21; 24 26; 24 25; 15 45; 14 46; 47 49; 13 49; 39 57; 7 29; 32 33; 32 34; 40 56; 11 41; 11 43; 9 55]; 
    case 118
        % IEEE 118-bus, 11 links
        Transformers=[5 8; 17 30; 25 26; 37 38; 69 68; 65 66; 80 81; 59 63; 61 64; 86 87; 68 116];
end

Num_TransLinks = size(Transformers);                                       % number of transformer links
for i=1:Num_TransLinks(1)                                                  
    Src_Vertex = [Src_Vertex;Transformers(i,1)-1];
    Dst_Vertex = [Dst_Vertex;Transformers(i,2)-1];
    Lenght_Line = [Lenght_Line;0.5];
end
%% Generate the graph matrix
L = size(Src_Vertex);                                                      % number of total links
G = zeros(N,N);
for i=1:L
    G(Src_Vertex(i)+1,Dst_Vertex(i)+1) = Lenght_Line(i);                   % undirect graph
    G(Dst_Vertex(i)+1,Src_Vertex(i)+1) = Lenght_Line(i);
end
for i=1:N
    for j=1:N
        if G(i,j)==0  
            G(i,j) = inf;                                                  % if there is no link between i and j
        end
    end
    G(i,i)=0;
end
%% Combine several topologies together by adding connecting links
duplicateNum = 10;                                                         % number of connected networks, can be changed manually
G_large = zeros(N*duplicateNum,N*duplicateNum);
for i=1:N*duplicateNum
    for j=1:N*duplicateNum
        G_large(i,j) = inf;                                               
    end
end
for i=0:1:duplicateNum-1
    G_large(1+N*i:N+N*i,1+N*i:N+N*i) = G;
end
% generate links connecting nodes in different topologies with random weight of [10,100] km
numLinkperTopo = 10;                                                       % average number of out links for every duplicated topology
numLinks = numLinkperTopo*duplicateNum;
linkWeights = randi([10 100],1,numLinks);
linkIdx = 0;
while linkIdx<=numLinks
    src_node = randi([1 N*duplicateNum]);
    flag = 1;
    while flag
        dst_node = randi([1 N*duplicateNum]);
        if floor(dst_node/N)==floor(src_node/N)                            % guarantee connecting nodes from different 118-buses
        else
            G_large(src_node,dst_node) = linkWeights(i);
            G_large(dst_node,src_node) = linkWeights(i);
            linkIdx = linkIdx + 1;
            flag = 0;
        end
    end
end
save('Matrix_1180Bus.mat','G_large');                                      % Save the topology matrix data
