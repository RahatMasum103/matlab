% Power System State Estimation using Weighted Least Square Method..

fid = fopen('Z_And_Shift_Factors.txt', 'a+');

buses = 118;
lines = 186;
% Reference bus is Bus 7 in the case of 7 bus (9 lines) system.
% Reference bus is Bus 1 in the case of 14 bus (20 lines) system.

linedata = linedatas(buses);
lineStarts = linedata(:,1);
lineEnds = linedata(:,2);
lineReactances = linedata(:,4);

%lineStarts = [1, 1, 2, 3, 4, 4, 5, 6, 2]';
%lineEnds = [2, 3, 3, 4, 5, 6, 6, 7, 7]';
%lineReactances = [0.002, 0.002, 0.002, 0.00125, 0.002, 0.002, 0.002, 0.01, 0.01]';

% Line Matrix
B = zeros(buses, buses);

C = zeros(buses, buses);
for i = 1:lines
    s = lineStarts(i);
    e = lineEnds(i);
    C(s,e) = i;
    C(e,s) = i;
end

for i = 1:buses
    for j = 1:buses
        if (i == j)
            continue;
        elseif (C(i,j) > 0)
            B(i,j) = -1/lineReactances(C(i,j));
        end
    end
end

for i = 1:buses
    sum = 0;
    for j = 1:buses
        if (C(i,j) > 0)
            sum = sum + 1/lineReactances(C(i,j));
        end
    end
    B(i,i) = sum;
end

% Delete the first column and the first row
B = B(:, 2:end);
B = B(2:end, :);

% Delete the last column and the last row
%B = B(:, 1:(end - 1));
%B = B(1:(end - 1), :);

disp('B:');
disp(B);

disp('Z:');
Z = inv(B);
disp(Z);

fprintf(fid, 'Z(%d,%d):\n', buses, lines);
[R, C] = size(Z);
for i = 1:R
    for j = 1:C
        fprintf(fid, '%15.7f', Z(i, j));
    end
    fprintf(fid, ';\n');
end


D = zeros(lines, lines);
for i = 1:lines
    D(i,i) = 1/lineReactances(i);       
end

A = zeros(lines, buses);
for i = 1:lines
    s = lineStarts(i);
    e = lineEnds(i);
    A(i,s) = 1;
    A(i,e) = -1;
end

H = D*A;

% Delete the first column
H = H(:, 2:end);

% Delete the last column
%H = H(:, 1:(end - 1));

disp('H:');
disp(H);


%S = H * B;
%S = H / B;
S = H * Z;

disp('S:');
disp(S);

%fid = fopen('Shift_Factors.txt', 'a+');

fprintf(fid, 'S(%d,%d):\n', buses, lines);
[Row, Col] = size(S);
for i = 1:Row
    for j = 1:Col
        fprintf(fid, '%15.6f', S(i, j));
    end
    fprintf(fid, ';\n');
end

fclose(fid);
