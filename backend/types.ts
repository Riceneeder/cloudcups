export interface PrintOptions {
  printer: string;
  copies: number;
  duplex?: boolean; // 可选，默认false
  color?: boolean; // 可选，默认false（黑白打印）
  media: string; // 纸张大小，如 'A4'
  orientation: 'portrait' | 'landscape';
  pageRange?: string; // 如 '1-3,5'
}
