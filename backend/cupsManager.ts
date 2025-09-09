import { spawn } from 'child_process';
import { PrintOptions } from './types';
import { log } from './logger';

let cups: any;
try {
  cups = require('cups');
  log.info('node-cups 模块加载成功');
} catch (e) {
  log.warn('node-cups 模块未找到，将使用命令行模式', e);
  // console.warn('node-cups not found, falling back to command line');
}

export async function getPrinters(): Promise<string[]> {
  if (cups && cups.getPrinterNames) {
    try {
      log.info('使用 node-cups 获取打印机列表');
      const printers = await cups.getPrinterNames();
      log.info('node-cups 获取打印机成功', printers);
      // console.log('Found printers via node-cups:', printers);
      return printers;
    } catch (error) {
      log.warn('node-cups 获取打印机失败，降级到命令行模式', error);
      // console.warn('node-cups failed, falling back to lpstat:', error.message);
    }
  }
  
  // 降级到命令行模式
  log.info('使用 lpstat 命令获取打印机列表');
  // console.log('Using lpstat fallback for printer detection');
  const proc = Bun.spawn(['lpstat', '-a']);
  const output = await new Response(proc.stdout).text();
  log.debug('lpstat 命令输出', output);
  const printers = output
    .split('\n')
    .map(line => line.split(' ')[0])
    .filter(Boolean);
  log.info('lpstat 获取打印机成功', printers);
  // console.log('Found printers via lpstat:', printers);
  return printers;
}

export async function printFile(filePath: string, options: PrintOptions): Promise<{ jobId?: string; error?: string }> {
  try {
    log.info('开始打印文件', { filePath, options });
    if (cups && cups.printFile) {
      try {
        log.info('使用 node-cups 进行打印');
        // console.log('Using node-cups for printing');
        const jobId = await cups.printFile(options.printer, filePath, {
          'copies': options.copies,
          'sides': options.duplex === true ? 'two-sided-long-edge' : 'one-sided',
          'ColorModel': options.color === true ? 'Color' : 'Gray',
          'media': options.media,
          'orientation-requested': options.orientation === 'landscape' ? 4 : 3,
          ...(options.pageRange ? { 'page-ranges': options.pageRange } : {})
        });
        log.info('node-cups 打印成功', { jobId });
        return { jobId: String(jobId) };
      } catch (cupsError) {
        log.warn('node-cups 打印失败，降级到 lp 命令', cupsError);
        // console.warn('node-cups printing failed, falling back to lp:', cupsError.message);
      }
    }
    
    // 降级到命令行模式
    log.info('使用 lp 命令进行打印');
    // console.log('Using lp command for printing');
    const args = [
      '-d', options.printer,
      '-n', String(options.copies),
      '-o', `media=${options.media}`,
      '-o', `sides=${options.duplex === true ? 'two-sided-long-edge' : 'one-sided'}`,
      '-o', `ColorModel=${options.color === true ? 'Color' : 'Gray'}`,
      '-o', `orientation-requested=${options.orientation === 'landscape' ? 4 : 3}`
    ];
    if (options.pageRange) args.push('-P', options.pageRange);
    args.push(filePath);

    log.info('执行 lp 命令', { args });
    // console.log('Executing lp command with args:', args);
    const proc = Bun.spawn(['lp', ...args]);
    const output = await new Response(proc.stdout).text();
    log.info('lp 命令输出', output);
    // console.log('lp command output:', output);
    
    // 支持中英文的作业ID解析
    if (output.includes('request id is') || output.includes('请求 ID 为')) {
      // 英文格式: "request id is HP_LaserJet_Pro_MFP_M126a-32"
      // 中文格式: "请求 ID 为 HP_LaserJet_Pro_MFP_M126a-32 (1 个文件)"
      let jobId;
      
      if (output.includes('request id is')) {
        jobId = output.match(/request id is ([^\s]+)/)?.[1];
      } else if (output.includes('请求 ID 为')) {
        jobId = output.match(/请求 ID 为\s+([^\s]+)/)?.[1];
      }
      
      if (jobId) {
        log.info('提取到作业ID', jobId);
        // console.log('Extracted job ID:', jobId);
        return { jobId };
      }
    }
    
    log.error('打印失败或无法解析作业ID', output);
    return { error: output || 'Unknown print error' };
  } catch (err: any) {
    log.error('打印过程发生错误', err);
    // console.error('Print error:', err);
    return { error: err.message || String(err) };
  }
}
