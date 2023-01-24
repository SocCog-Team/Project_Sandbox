function [output] = Create_RT_plots_by_category_A_vs_B (RT_A, RT_B)
%create plots for reaction time of subject A against subject B
ReactionTimes_A_vs_B = figure('Name', 'ReactionTimes_A_vs_B', 'visible', figure_visibility_string);
fnFormatDefaultAxes(DefaultAxesType);
[output_rect] = fnFormatPaperSize(DefaultPaperSizeType, gcf, output_rect_fraction);
set(gcf(), 'Units', 'centimeters', 'Position', output_rect, 'PaperPosition', output_rect, 'PaperPosition', output_rect );
legend_list = {};
hold on

plot (