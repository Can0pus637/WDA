% 读取数据表  
T = readtable('Final_Rounded_FPGA_Table.csv', 'VariableNamingRule', 'preserve');

% 提取方法和矩阵尺寸
methods = unique(T.("Method"), 'stable');
sizes = unique(T.("M"), 'stable');

% 初始化功耗数据
Power_data = zeros(length(sizes), length(methods));

for i = 1:length(sizes)
    for j = 1:length(methods)
        idx = strcmp(T.("M"), sizes{i}) & strcmp(T.("Method"), methods{j});
        if any(idx)
            Power_data(i, j) = T.("Dynamic Power (W)")(idx);
        else
            Power_data(i, j) = NaN;
        end
    end
end

% 绘图
figure;
b = bar(Power_data, 'grouped');
set(gca, 'xticklabel', sizes);
legend(methods, 'Location', 'northwest');
xlabel('Matrix Size');
ylabel('Power (W)');
title('Power Comparison');
grid on;
set(gca, 'FontSize', 12);
ylim([0, max(Power_data(:), [], 'omitnan') * 1.2]);

% 获取 OBC 柱子的中心位置（第1组）
x_vals = b(1).XEndPoints;

% 设置失败组索引（如 12x12 和 16x16）
fail_groups = [3, 4];
fail_x = x_vals(fail_groups);
ymax = max(Power_data(:), [], 'omitnan');
fail_y = ones(1, length(fail_groups)) * ymax * 0.01;

% 添加蓝色 ×
for i = 1:length(fail_groups)
    text(fail_x(i), fail_y(i), '×', ...
        'Color', [0 0.3 1], ...
        'FontSize', 18, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
end

% 添加统一说明 annotation
annotation('textbox', [0.52, 0.02, 0.5, 0.05], ...
    'String', '"×" indicates synthesis failure', ...
    'FontSize', 10, 'FontAngle', 'italic', ...
    'Color', [0 0 0.6], ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');
