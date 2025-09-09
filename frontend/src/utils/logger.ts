export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3
}

class Logger {
  private minLevel: LogLevel;

  constructor(minLevel = LogLevel.INFO) {
    this.minLevel = minLevel;
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

  private writeLog(level: LogLevel, message: string, ...args: any[]) {
    if (level < this.minLevel) return;

    const timestamp = this.getTimestamp();
    const levelStr = this.getLevelString(level);
    const argsStr = args.length > 0 ? ' ' + args.map(arg => 
      typeof arg === 'object' ? JSON.stringify(arg, null, 2) : String(arg)
    ).join(' ') : '';
    
    const logEntry = `[${timestamp}] [${levelStr}] ${message}${argsStr}`;

    // 根据日志级别选择输出方式
    switch (level) {
      case LogLevel.DEBUG:
        console.debug(logEntry);
        break;
      case LogLevel.INFO:
        console.info(logEntry);
        break;
      case LogLevel.WARN:
        console.warn(logEntry);
        break;
      case LogLevel.ERROR:
        console.error(logEntry);
        break;
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
}

// 创建全局日志实例
export const logger = new Logger();

// 便捷的日志函数
export const log = {
  debug: (message: string, ...args: any[]) => logger.debug(message, ...args),
  info: (message: string, ...args: any[]) => logger.info(message, ...args),
  warn: (message: string, ...args: any[]) => logger.warn(message, ...args),
  error: (message: string, ...args: any[]) => logger.error(message, ...args)
};
