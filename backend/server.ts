import { Elysia } from 'elysia';
import { getPrinters, printFile } from './cupsManager.ts';
import { PrintOptions } from './types.ts';
import { log } from './logger.ts';
import { logRoutes } from './logRoutes.ts';

const app = new Elysia()
  .use(logRoutes)
  .onRequest(({ request, set }) => {
    set.headers['Access-Control-Allow-Origin'] = '*';
    set.headers['Access-Control-Allow-Methods'] = 'GET,POST,OPTIONS';
    set.headers['Access-Control-Allow-Headers'] = 'Content-Type';
  })
  .get('/api/printers', async () => {
    try {
      log.info('获取打印机列表请求');
      const printers = await getPrinters();
      log.info('成功获取打印机列表', { count: printers.length, printers });
      return { printers };
    } catch (e) {
      log.error('获取打印机列表失败', e);
      return { error: '无法获取打印机列表' };
    }
  })
  .post('/api/print', async ({ request }) => {
    const formData = await request.formData();
    const file = formData.get('file');
    const optionsRaw = formData.get('options');
    if (!file || !(file instanceof File)) {
      log.warn('打印请求缺少文件');
      return { error: '未上传文件' };
    }
    if (!optionsRaw) {
      log.warn('打印请求缺少参数');
      return { error: '缺少打印参数' };
    }
    let options: PrintOptions;
    try {
      options = JSON.parse(optionsRaw as string);
      log.info('收到打印请求', { fileName: file.name, options });
    } catch {
      log.error('打印参数解析失败', optionsRaw);
      return { error: '打印参数格式错误' };
    }
    if (!file.name.match(/\.(pdf|docx?|png|jpg|jpeg)$/i)) {
      log.warn('不支持的文件类型', file.name);
      return { error: '仅支持 PDF/Word/图片文件' };
    }
    
    const tempPath = `/tmp/${Date.now()}_${file.name}`;
    await Bun.write(tempPath, file);
    log.info('临时文件已保存', tempPath);
    
    try {
      const result = await printFile(tempPath, options);
      
      // 打印成功后删除临时文件
      if (!result.error) {
        log.info('打印作业提交成功', result);
        // 延迟删除，确保打印作业已经读取了文件
        setTimeout(async () => {
          try {
            await Bun.write(tempPath, ''); // 清空文件内容
            log.info('临时文件已清理', tempPath);
            // console.log(`临时文件已清理: ${tempPath}`);
          } catch (cleanupError) {
            log.error('清理临时文件失败', { path: tempPath, error: cleanupError });
            // console.warn(`清理临时文件失败: ${tempPath}`, cleanupError);
          }
        }, 5000); // 5秒后删除
      } else {
        log.error('打印作业失败', result);
        // 打印失败时立即删除文件
        try {
          await Bun.write(tempPath, '');
          log.info('打印失败，临时文件已清理', tempPath);
          // console.log(`打印失败，临时文件已清理: ${tempPath}`);
        } catch (cleanupError) {
          log.error('清理临时文件失败', { path: tempPath, error: cleanupError });
          // console.warn(`清理临时文件失败: ${tempPath}`, cleanupError);
        }
      }
      
      return result;
    } catch (error) {
      log.error('打印过程发生异常', error);
      // 发生异常时也要清理文件
      try {
        await Bun.write(tempPath, '');
        log.info('异常发生，临时文件已清理', tempPath);
        // console.log(`异常发生，临时文件已清理: ${tempPath}`);
      } catch (cleanupError) {
        log.error('清理临时文件失败', { path: tempPath, error: cleanupError });
        // console.warn(`清理临时文件失败: ${tempPath}`, cleanupError);
      }
      throw error;
    }
  })
  .get('/*', async ({ request }) => {
    const url = new URL(request.url);
    let filePath = url.pathname === '/' ? '/index.html' : url.pathname;
    try {
      return Bun.file(`../frontend/dist${filePath}`);
    } catch {
      return Bun.file(`../frontend/dist/index.html`);
    }
  });

app.listen(3000);
log.always('Print server running at http://localhost:3000');
// console.log('Print server running at http://localhost:3000');
