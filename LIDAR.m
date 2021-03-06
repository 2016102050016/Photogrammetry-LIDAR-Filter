%% Programa de Classifica��o de Dados LiDAR
%Realizado por Rui Jorge Abrunhosa Nunes n�32092
%Produ��o Cartogr�fica 2011/2012
%MESTRADO EM ENGENHARIA GEOGR�FICA
%--------------------------------------------------------------------------
clc;
close all;
format long g;

%% Abertura de Ficheiros---------------------------------------------------
NaoTerreno = fopen('NaoTerreno.txt', 'w');
Terreno = fopen('Terreno.txt', 'w');
Outliers = fopen('Outliers.txt','w');

%% Leitura dos dados do ficheiro-------------------------------------------
%Leitura das cotas
DELIMITER = ' ';
HEADERLINES = 6;
newData1 = importdata('LIDARasc118.txt', DELIMITER, HEADERLINES);
vars = fieldnames(newData1);
for i = 1:length(vars)
    assignin('base', vars{i}, newData1.(vars{i}));
end

%Cria��o do vector com os dados LiDAR
cotas_lidar = data;

%Leitura das coordenadas dos cantos
DELIMITER = ' ';
HEADERLINES = 0;

newData2 = importdata('LIDARasc118.txt', DELIMITER, HEADERLINES);

vars = fieldnames(newData2);
for i = 1:length(vars)
    assignin('base', vars{i}, newData2.(vars{i}));
end

%Cria��o de vari�veis com informa��o do cabe�alho
linhas = data(1,1);
colunas = data(1,1);
X_Canto = data(3,1);
Y_Canto = data(4,1);

%Preenchimento de Matrizes
X = zeros(linhas:colunas);
Y = zeros(linhas:colunas);

k = X_Canto-linhas;
l = Y_Canto-colunas;

for i=1:linhas
    for j=1:colunas
        X(i,j) = k;
        Y(i,j) = l;
        l = l+1;
    end
    k = k-1;
    l = Y_Canto-colunas;
end

%% Visualiza��o dos dados -------------------------------------------------
%Imagem
figure
SUBPLOT(1,2,1)
imagesc(cotas_lidar)
Title('Topo')
SUBPLOT(1,2,2)
mesh(cotas_lidar)
Title('Prespectiva')

%% Classifica��o dos Dados ------------------------------------------------
%Obten��o dos edificios
Media = mean(cotas_lidar(:));
class = zeros(linhas:colunas);
for i=1:linhas
    for j = 1:colunas
        if(cotas_lidar(i,j) < Media)
            classificacao(i,j)=50;
        else
            classificacao(i,j)=100;
        end
    end
end
figure
imagesc(classificacao)
Title('Resultado da classifica��o')

%Elimina��o de outliers
Media2 = mean(cotas_lidar(:));
for i=1:linhas
    for j=1:colunas
        if (classificacao(i,j) == 50 && cotas_lidar(i,j) < Media2*0.5)
            classificacao(i,j) = 0 ;
        end
    end
end


%% Exporta��o dos dados ---------------------------------------------------
Z = cotas_lidar;

for i=1:linhas
    for j=1:colunas
        if classificacao(i,j) == 100
           fprintf(NaoTerreno, 'X= %-10.3f Y= %-10.3f Z= %-10.2f\n', X(i,j),Y(i,j),Z(i,j));
        else if classificacao(i,j) == 0
               fprintf(Outliers, 'X= %-10.3f Y= %-10.3f Z= %-10.2f\n', X(i,j),Y(i,j),Z(i,j)); 
                else if classificacao(i,j) == 50
                fprintf(Terreno, 'X= %-10.3f Y= %-10.3f Z= %-10.2f\n', X(i,j),Y(i,j),Z(i,j));
                end
            end
        end
    end
end


%% Fecho de ficheiros -----------------------------------------------------
fclose(NaoTerreno);
fclose(Terreno);
fclose(Outliers);



