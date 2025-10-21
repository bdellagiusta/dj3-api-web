<template>
  <el-config-provider :locale="appStore.setting.locale.value">
    <el-container :style="{'--sideBarWidth': sideBarWidth}">
      
      <el-aside v-if="isAdmin" class="app-left">
        <g-aside></g-aside>
      </el-aside>
      <el-container class="app-container ">
        <el-header class="app-header">
          <g-header></g-header>
        </el-header>
        <div class="header-tags">
          <tags></tags>
        </div>

        <el-main class="app-main">

          <router-view v-slot="{ Component }">
            <transition mode="out-in" name="el-fade-in-linear">
              <keep-alive :include="cachedTags">
                <component :is="Component"/>
              </keep-alive>
            </transition>
          </router-view>
      
        </el-main>
      </el-container>
    </el-container>
  </el-config-provider>
</template>

<script setup>
  import { useAppStore } from '@/store/app'
  import { useTagsStore } from '@/store/tags'
  import { ref, computed } from 'vue'
  import Tags from '@/layout/components/tags/index.vue'
  import GAside from '@/layout/components/aside.vue'
  import GHeader from '@/layout/components/header.vue'

  const appStore = useAppStore()
  const sideBarWidth = computed(() => appStore.setting.locale.sideBarWidth)
  
  const tagStore = useTagsStore()
  const cachedTags = ref([])
  cachedTags.value = tagStore.cached

// Obtener información del usuario desde localStorage
const userInfo = computed(() => {
  const userStr = localStorage.getItem('user_info')
  return userStr ? JSON.parse(userStr) : null
})

const currentUsername = computed(() => userInfo.value?.name || '')

// Verificar si es admin
const isAdmin = computed(() => userInfo.value?.name === 'admin')

console.log('Current User:', currentUsername.value)
console.log('Is Admin:', isAdmin.value)
</script>

<style lang="scss" scoped>
.app-header {
  background-color: #3f454b;
  color: var(--basicWhite);
  display: flex;
  height: 50px;
}

.header-tags {
  height: auto;
  border-bottom: 1px solid #eee;
  display: flex;
  padding: 0;
}



.app-container {
  min-height: 100vh;
}
</style>


