import { Elysia } from 'elysia';
import { readFile, readdir, stat } from 'fs/promises';
import { join } from 'path';

export const logRoutes = new Elysia({ prefix: '/api/logs' })
  .get('/', async () => {
    try {
      const logDir = 'logs';
      const files = await readdir(logDir);
      const logFiles = files
        .filter(file => file.endsWith('.log'))
        .sort((a, b) => b.localeCompare(a)); // 按日期倒序
      
      const fileStats = await Promise.all(
        logFiles.map(async (file) => {
          const filePath = join(logDir, file);
          const stats = await stat(filePath);
          return {
            name: file,
            size: stats.size,
            created: stats.birthtime,
            modified: stats.mtime
          };
        })
      );
      
      return { files: fileStats };
    } catch (error) {
      return { error: '无法读取日志目录' };
    }
  })
  .get('/:filename', async ({ params: { filename } }) => {
    try {
      const logPath = join('logs', filename);
      const content = await readFile(logPath, 'utf-8');
      const lines = content.split('\n').filter(Boolean);
      
      // 只返回最后1000行，避免文件过大
      const recentLines = lines.slice(-1000);
      
      return { 
        filename,
        content: recentLines.join('\n'),
        totalLines: lines.length,
        returnedLines: recentLines.length
      };
    } catch (error) {
      return { error: '无法读取日志文件' };
    }
  });
