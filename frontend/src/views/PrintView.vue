<template>
  <el-card>
    <template #header>
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <span>云打印服务</span>
        <el-button 
          text 
          size="small" 
          @click="showLogs = !showLogs"
        >
          <el-icon><Document /></el-icon>
          {{ showLogs ? '隐藏日志' : '查看日志' }}
        </el-button>
      </div>
    </template>

    <FileUploader v-model:file="file" :key="uploadKey" />
    
    <!-- 显示已选择的文件信息 -->
    <el-alert 
      v-if="file" 
      :title="`已选择文件: ${file.name} (${(file.size / 1024 / 1024).toFixed(2)} MB)`" 
      type="success" 
      show-icon 
      closable
      @close="onFileAlertClose"
      style="margin-top: 10px;" 
    />
    
    <!-- 文件预览区域 -->
    <div v-if="file && filePreviewUrl" style="margin-top: 20px;">
      <h4 style="margin-bottom: 16px; color: #303133;">
        <el-icon style="margin-right: 8px;"><View /></el-icon>
        文件预览
      </h4>
      <div style="border: 1px solid #dcdfe6; border-radius: 8px; padding: 16px; max-height: 450px; overflow: auto; background-color: #fafafa;">
        <!-- 图片预览 -->
        <img 
          v-if="isImageFile" 
          :src="filePreviewUrl" 
          alt="文件预览" 
          style="max-width: 100%; max-height: 400px; display: block; margin: 0 auto; border-radius: 4px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"
          @load="onPreviewLoad"
          @error="onPreviewError"
        />
        <!-- PDF预览 -->
        <iframe 
          v-else-if="isPdfFile"
          :src="filePreviewUrl" 
          style="width: 100%; height: 400px; border: none; border-radius: 4px;"
          @load="onPreviewLoad"
        ></iframe>
        <!-- 其他文件类型 -->
        <div v-else style="text-align: center; padding: 60px 20px; color: #909399;">
          <el-icon style="font-size: 64px; margin-bottom: 16px; color: #c0c4cc;"><Document /></el-icon>
          <p style="font-size: 16px; font-weight: 500; margin-bottom: 8px;">{{ file.name }}</p>
          <p style="font-size: 14px; color: #c0c4cc;">此文件类型不支持预览，但可以正常打印</p>
        </div>
      </div>
    </div>
    
    <el-form :model="form" label-width="120px" style="margin-top: 20px;">
      <el-form-item label="打印机">
        <el-select v-model="form.printer" placeholder="请选择打印机" :loading="loadingPrinters">
          <el-option v-for="p in printers" :key="p" :label="p" :value="p" />
        </el-select>
        <div v-if="printers.length === 0 && !loadingPrinters" style="color: #f56c6c; font-size: 12px; margin-top: 4px;">
          未检测到打印机，请检查 CUPS 服务和打印机配置
        </div>
      </el-form-item>
      <el-form-item label="份数">
        <el-input-number v-model="form.copies" :min="1" />
      </el-form-item>
      <el-form-item label="纸张大小">
        <el-select v-model="form.media">
          <el-option label="A4" value="A4" />
          <el-option label="A3" value="A3" />
        </el-select>
      </el-form-item>
      <el-form-item label="方向">
        <el-radio-group v-model="form.orientation">
          <el-radio label="portrait">纵向</el-radio>
          <el-radio label="landscape">横向</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="页面范围">
        <el-input v-model="form.pageRange" placeholder="如 1-3,5" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" :disabled="!file || !form.printer" @click="submitPrint" :loading="printing">
          {{ printing ? '打印中...' : '打印' }}
        </el-button>
        <el-button v-if="file" @click="clearFile" style="margin-left: 10px;">
          清除文件
        </el-button>
      </el-form-item>
    </el-form>
    <el-alert 
      v-if="result" 
      :title="resultTitle" 
      :type="resultType" 
      show-icon 
      closable
      @close="onResultAlertClose"
      style="margin-top: 20px;" 
    />
    
    <!-- 日志查看器 -->
    <el-card v-if="showLogs" style="margin-top: 20px;">
      <LogView />
    </el-card>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed, watch, nextTick } from 'vue';
import FileUploader from '../components/FileUploader.vue';
import LogView from './LogView.vue';
import axios from 'axios';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Document, View } from '@element-plus/icons-vue';
import { log } from '../utils/logger';

const file = ref<File | null>(null);
const printers = ref<string[]>([]);
const loadingPrinters = ref(false);
const showLogs = ref(false);
const printing = ref(false);
const result = ref<string | null>(null);
const filePreviewUrl = ref<string>('');
const uploadKey = ref(0); // 用于强制重新渲染FileUploader组件

const form = reactive({
  printer: '',
  copies: 1,
  media: 'A4',
  orientation: 'portrait',
  pageRange: ''
});

