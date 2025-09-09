import { writeFile, appendFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';
import { join } from 'path';

export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3
}

class Logger {
  private logDir: string;
  private logFile: string;
  private minLevel: LogLevel;

  constructor(logDir = 'logs', minLevel = LogLevel.INFO) {
    this.logDir = logDir;
    this.logFile = join(logDir, `app-${new Date().toISOString().split('T')[0]}.log`);
    this.minLevel = minLevel;
    this.init();
  }

  private async init() {
    try {
      if (!existsSync(this.logDir)) {
        await mkdir(this.logDir, { recursive: true });
      }
    } catch (error) {
      console.error('Failed to create log directory:', error);
    }
  }

  private getTimestamp(): string {
    return new Date().toISOString();
  }

  private getLevelString(level: LogLevel): string {
    switch (level) {
      case LogLevel.DEBUG: return 'DEBUG';
      case LogLevel.INFO: return 'INFO';
      case LogLevel.WARN: return 'WARN';
      case LogLevel.ERROR: return 'ERROR';
      default: return 'UNKNOWN';
    }
  }

  private async writeLog(level: LogLevel, message: string, ...args: any[]) {
    if (level < this.minLevel) return;

    const timestamp = this.getTimestamp();
    const levelStr = this.getLevelString(level);
    const argsStr = args.length > 0 ? ' ' + args.map(arg => 
      typeof arg === 'object' ? JSON.stringify(arg, null, 2) : String(arg)
    ).join(' ') : '';
    
    const logEntry = `[${timestamp}] [${levelStr}] ${message}${argsStr}\n`;

    try {
      await appendFile(this.logFile, logEntry);
    } catch (error) {
      // 如果写入失败，至少输出到控制台
      console.error('Failed to write to log file:', error);
      console.log(logEntry.trim());
    }
  }

  debug(message: string, ...args: any[]) {
    this.writeLog(LogLevel.DEBUG, message, ...args);
  }

  info(message: string, ...args: any[]) {
    this.writeLog(LogLevel.INFO, message, ...args);
  }

  warn(message: string, ...args: any[]) {
    this.writeLog(LogLevel.WARN, message, ...args);
  }

  error(message: string, ...args: any[]) {
    this.writeLog(LogLevel.ERROR, message, ...args);
  }

  // 特殊方法：始终输出到控制台和日志文件（用于重要信息）
  always(message: string, ...args: any[]) {
    const timestamp = this.getTimestamp();
    const argsStr = args.length > 0 ? ' ' + args.map(arg => 
      typeof arg === 'object' ? JSON.stringify(arg, null, 2) : String(arg)
    ).join(' ') : '';
    
    const logEntry = `[${timestamp}] [INFO] ${message}${argsStr}`;
    console.log(logEntry);
    this.writeLog(LogLevel.INFO, message, ...args);
  }
}

// 创建全局日志实例
export const logger = new Logger();

// 便捷的日志函数
export const log = {
  debug: (message: string, ...args: any[]) => logger.debug(message, ...args),
  info: (message: string, ...args: any[]) => logger.info(message, ...args),
  warn: (message: string, ...args: any[]) => logger.warn(message, ...args),
  error: (message: string, ...args: any[]) => logger.error(message, ...args),
  always: (message: string, ...args: any[]) => logger.always(message, ...args)
};
