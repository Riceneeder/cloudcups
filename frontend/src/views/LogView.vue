<template>
  <el-card>
    <template #header>
      <div style="display: flex; justify-content: between; align-items: center;">
        <span>系统日志</span>
        <el-button @click="refreshLogs" :loading="loading" size="small">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>
    </template>

    <!-- 日志文件列表 -->
    <el-table 
      :data="logFiles" 
      v-loading="loading"
      @row-click="viewLog"
      style="cursor: pointer; margin-bottom: 20px;"
    >
      <el-table-column prop="name" label="文件名" />
      <el-table-column prop="size" label="大小" :formatter="formatFileSize" />
      <el-table-column prop="modified" label="修改时间" :formatter="formatDate" />
    </el-table>

    <!-- 日志内容 -->
    <div v-if="selectedLog">
      <el-divider content-position="left">
        {{ selectedLog.filename }} 
        <span v-if="selectedLog.totalLines !== selectedLog.returnedLines">
          (显示最近 {{ selectedLog.returnedLines }} / {{ selectedLog.totalLines }} 行)
        </span>
      </el-divider>
      
      <el-input
        v-model="logContent"
        type="textarea"
        :rows="20"
        readonly
        style="font-family: 'Courier New', monospace; font-size: 12px;"
      />
    </div>
  </el-card>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { ElMessage } from 'element-plus';
import { Refresh } from '@element-plus/icons-vue';

interface LogFile {
  name: string;
  size: number;
  created: string;
  modified: string;
}

interface LogContent {
  filename: string;
  content: string;
  totalLines: number;
  returnedLines: number;
}

const logFiles = ref<LogFile[]>([]);
const selectedLog = ref<LogContent | null>(null);
const logContent = ref('');
const loading = ref(false);

const formatFileSize = (row: LogFile) => {
  const bytes = row.size;
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const formatDate = (row: LogFile) => {
  return new Date(row.modified).toLocaleString('zh-CN');
};

const refreshLogs = async () => {
  loading.value = true;
  try {
    const { data } = await axios.get('/api/logs');
    if (data.error) {
      ElMessage.error('获取日志列表失败：' + data.error);
    } else {
      logFiles.value = data.files || [];
    }
  } catch (error) {
    ElMessage.error('无法连接到服务器');
  }
  loading.value = false;
};

const viewLog = async (row: LogFile) => {
  loading.value = true;
  try {
    const { data } = await axios.get(`/api/logs/${row.name}`);
    if (data.error) {
      ElMessage.error('读取日志文件失败：' + data.error);
    } else {
      selectedLog.value = data;
      logContent.value = data.content;
    }
  } catch (error) {
    ElMessage.error('无法读取日志文件');
  }
  loading.value = false;
};

onMounted(() => {
  refreshLogs();
});
</script>

<style scoped>
.el-table :deep(.el-table__row) {
  cursor: pointer;
}

.el-table :deep(.el-table__row:hover) {
  background-color: #f5f7fa;
}
</style>
