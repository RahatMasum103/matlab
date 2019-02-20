%%%%%%%%%%%%%%%%%%%%%%% Calcualtion of LODF %%%%%%%%%%%%%%%%%%%% %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calcualtion of LODF
% only change this input and in the same directory there should a .txt file
% named, "input_line_data_[bus]_line[].txt

num_of_bus=118;   %num of bus
num_of_line=186;  %num of lines



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% reading linedata from txt file %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_name=strcat('input_line_data_',string(num_of_bus),'_',string(num_of_line));
line_data=load(strcat(file_name,'.txt'));   %line_data contains line info

% initializing other matrixes

Ybus=zeros(num_of_bus);
Impedence=zeros(num_of_bus);
line_direction=zeros(num_of_bus);

%   Generating Impedence matrix from bus_data
%   Impedence = 1/ Admittence

for i=1:size(line_data,1)
    Impedence(line_data(i,2),line_data(i,3))=1/line_data(i,4);
    Impedence(line_data(i,3),line_data(i,2))=1/line_data(i,4);
    
    %     line_direction(line_data(i,2),line_data(i,3))=1;
    %     line_direction(line_data(i,3),line_data(i,2))=-1;
end

% display impedence matrix
%Impedence

%%%%%%%%%%%%%%             Generating Y_bus         %%%%%%%%%%%%%%%
for i=1:size(line_data,1)
    Ybus(line_data(i,2),line_data(i,3))=-line_data(i,4);
    Ybus(line_data(i,3),line_data(i,2))=-line_data(i,4);
end

for i=1:size(Ybus,1)
    Ybus(i,i)=-sum(Ybus(i,:));
end

%%%%%%  Ybus created
% uncomment the next line to see Ybus
%Ybus


% Now calculating sensetivity matrix
Y_eliminated=Ybus(2:end,2:end);
M=inv(Y_eliminated);
X_sen=M;
X_sen=[zeros(1,size(X_sen,2)); X_sen];
X_sen=[zeros(size(X_sen,1),1) X_sen];

%%%%%%%%%%%  finding LODF %%%%%%%%%%%55
LODF=zeros(num_of_line);    % generating line*line matrix with 0s
lodf_row=0;

%%%%%%%% seraching for a line  whcih will be the reference
for i=1:num_of_bus
    for j=i+1:num_of_bus
        if abs(Impedence(i,j))~=0
            lodf_row=lodf_row+1;
            lodf_column=0;
            
            % searching for other lines to calculate lodf for the previous
            % line
            for k=1:num_of_bus
                for l=k+1:num_of_bus
                    if abs(Impedence(k,l))~=0
                        lodf_column=lodf_column+1;
                        if i==k && j==l
                            LODF(lodf_row,lodf_column)=0; % same line
                        else
                            numerator=Impedence(i,j)*(X_sen(i,l)-X_sen...
                                (j,l)-X_sen(i,k)+X_sen(j,k))/Impedence(k,l);
                            denominator=Impedence(i,j)-(X_sen(i,i)+X_sen...
                                (j,j)-2*X_sen(i,j));
                            LODF(lodf_row,lodf_column)=numerator/denominator;
                        end
                    end
                end
            end
            
        end
    end
end

%lodf calculations are over
% display lodf
LODF

%%%%%%  Writing in a .txt file named "input_lodf_[bus]_[line].txt %%%%%%%%%

output_file_name=strcat('input_lodf_',string(num_of_bus),'_',string(num_of_line),'.txt');
fid = fopen(output_file_name,'wt');
for ii = 1:size(LODF,1)
    fprintf(fid,'%.5g ',LODF(ii,:));
    fprintf(fid,'\n');
end
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%  end  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
