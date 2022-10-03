clear all; close all; clc;
% the code to generate the results in TABLE III of the paper
% change N to 14/24/30/39/57/118 manually
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
%% Generate the graph matrix for the topology
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
save(['Matrix_',num2str(N),'Bus.mat'],'G');                                % Save the topology matrix data
%% Find the LFA and rLFA nodes to see if they exist
switch N
    case 14
        % IEEE 14-bus, critical links for PMU-PDC connections
        dst = 11;
        % critical links
        PMU = [6 11; 2 5 ; 5 6 ; 7 4 ; 4 5 ; 9 4];                                 
    case 24
        % IEEE 24-bus, critical links for PMU-PDC connections
        dst = 11;
        % critical links
        PMU = [21 15; 15 24; 24  3; 3   9; 9  11; 23 12; 12  9; ...
               8  9;   2  1; 1  5;  5 10; 10 11; 16 14; 14 11];
    case 30
        dst = 17;
        % critical links
        PMU = [15 12; 12 16; 16 17; 1  2 ; 2  6 ; 6  10; 10 17; ...
               27 28; 28  6; 9 10; 19 20; 20 10; 25 24; 24 22; ...
               22 21; 21 10];
    case 39
        dst = 16;
        % critical links
        PMU = [9   8; 8   7; 7   6; 6  11; 11 12; 12 13; 13 14; ...
               14 15; 15 16; 10 13; 23 22; 22 21; 21 16; 29 28; 28 26; ...
               26 27; 27 17; 17 16; 25  2; 2   3; 3  18; 18 17]; 
    case 57
        dst = 22;
        % critical links
        PMU = [20 21; 21 22; 31 30; 30 25; 25 24; 24 23; 23 22; ...
               32 34; 34 35; 35 36; 36 37; 37 38; 38 22; 57 39; ...
               39 37; 44 38; 48 38; 47 48; 49 47; 13 49; 41 11; ...
               11 13; 46 14; 14 13; 55  9;  9 13;  8  9;  7  8; ...
               29  7; 52 29; 28 29; 10 12; 12 13;  1 15; 15 13; ...
               4  3;  3 15];
    case 118
        dst = 69;
        % critical links
        PMU = [  2  12;  11 12;  12  16; 16 17;  5   8;  8  30;  30  17; ...
               17 113; 113 32;  29  31; 31 32; 114 32;  32 23; 25 23;  20 21;  21  22; ...
               22  23;  23 24;  24 70;  71  70; ...
               70  69;  75 69;  77 69;  80 77;  82 77;  83 82;  85  83; ...
               86  95;  96  82; 94 96;  93 94;  92 93; 91 92; 100 94; 101 100; ...
               103 100;105 103; 110 103; 49 69;  45 49;  50 49; 42 49;  40 42;  39  40; ...
               37  39;  34 37;  51  49; 52 52;  66 49;  65 66; 64 65;  63 64;  59  63];
end
Ncl = length(PMU);
% compute the number of links which fail will generate unavailable LFA/rLFA
LFA_num = 0;     % number of links that do not have a LFA
rLFA_num = 0;    % number of links that do not have a rLFA
for i_index = 1:Ncl
    %one link failure
    p_node = PMU(i_index,1); %src node of the failed link
    q_node = PMU(i_index,2); %dst node of the failed link
    %run the floyd algorithm to find shortest paths between each node pair
    [ Distances,R ] = floydSPR(G);
    %R(i,j): the next node from i to reach j   
    %LFA
    LFA_node = inf;
    for node_idx=1:N
        if G(p_node,node_idx)~=inf && G(p_node,node_idx)~=0 && node_idx~=q_node %adjacent node of p
            %LFA
            if Distances(node_idx,dst)<G(p_node,node_idx)+Distances(p_node,dst)
                LFA_node = node_idx;
                break;
            end
        end
    end
    if LFA_node == inf
        LFA_num = LFA_num + 1;
    end
    %rLFA
    %find Q space
    Q_space = [];
    for node_idx=1:N
        if node_idx~=dst
            if ~isToPnode(node_idx,p_node,dst,R)
                Q_space = [Q_space,node_idx];
            end
        end
    end
    %disp(Q_space);
    %find P space
    P_space = [];
    for node_idx=1:N
        if node_idx~=p_node
            if ~isToPnode(node_idx,q_node,p_node,R)
                P_space = [P_space,node_idx];
            end
        end
    end
    %disp(P_space);
    PQ_idx = ismember(P_space,Q_space);
    if sum(PQ_idx)==0
        rLFA_num = rLFA_num + 1;    % num of unavailable rLFA nodes in total
    end
end
disp(['LFA num: ',num2str(LFA_num)]);
disp(['rLFA num: ',num2str(rLFA_num)]);

%to see if the node is located at the subtree of p_node
function [flag] = isToPnode(start_node,p_node,dst,R)
    flag = 0;
    a = start_node;
    while a~=dst
        if a==p_node
            flag = 1;
            break;
        end
        a = R(a,dst);
    end
end