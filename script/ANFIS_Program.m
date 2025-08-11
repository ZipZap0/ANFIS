%dataset
error_yaw = [26, 24 ,20, 16, 12, 10, 8, 6, 4, 2, 1,0.5,-1, -2, -4, -6, -8, -10, -12, -16, -20, -24, -26]; %input

control_target = [24, 22, 18, 14, 10, 8, 6, 4, 2, 1, 0.5,0.15,-0.5, -1, -2, -4, -6, -8, -10, -14, -18, -22, -24]

%data
data = [error_yaw', control_target'];

%sugeno
FIS = sugfis;
FIS = addInput(FIS, [-30,30], 'Name', 'Error');

%MEMBERSHIP inputMF 
FIS = addMF(FIS, 'Error', 'trimf', [-30, -15, -5], 'Name', 'Negatif besar');
FIS = addMF(FIS, 'Error', 'trimf', [-15, -5, 0], 'Name', 'Negatif kecil');
FIS = addMF(FIS, 'Error', 'trimf', [-7, 0, 7], 'Name', 'Nol');
FIS = addMF(FIS, 'Error', 'trimf', [0, 5, 15], 'Name', 'Positif kecil');
FIS = addMF(FIS, 'Error', 'trimf', [5, 15, 30], 'Name', 'Positif besar');

%rentang output
FIS = addOutput(FIS, [-30,30], 'Name', 'Control');

%DEFUZZIFIKASI OutputMF 
FIS = addMF(FIS, 'Control', 'constant', 0, 'Name', 'Out1'); 
FIS = addMF(FIS, 'Control', 'constant', 0, 'Name', 'Out2');
FIS = addMF(FIS, 'Control', 'constant', 0, 'Name', 'Out3');
FIS = addMF(FIS, 'Control', 'constant', 0, 'Name', 'Out4');
FIS = addMF(FIS, 'Control', 'constant', 0, 'Name', 'Out5');

%output konstanta tiap aturan
FIS.Outputs(1).MembershipFunction(1).Parameters = -15;
FIS.Outputs(1).MembershipFunction(2).Parameters = -5;
FIS.Outputs(1).MembershipFunction(3).Parameters = 0;
FIS.Outputs(1).MembershipFunction(4).Parameters = 5;
FIS.Outputs(1).MembershipFunction(5).Parameters = 15;

%rule  
rules  = [
    1 1 1 1 %inMF, outMF, bobot, operasi
    2 2 1 1
    3 3 1 1
    4 4 1 1 
    5 5 1 1
    ];
FIS = addRule(FIS, rules);

%MASUK ANFIS PENGATURAN ANFIS
opt = anfisOptions('InitialFIS', FIS, 'EpochNumber', 400, 'DisplayErrorValues', 1);

%train ANFIS
FIS_trained = anfis(data,opt);

%simpan modul
writeFIS(FIS_trained, 'anfis_trained.fis');
disp('model pelatihan disimpan');

set_point = 0; %setpoint
yaw = 20; %posisi awal
yaw_log = yaw;
max_iter = 30;
time_log = 0;

    fprintf('Posisi awal : %d \n', yaw);

for k = 1:max_iter
    error = yaw - set_point;

    %feedback anfis OUTPUT LAYER
    control = evalfis(FIS_trained, error);
    %out teori
    yaw = yaw - control;
    %konversi hasil pos
    hasil_pos_x = 12 * (cos(control) - 1);
    hasil_pos_y = 12 * (sin(control));
    %history
    yaw_log = [yaw_log, yaw];
    time_log = [time_log, k];

    fprintf('\nLoop %2d: error = %5.2f, control = %5.2f, yaw = %5.2f \n', k, error, control, yaw);
    

    fprintf('\n hasil_pos_x  %d || hasil_pos_y %d \n', hasil_pos_x, hasil_pos_y);

    control = max(-3, min(3, control));

    if abs(error) < 0.1 && abs(control) > 0
        fprintf('\n Setpoint di loop : %d \n', k);
        break;
    end;
end;

%evaluasi FIS
test_input = [1.15]; %error

%bandingkan
pred_awal = evalfis(FIS, test_input);
pred_anfis = evalfis(FIS_trained, test_input);

%OutCLI
disp('YAW = Error_yaw (FIS)'); %hanya FIS
for i = 1:length(test_input)
    fprintf('|%3d = %.1f|   \n', test_input(i), pred_awal(i));
end

disp('YAW = Error_yaw (ANFIS)'); %setelah ANFIS
for i = 1:length(test_input)
    fprintf('|%3d = %.1f|   \n', test_input(i), pred_anfis(i));
end

%outGUI
%FIS_trained = readfis('anfis_trained.fis');

%error_range = -30:0.5:30; %resolusi 0,5 derajat

%output kontrol setiap eror
%control_output = evalfis(FIS_trained, error_range);

%figure('Position', [100,100,700,400]);
%plot(error_range, control_output, 'b-', 'LineWidth', 2);
%hold on;

%yline (0, 'k--', 'LineWidth', 1);
%xline (0, 'k--', 'LineWidth', 1);

%patch([-7 7 7 -7], [min(control_output) min(control_output) max(control_output) max(control_output)], ...
 %   [0.9 0.9 0.9], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
%text(0, max(control_output)*0.9, 'Daerah Error Kecil', 'HorizontalAlignment', 'center');

%xlabel('error yaw (derajat)', FontSize=12);
%ylabel('yaw', FontSize=12);
%title('Kurva Kontrol ANFIS: Koreksi terhadap Error Yaw', 'FontSize', 14, 'FontWeight', 'bold');

%grid on;
%hold off;

%fprintf('Plot kurva kontrol ANFIS telah dibuat.\n');
%fprintf('Rentang error: -30 hingga +30 derajat\n');
%fprintf('Output kontrol: dari %.2f hingga %.2f\n', min(control_output), max(control_output));
