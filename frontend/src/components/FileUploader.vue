<template>
  <el-upload
    ref="uploadRef"
    drag
    :auto-upload="false"
    :show-file-list="false"
    :before-upload="beforeUpload"
    :on-change="handleChange"
    :limit="1"
    accept=".pdf,.doc,.docx,.png,.jpg,.jpeg"
  >
    <el-icon style="font-size: 67px; color: #8c939d;">
      <Upload />
    </el-icon>
    <div class="el-upload__text">拖拽文件到此或点击上传</div>
    <div class="el-upload__tip">支持 PDF、Word、图片文件</div>
  </el-upload>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { ElMessage } from 'element-plus';
import { Upload } from '@element-plus/icons-vue';
import { log } from '../utils/logger';

// 只负责文件选择，文件通过 v-model:file 传递给父组件
const props = defineProps<{ file: File | null }>();
const emit = defineEmits(['update:file']);

const uploadRef = ref();

// 监听file prop的变化，当文件被清除时重置upload组件
watch(() => props.file, (newFile) => {
  if (!newFile && uploadRef.value) {
    // 文件被清除，重置upload组件状态
    log.info('重置上传组件状态');
    // console.log('Resetting upload component state');
    try {
      uploadRef.value.clearFiles();
      // 额外重置，确保组件完全清空
      if (uploadRef.value.uploadFiles) {
        uploadRef.value.uploadFiles = [];
      }
    } catch (error) {
      log.warn('重置上传组件时出错', error);
      // console.warn('Error resetting upload component:', error);
    }
  }
});

function beforeUpload(file: File) {
  log.info('beforeUpload 被调用', { fileName: file.name, size: file.size });
  // console.log('beforeUpload called with:', file);
  const valid = /\.(pdf|docx?|png|jpg|jpeg)$/i.test(file.name);
  if (!valid) {
    log.warn('用户选择了不支持的文件类型', file.name);
    ElMessage({
      message: '仅支持 PDF/Word/图片文件',
      type: 'error',
      duration: 5000,
      showClose: true
    });
    return false;
  }
  return false; // 阻止自动上传，我们只是选择文件
}

function handleChange(uploadFile: any) {
  log.info('handleChange 被调用', { uploadFile: uploadFile?.name || 'unknown' });
  // console.log('handleChange called with:', uploadFile);
  
  try {
    // 处理不同的文件对象结构
    let file: File;
    
    if (uploadFile?.raw && uploadFile.raw instanceof File) {
      // Element Plus upload 组件格式
      file = uploadFile.raw;
    } else if (uploadFile instanceof File) {
      // 直接的 File 对象
      file = uploadFile;
    } else if (uploadFile?.file && uploadFile.file instanceof File) {
      // 某些情况下可能在 file 属性中
      file = uploadFile.file;
    } else {
      log.error('无法识别的文件对象格式', uploadFile);
      // console.error('无法识别的文件对象格式:', uploadFile);
      ElMessage({
        message: '文件格式错误，请重新选择',
        type: 'error',
        duration: 5000,
        showClose: true
      });
      return;
    }
    
    log.info('文件选择成功', { fileName: file.name, size: file.size });
    // console.log('Selected file:', file);
    emit('update:file', file);
    ElMessage({
      message: `已选择文件: ${file.name} (${(file.size / 1024 / 1024).toFixed(2)} MB)`,
      type: 'success',
      duration: 5000,
      showClose: true
    });
  } catch (error) {
    log.error('处理文件时出错', error);
    // console.error('处理文件时出错:', error);
    ElMessage({
      message: '处理文件时出错，请重试',
      type: 'error',
      duration: 5000,
      showClose: true
    });
  }
}
</script>
