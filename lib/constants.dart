const int kBoxCount = 106;
const int kMetricCount = 3;
const bool kMetricsStartWith1 = true;

String metricLabel(int index) => 'T${index + (kMetricsStartWith1 ? 1 : 0)}';
