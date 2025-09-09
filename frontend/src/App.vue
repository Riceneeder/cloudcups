<template>
  <el-container style="height: 100vh;">
    <el-header>
      <h2>101打印服务</h2>
    </el-header>
    <el-main>
      <PrintView />
    </el-main>
  </el-container>
</template>

<script setup>
import PrintView from './views/PrintView.vue';
</script>
