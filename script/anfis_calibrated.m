%%latih di simulasi -> uji robot -> perbaiki model -> uji robot -> repeat

error_yaw_asli = [10, 5, -3, 8, -7, 15];             %data error
kontrol_asli = [8.5, 4.2, -2.8, 6.8, -5.9, 14.7];    %kontrol asli pada robot

data_asli = [error_yaw_asli', kontrol_asli'];   %dataset rl
FIS_lama = readfis('anfis_trained.fis');      %baca modul simulasi

opt = anfisOptions('InitialFIS', FIS_lama, 'EpochNumber', 400, 'StepSizeDecreaseRate', 0.01);       %modul lama utk referensi

%modul lama digunakan sbg ref, lalu menggunakan dataset asli hingga anfis -
%modul baru ini akan mempelajari modul lama(teori) dengan dataset -
%asli(praktek), jadi membuat modul baru yang lebih mantap

FIS_final = anfis(data_asli, opt);      %modul baru

writeFIS(FIS_final, 'anfis_final.fis');      %simpan modul final
disp('Model ANFIS final (real) telah disimpan!');

test_error = [10; 9; -3; 12]; %tes input baru
control_lama = evalfis(modul_lama, test_error); %simulasi (kontrol saat simulasi)
control_baru = evalfis(FIS_final, test_error);  %data asli (kontrol praktek)

fprintf('\nPerbandingan Output Kontrol:\n');    %perbandingan
fprintf('%8s %15s %15s\n', 'Error', 'Simulasi', 'Real-Finetune');
fprintf('%8s %15s %15s\n', '------', '--------', '-----------');

for i = 1:length(test_error)
    fprintf('%8.1f %15.2f %15.2f\n', test_error(i), control_lama(i), control_baru(i));
end

set_point = 0;
yaw = 10;
yaw_log;
time_log;
max_iter = 30;

fprintf('   SIMULASI KONTROL REAL-TIME  \n');
fprintf('Posisi awal yaw: %.2f°\n', yaw);
fprintf('Target (setpoint): %.2f°\n', set_point);
fprintf('Model ANFIS: anfis_final.fis\n\n');

for k = 1:max_iter
    error = yaw - set_point;    %hitung eror yaw

    control = evalfis(FIS_final, error);
    yaw = yaw - control;    %update yaw

    hasil_pos_x = 12 * (cosd(control) -1);
    hasil_pos_y = 12 * sind(control);

    yaw_log = [yaw_log, yaw];
    time_log = [time_log, k];

    fprintf('Loop %2d: error = %6.2f°, control = %6.2f°, yaw = %6.2f°\n', ...
        k, error, control, yaw);
    fprintf('         : hasil pos x = %6.2f\n         : hasil pos y = %6.2f \n', hasil_pos_x, hasil_pos_y);

    if abs(error) < 0.1 && abs(control) < 0.5
        fprintf('\n Robot berhasil mencapai setpoint di loop ke-%d\n', k);
        break;
    end
end

if k == max_iter
    fprintf('\n  Simulasi berhenti karena mencapai maksimal iterasi (%d)\n', max_iter);
    fprintf('   Robot belum sepenuhnya lurus. Pertimbangkan tuning ulang ANFIS.\n');
end