// 计算属性
const resultType = computed(() => result.value?.includes('error') ? 'error' : 'success');
const resultTitle = computed(() => result.value?.includes('error') ? result.value : `打印任务提交成功：${result.value}`);

const isImageFile = computed(() => {
  if (!file.value) return false;
  return /\.(png|jpg|jpeg|gif|bmp|webp)$/i.test(file.value.name);
});

const isPdfFile = computed(() => {
  if (!file.value) return false;
  return /\.pdf$/i.test(file.value.name);
});

// 监听文件变化，生成预览
watch(file, async (newFile) => {
  if (filePreviewUrl.value) {
    URL.revokeObjectURL(filePreviewUrl.value);
  }
  
  if (newFile) {
    filePreviewUrl.value = URL.createObjectURL(newFile);
  } else {
    filePreviewUrl.value = '';
  }
});

// 自动消失的消息提示
const showMessage = (message: string, type: 'success' | 'error' | 'warning' = 'success') => {
  ElMessage({
    message,
    type,
    duration: 5000, // 5秒后自动消失
    showClose: true
  });
};

onMounted(async () => {
  loadingPrinters.value = true;
  log.info('组件挂载，开始加载打印机列表');
  try {
    const { data } = await axios.get('/api/printers');
    printers.value = data.printers || [];
    log.info('打印机列表加载成功', data.printers);
    if (data.error) {
      log.warn('获取打印机列表时收到错误', data.error);
      showMessage('获取打印机列表失败：' + data.error, 'warning');
    }
  } catch (error) {
    log.error('无法连接到打印服务器', error);
    showMessage('无法连接到打印服务器，请检查后端服务是否运行', 'error');
    printers.value = [];
  }
  loadingPrinters.value = false;
});

// 清除文件
function clearFile() {
  log.info('清除文件并重置上传组件');
  // console.log('Clearing file and resetting upload component...');
  
  if (filePreviewUrl.value) {
    URL.revokeObjectURL(filePreviewUrl.value);
  }
  file.value = null;
  filePreviewUrl.value = '';
  result.value = null;
  
  // 强制重新渲染FileUploader组件以重置其状态
  uploadKey.value += 1;
  log.info('上传组件key已更新', uploadKey.value);
  // console.log('Upload key updated to:', uploadKey.value);
  
  showMessage('文件已移除', 'success');
}

// 文件信息提示关闭事件
async function onFileAlertClose() {
  try {
    await ElMessageBox.confirm(
      '确定要移除已选择的文件吗？',
      '移除文件',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    );
    clearFile();
  } catch {
    // 用户点击取消，不做任何操作
    log.info('用户取消移除文件');
    // console.log('用户取消移除文件');
  }
}

// 结果提示关闭事件
function onResultAlertClose() {
  result.value = null;
}

// 预览加载事件
function onPreviewLoad() {
  log.info('文件预览加载完成');
  // console.log('文件预览加载完成');
}

function onPreviewError() {
  showMessage('文件预览加载失败', 'warning');
}

async function submitPrint() {
  if (!file.value) {
    showMessage('请先选择要打印的文件', 'error');
    return;
  }
  
  if (!form.printer) {
    showMessage('请选择打印机', 'error');
    return;
  }

  log.info('开始提交打印任务', { fileName: file.value.name, form });
  printing.value = true;
  result.value = null;
  
  const formData = new FormData();
  formData.append('file', file.value);
  formData.append('options', JSON.stringify(form));
  
  try {
    log.info('发送打印请求到后端');
    const { data } = await axios.post('/api/print', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
    
    if (data.error) {
      log.error('打印任务失败', data.error);
      result.value = `error: ${data.error}`;
      showMessage('打印失败：' + data.error, 'error');
    } else {
      log.info('打印任务提交成功', { jobId: data.jobId });
      result.value = `任务ID: ${data.jobId || '未知'}`;
      showMessage('打印任务提交成功！', 'success');
      
      // 打印成功后自动清除文件
      setTimeout(() => {
        clearFile();
      }, 2000); // 2秒后清除文件，让用户看到成功消息
    }
  } catch (error: any) {
    const errorMsg = error.response?.data?.error || error.message || '网络错误';
    log.error('打印请求失败', errorMsg);
    result.value = `error: ${errorMsg}`;
    showMessage('打印失败：' + errorMsg, 'error');
  } finally {
    printing.value = false;
  }
  
  // 5秒后自动清除结果提示
  setTimeout(() => {
    result.value = null;
  }, 5000);
}

// 组件卸载时清理URL对象
import { onUnmounted } from 'vue';
onUnmounted(() => {
  if (filePreviewUrl.value) {
    URL.revokeObjectURL(filePreviewUrl.value);
  }
});
</script>
